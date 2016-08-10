require 'puppet/provider'

class Puppet::Provider::AppModelingMonitor < Puppet::Provider
  # Here we simply monopolize the resource API, to execute a test to see if the
  # database is connectable. When we return a state of `false` it triggers the
  # create method where we can return an error message.
  #
  # @return [bool] did the test succeed?
  def exists?
    # If this node is the producer of the capability,
    # do not run the check on that node.
    return true if resource.tags.grep(/^producer:/).any?

    timeout = resource[:timeout]

    success = false

    begin
      Timeout::timeout(timeout) do
        success = validate

        while success == false
          interval = resource[:ping_interval]
          Puppet.notice("Test failure; sleeping #{interval} second(s) before retry")
          sleep interval
          success = validate
        end
      end
    rescue Timeout::Error => ex
      Puppet.err("Testing timed out after #{timeout} second(s); giving up")
    end

    success
  end

  # Abstract method for a single validation check.
  #
  # This method must be overridden by children or a Puppet::Error will
  # be thrown.
  #
  # @return [bool] returns true if validation succeeded
  def validate
    raise Puppet::Error, "No validation method provided, ensure #validation is overridden"
  end

  # This method is called when the exists? method returns false.
  #
  # @return [void]
  def create
    # If `#create` is called, that means that `#exists?` returned false, which
    # means that the test failed so we need to cause a failure here.
    raise Puppet::Error, "Test has failed"
  end
end
