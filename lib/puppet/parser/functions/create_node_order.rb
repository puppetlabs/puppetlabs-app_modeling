# Given an instance title and list of node names creates a node_order application for them
#
# # create_node_order('node1->node2', ['node1', 'node2']
#
# creates and node order where node1 runs before node2
#
# # create_node_order('db->web', ['database-node', ['web-node1', 'web-node2'], 'lb-node'])
#
# creates a node order where first the database will run followed by the web nodes and finally the lb
#
#
# @param app_name String the name of the node_order application to create
# @prams nodes [String | [String] A list of nodes or layers of nodes to order.
module Puppet::Parser::Functions
  newfunction(:create_node_order, arity: 2) do |args|
    app_name, order = args

    nodes = {}
    order.flatten.each do |node_name|
      node = Puppet::Resource.new(nil, "Node[#{node_name}]", {})
      comp = Puppet::Resource.new(nil, "App_modeling::Dependency[#{app_name}-#{node_name}]", {})
      # Make sure this node doesn't already appear
      if nodes.keys.any? {|n| n.title == node.title}
        raise Puppet::ParseError, "Cannot create node_order '#{app_name}' node '#{node_name}' is included twice"
      end
      nodes[node] = comp
    end
    #raise Puppet::ParseError, "nodes are: #{nodes}"
    params = {app_name => { "order" => order, "nodes" => nodes}}
    function_create_resources(["app_modeling::node_order", params])
  end
end
