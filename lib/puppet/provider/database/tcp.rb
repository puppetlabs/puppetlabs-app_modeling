require_relative '../app_modeling_monitor'
require 'socket'
require 'ipaddr'

Puppet::Type.type(:database).provide(:tcp,
                                     :parent => Puppet::Provider::AppModelingMonitor) do

  def validate
    begin
      TCPSocket.new(resource[:host], resource[:port]).close
      true
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
      Puppet.notice("Unable to connect to database at #{resource[:host]}:#{resource[:port]}: " + e.message)
      false
    end
  end
end
