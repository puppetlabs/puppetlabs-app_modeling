require 'socket'
require 'timeout'
require 'ipaddr'
begin
  require 'puppet/provider/tcp'
rescue LoadError
  require (Puppet.lookup(:environments).get!(Puppet[:environment]).module("basehealthcheck").plugin_directory + "/puppet/provider/tcp")
end

# SQL Health Checks
Puppet::Type.type(:database).provide(:tcp, :parent => Puppet::Provider::Tcp) do
  def check
    super(resource[:host], resource[:port], resource[:timeout], resource[:ping_interval])
  end
end
