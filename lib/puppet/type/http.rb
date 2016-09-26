Puppet::Type.newtype :http, :is_capability => true do
  @doc = "A type for testing http connections"

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :is_namevar => true) do
    desc 'The unique name of the resource'
  end

  newparam(:port) do
    desc 'The TCP port that the HTTP service is listening to'
    defaultto 80

    validate do |value|
      Integer(value)
    end

    munge do |value|
      Integer(value)
    end
  end

  newparam(:ip) do
    desc 'The external IP address of the HTTP service'
  end

  newparam(:host) do
    desc 'The hostname of the HTTP service'
  end

  newparam(:ssl) do
    desc 'Set to true if the HTTP service uses SSL encryption'
    defaultto false
  end

  newparam(:base_path) do
    desc 'Path of HTTP resource'
    defaultto "/"
  end

  newparam(:timeout) do
    desc 'Time before timing out the resource (seconds)'
    defaultto 60

    validate do |value|
      Float(value)
    end

    munge do |value|
      Float(value)
    end
  end

  newparam(:ping_interval) do
    desc 'Time to sleep before attempting to try a connection again (second)'
    defaultto 1

    validate do |value|
      Float(value)
    end

    munge do |value|
      Float(value)
    end
  end

  newparam(:status_codes) do
    desc 'An array of HTTP status codes that will return success. For example
          [200, 302] will match for OK and redirection responses.'
    defaultto [200]

    munge do |value|
      Array(value)
    end
  end
end
