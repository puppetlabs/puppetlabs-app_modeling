require 'puppet/provider'

class Puppet::Provider::Tcp < Puppet::Provider
  def check(host, port, timeout, ping_interval)
    # If this node is the producer of the capability,
    # do not run the check on that node.
    return true if resource.tags.grep(/^producer:/).any?

    start_time = Time.now
    @tcp_host = host
    @tcp_port = port
    success = false

    begin
      while success == false && ((Time.now - start_time ) < timeout) do
        Puppet.warning "Failed to make a connection to the host #{@tcp_host}:#{@tcp_port}; sleeping #{ping_interval} seconds before trying again"
        sleep ping_interval
        success = try_connection(@tcp_host, @tcp_port, timeout)
      end
    rescue Exception => e
      Puppet.err "Error trying to connect to #{@tcp_host}:#{@tcp_port} : #{e}"
    end

    if success
      Puppet.info "Successfully made a connection to host #{@tcp_host}:#{@tcp_port}"
    else
      Puppet.err "Could not make a connection to host #{@tcp_host}:#{@tcp_port} within the #{timeout} second timeout"
    end

    success
  end

  def exists?
    check
  end

  # @api private
  def try_connection(host, port, timeout)
    Timeout::timeout(timeout) do
      begin
        TCPSocket.new(host, port).close
        true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
        false
      end
    end
  rescue Timeout::Error
    false
  end

  # This method will only be called if exists? returns falls, meaning we
  # couldn't connect to the port. In that case, the check fails and we raise an
  # error.
  def create
    raise Puppet::Error, "Unable to connect to the host: #{@tcp_host}:#{@tcp_port}"
  end
end
