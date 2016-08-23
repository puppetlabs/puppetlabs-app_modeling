Puppet::Type.newtype :data_capability, is_capability: true do
  newparam :name
  newparam :data do
    desc "the data to pass through the capability"
  end
end
