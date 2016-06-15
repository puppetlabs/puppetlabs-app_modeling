Puppet::Type.newtype :mysql_server, :is_capability => true do
  newparam :name, :is_namevar => true
  newparam :host
  newparam :database
end
