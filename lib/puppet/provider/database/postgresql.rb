require_relative '../app_modeling_monitor'

Puppet::Type.type(:database).provide(:postgresql,
                                     :parent => Puppet::Provider::AppModelingMonitor) do
  confine :feature => :postgres

  def validate
    db_uri = "tcp://#{resource[:host]}:#{resource[:port]}}/"

    begin
      connect
      true
    rescue Exception => e
      Puppet.notice("Unable to connect to postgresql database #{resource[:database]} at #{db_uri}: " + e.message)
      false
    end
  end

  def connect
    conn = PostgresPR::Connection.new(resource[:database],
                                      resource[:user],
                                      resource[:password],
                                      db_uri)
    conn.query( "SELECT 1" )
  end
end
