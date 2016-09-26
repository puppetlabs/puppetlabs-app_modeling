# app_modeling

#### Table of contents

1. [Description](#description)
1. [Usage - Example uses of the module](#usage)
1. [Reference - Parameter and arguments](#reference)

## Description

This module contains a collection of Puppet extensions for modeling cross-node applications in Puppet code. Included is a set of types and providers for common capability resources and two functions useful for defining dynamic applications.

## Usage

### Capability resources

This module contains two capability resource types: `http` and `database`. You can use these resource types to *produce* and *consume* resources in application components.

For example, the following code sample shows how you could use this module to create an application component for a web server that consumes a `database` resource and produces an `http` resource.

```puppet
Wordpress_app::Web consumes Database{
  db_host     => $host,
  db_name     => $database,
  db_user     => $user,
  db_password => $password,
}
Wordpress_app::Web produces Http {
  ip   => $interface ? { /\S+/ => $::networking['interfaces'][$interface]['ip'], default => $::ipaddress },
  port => $web_port,
  host => $::hostname,
}
define wordpress_app::web(
  String $db_host,
  String $db_name,
  String $db_user,
  String $db_password,
  String $web_port = '8080',
) {
  # Puppet code to set up this component
}
```

### Dynamic application functions

The functions included in this module make it easier to write dynamic applications where some components are defined in the declaration. For example, you can use the `collect_component_titles` function to determine if a component exists and, if it doesn't, the function will create it.

```puppet
# Create an lb component for each declared load balancer.
$lb_components = collect_component_titles($nodes, Wordpress_app::Lb)
$lb_components.each |$comp_name| {
  wordpress_app::lb { $comp_name:
    balancermembers => $web_https,
    lb_options      => $lb_options,
    ipaddress       => $lb_ipaddress,
    port            => $lb_port,
    balance_mode    => $lb_balance_mode,
    require         => $web_https,
    export          => Http["lb-${name}"],
  }
}
```

## Reference

### Types

#### `data_capability`

The `data_capability` type accepts a single parameter that can be used to pass arbitrary data to other other nodes. There is no availability check. This is useful if you need to pass data between components but don't care if services are running. See [examples/data.pp](https://github.com/puppetlabs/puppetlabs-app_modeling/blob/master/examples/data.pp).

##### Parameters

* `data`: Arbitrary data to produce or consume component information. Usually this should be a hash.

#### `dependency`

The `dependency` type passes no information between nodes and has no availabilty check. This type is useful if you only care about node run order.

#### `http`

The `http` type allows the following parameters and providers:

##### Parameters

* `ip`: The external IP address of the HTTP service (default: `127.0.0.1`).
* `host`: The hostname of the node where the resource is available (default: `127.0.0.1`).
* `base_path`: The base path the resource is mounted at (default: `\`).
* `port`: The port where the resource is available (default: `80`).
* `ssl`: Set to true if the HTTP service uses SSL encryption (default: `false`).
* `timeout`: Time before timing out the resource in seconds (default: `60`).
* `ping_interval`: Time between retries in seconds (default: `1`).
* `status_codes`: An array of HTTP status codes that will return success (default: `[200]`).

##### Providers

* `tcp`: This provider attempts to make a TCP connection to the port where the resource is available.

#### `database`

The `database` type allows the following parameters and providers:

##### Parameters

* `database`: The name of the database to connect to.
* `host`: The hostname of the node where the database is available (default: `127.0.0.1`).
* `port`:  The port where the database is available (default: `5432`).
* `user`: The user that connects to the database.
* `password`: The password used to connect to the database.
* `instance`: The instance of the database to connect to.
* `timeout`: The timeout, in seconds, to use when attempting to check the database (default: `60`).
* `ping_interval`: How long to wait before retrying a connection (default: 1).

##### Providers

* `tcp` - This provider attempts to make a TCP connection to the port.
* `postgres` - This provider connects to a PostgreSQL database.

### Functions

#### `collect_component_titles`

This function searches the node hash of an application for all components of a given type and returns an array of their titles.

```
collect_component_titles($nodes, Wordpress_app::Web)
```

#### `collect_component_nodes`

This function searches the node hash of an application for all nodes that have a given component assigned to them and returns an array of nodes titles.

```
collect_component_nodes($nodes, Wordpress_app::Web)
```

#### `create_component_app`

This function is similiar to normal application declaration syntax, but instead of mapping nodes to component instances, this function maps components to nodes. This makes it easier to use applications defined with `collect_component_titles` if the same components are assigned to many nodes for availability or scale. For example, the following example site blocks create equivalent application declarations:

```puppet
site {
  create_component_app('wordpress::app', 'my_wordpress',
    {'db_password' => 'secret',
     'components' => {
       # These component names must be quoted if defined in puppet code so they parse as strings.
       'Wordpress_app::Database' => ['node1.example.com'],
       'Wordpress_app::Web' => ['node2.example.com', 'node3.example.com', 'node4.example.com'],
       'Wordpress_app::Lb' => ['node4.example.com']
      }
    })
}

site {
  wordpress::app { 'my_wordpress:
    db_password => 'secret',
    nodes => {
      Node['node1.example.com'] => Wordpress_app::Database['my_wordpress-node1.example.com'],
      Node[node2.example.com'] => Wordpress_app::Web['my_wordpress-node2.example.com'],
      Node[node3.example.com'] => Wordpress_app::Web['my_wordpress-node3.example.com'],
      Node[node4.example.com'] => [Wordpress_app::Web['my_wordpress-node4.example.com'],
                                   Wordpress_app::Lb['my_wordpress-node4.example.com']],
    }
  }
}
```

The component instances created are given titles `"${app_instance_name}-${node_name}"`. This works well if the application definition uses `collect_component_titles` to declare components.

#### `create_node_order`

This function can be used in site blocks for applications in which the assigned nodes must run in order. This function accepts a title for the application and a list of node layers. It then creates an instance of `app_modeling::node_order` where the nodes at each layer depend on all the nodes in the previous layer.

The following example creates a dependency between two nodes. Whenever an orchestrator job is run on these nodes, `node1` will always run before `node2`. You can run an orchestrator job on these nodes with `puppet job run --application App_modeling::Node_order['node1-node2']`.

```puppet
site {
  create_node_order('node1-node2', ['node1.example.com', 'node2.example.com'])
}
```

The following example shows a node run order for a three-layer web application (a database, some application servers, and a load balancer).  You can run an orchestrator job to deploy this application with `puppet job run --application App_modeling::Node_order['three_tier']`.

```puppet
site {
  create_node_order('three_tier', ['database.example.com', ['web1.example.com','web2.example.com','web3.example.com'], 'lb.example.com'])
}
```

##### Parameters

* `title` - The title of the application to create.
* `nodes` - An array of node layers to order. A node layer can consist of a single node name or an array of node names.
