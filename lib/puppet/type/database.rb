Puppet::Type.newtype :database, :is_capability => true do
  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'The name of the resource'
  end

  newparam(:database) do
    desc 'The database name'
  end

  newparam(:host) do
    desc 'The hostname of the server'
    defaultto '127.0.0.1'
  end

  newparam(:port) do
    desc 'The port to use when connecting to the server'
    defaultto 5432
  end

  newparam(:timeout) do
    desc 'The number of seconds that the validator should attempt to make a connection before giving up.'
    defaultto 60

    validate do |value|
      Integer(value)
    end

    munge do |value|
      Integer(value)
    end
  end

  newparam(:ping_interval) do
    desc 'The number of seconds to sleep before attempting to try a connection again'
    defaultto 1

    validate do |value|
      Integer(value)
    end

    munge do |value|
      Integer(value)
    end
  end

  newparam :user
  newparam :password
  newparam :instance
end
