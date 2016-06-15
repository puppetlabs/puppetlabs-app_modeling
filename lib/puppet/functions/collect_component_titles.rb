# Given a nodes hash and a component type collects the title of all
# coponents of that type in the application.
#
# @return [Array[String]] The titles of all matching components
#
# @param nodes [Hash] an applications $nodes hash
# @param component [Type] the component type to match
Puppet::Functions.create_function(:collect_component_titles) do
  def collect_component_titles(nodes, component)
    target = component.type_name
    nodes.map do |_, components|
      components = [components] unless components.kind_of?(Array)
      components = components.select {|comp| comp.type == target}
      components.map {|comp| comp.title}
    end.flatten
  end
end
