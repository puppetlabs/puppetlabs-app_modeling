require 'puppet/provider'

# PSQL Health Checks
Puppet::Type.type(:database).provide(:postgresql) do
  confine :feature => :postgres

  def check(database, host, port, password, user, timeout, ping_interval)
    # If this node is the producer of the capability,
    # do not run the check on that node.
    return true if resource.tags.grep(/^producer:/).any?

    start_time = Time.now

    @db = database
    @db_host = host
    @db_port = port
    db_uri = "tcp://#{host}:#{port}"

    success = try_connection(@db, user, password, timeout, db_uri)

    while success == false && ((Time.now - start_time ) < timeout) do
      Puppet.warning "Failed to make a connection to the postgresql database host #{@db_host}:#{@db_port} on database #{@db}; sleeping #{ping_interval} seconds before trying again"
      sleep ping_interval
      success = try_connection(@db, user, password, timeout, db_uri)
    end

    if success
      Puppet.info "Successfully made a connection to the postgresql database host #{@db_host}:#{@db_port} to database #{@db}"
    else
      Puppet.err "Could not make a connection to the postgresql database host #{@db_host}:#{@db_port} to database #{@db} within the #{timeout} second timeout"
    end

    success
  end

  def exists?
    check(resource[:database], resource[:host], resource[:port], resource[:password], resource[:user], resource[:timeout], resource[:ping_interval])
  end

  def try_connection(db, user, password, timeout, db_uri)
    begin
      conn = PostgresPR::Connection.new(db, user, password, db_uri)
      conn.query( "SELECT 1" )
      true
    rescue Exception => e
      false
    end
  end

  # This method will only be called if exists? returns falls, meaning we
  # couldn't connect to the port. In that case, the check fails and we raise an
  # error.
  def create
    raise Puppet::Error, "Unable to connect to the host: #{@db_host}:#{@db_port}"
  end
end
