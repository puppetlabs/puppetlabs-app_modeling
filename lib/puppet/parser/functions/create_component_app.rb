# Creates an instance of an application. Treats 'components' param as special and maps nodes to components.
#
# create_component_app($app_name, $instance_name, $params_and_components)
#
# create_component_app('wordpress::app', 'my_wordpress',
#   {'db_password' => 'secret',
#    'components' => {
#      'Wordpress_app::database' => ['node1.example.com'],
#      'Wordpress_app::web' => ['node2.example.com', node3.example.com']}})
#
#
# @param app_name The application to create an instance of
# @param instance_name The title of to the application instance to declare
# @param params The params to create the application with. Expects a components hash that maps components to node names.
module Puppet::Parser::Functions
  newfunction(:create_component_app, arity: 3) do |args|
    app_name, instance_name, params = args

    # TODO: Should we also accept nodes?
    nodes = {}
    components = params['components']
    components.each do |comp_name, node_names|
      node_names.each do |node_name|
        comp = Puppet::Resource.new(nil, "#{comp_name}[#{instance_name}-#{node_name}]", {})
        nodes[node_name] = (nodes[node_name] || []) << comp
      end
    end

    params.delete('components')
    params['nodes'] = {}
    nodes.each do |node_name, comps|
      node = Puppet::Resource.new(nil, "Node[#{node_name}]", {})
      params['nodes'][node] = comps
    end

    function_create_resources([app_name, {instance_name => params}])
  end
end
