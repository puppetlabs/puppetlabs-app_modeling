# This is intended to use with the create_node_order function
# It takes a node order which is an array of node name arrays.
# nodes in each each array will depend on nodes in the previous array
# Must have a component of App_modeling::Dependency["$name::$certname"]
# assigned to each node.
application app_modeling::node_order(
  $order,
) {
  $order.reduce([]) |$deps, $current| {
    app_modeling::wrap_array($current).map |$nod| {
      $capre = Dependency["${name}-${nod}"]
      app_modeling::dependency{"${name}-${nod}":
        export  => $capre,
        consume => $deps,
      }
      $capre
    }
  }
}
