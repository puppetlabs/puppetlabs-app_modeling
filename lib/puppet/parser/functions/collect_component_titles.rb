# Given a nodes hash and a component type collects the title of all
# coponents of that type in the application.
#
# @return [Array[String]] The titles of all matching components
#
# @param nodes [Hash] an applications $nodes hash
# @param component [Type] the component type to match
module Puppet::Parser::Functions
  newfunction(:collect_component_titles, type: :rvalue) do |args|
    nodes = args[0]
    component = args[1]
    raise Puppet::ParseError, "collect_component_titles requires a nodes hash and component" unless nodes && component

    target = component.type
    nodes.map do |_, components|
      components = [components] unless components.kind_of?(Array)
      components = components.select {|comp| comp.type == target}
      components.map {|comp| comp.title}
    end.flatten
  end
end
