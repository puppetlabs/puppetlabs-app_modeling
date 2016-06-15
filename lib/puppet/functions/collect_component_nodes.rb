# Given a nodes hash and a component type collects the title of all
# nodes with the component type assigned and returns them in an array.
#
# @return [Array[String]] All matching node titles
#
# @param nodes [Hash] an applications $nodes hash
# @param component [Type] the component type to match
Puppet::Functions.create_function(:collect_component_nodes) do
  def collect_component_nodes(nodes, component)
    target = component.type_name
    nodes.map do |node, components|
      components = [components] unless components.kind_of?(Array)
      if components.any? {|comp| comp.type == target}
        node.title
      end
    end.compact
  end
end
