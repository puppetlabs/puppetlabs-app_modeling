require 'puppet/provider'

class Puppet::Provider::NullProvider < Puppet::Provider
  # This always returns true since we don't care about availability
  def exists?
    return true
  end
end
