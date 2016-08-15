require 'puppet/provider'
#Use the null provider
Puppet::Type.type(:data_capability).provide(:data_capability, parent: Puppet::Provider::NullProvider) {}
