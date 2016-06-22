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

#### `http`

The `http` type allows the following parameters and providers:

##### Parameters

* `host`: The hostname of the node where the resource is available (default: `127.0.0.1`).
* `port`: The port where the resource is available (default: `80`).
* `ip`: The IP adress of the node where the resource is available.

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
