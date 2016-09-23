require 'puppet/provider'
require_relative './null_provider'

#Use the null provider
Puppet::Type.type(:dependency).provide(:dependency, parent: Puppet::Provider::NullProvider) {}
