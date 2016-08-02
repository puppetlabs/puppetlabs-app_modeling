# Given a nodes hash and a component type collects the title of all
# nodes with the component type assigned and returns them in an array.
#
# @return [Array[String]] All matching node titles
#
# @param nodes [Hash] an applications $nodes hash
# @param component [Type] the component type to match
module Puppet::Parser::Functions
  newfunction(:collect_component_nodes, type: :rvalue) do |args|
    nodes = args[0]
    component = args [1]
    raise Puppet::ParseError, "collect_component_nodes requires a nodes hash and component" unless nodes && component
    target = component.type
    nodes.map do |node, components|
      components = [components] unless components.kind_of?(Array)
      if components.any? {|comp| comp.type == target}
        node.title
      end
    end.compact
  end
end
