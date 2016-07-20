Puppet::Type.newtype :http, :is_capability => true do
  newparam(:name, :is_namevar => true) do
    desc 'The name of the resource'
  end

  newparam(:ip) do
    desc 'IP address of the HTTP service'
  end

  newparam(:port) do
    desc 'Port of the HTTP service'
  end

  newparam(:host) do
    desc 'Hostname of the HTTP service'
  end
end
