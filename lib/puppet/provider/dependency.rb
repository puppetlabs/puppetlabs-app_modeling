require 'puppet/provider'
require 'puppet/provider/null_provider'

#Use the null provider
Puppet::Type.type(:dependency).provide(:dependency, parent: Puppet::Provider::NullProvider) {}
