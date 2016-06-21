# app_modeling

#### Table of Contents

1. [Description](#description)
1. [Usage - Example uses of the module](#usage)
1. [Reference - Parameter and arguments](#reference)

## Description

This module contains a collection of puppet extenstions helpful for modeling
cross node applications in puppet code. These include a set of types and
providers for common capability resources and functions useful for defining
dynamic applications.

## Usage

### Capability resources

There are two capability resource types included in the module `http` and
`database`. They can be used to produce and consume resource in application
components. You could use these to create an application component for a web
server that consumes a database and produces an http resource like in the
following example:

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
  # puppet code to set up this component
}
```

### Dynamic Application Functions

This module also includes some functions that can make it easier to write dynamic applications where some components are defined in the declaration. For example sometimes components are optional or there may be a variable number of them. In these cases you can use `collect_component_titles` to find whether a component exists in this instance and create it.

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

The http type allows

##### Parameters

* host - The hostname the resource is available on (default: '127.0.0.1')
* port - The port to the resource is aviable on (default: '80')
* ip - the ip adress of the resource

##### Providers

*`tcp` - This provider attempts to make a tcp connection to the port.
*** To add?
* http - Verify the `health_chech` page returns a 200 status code.

#### `database`

* datbase - the name of the database
* host - the host the database is available at (default: '127.0.0.1')
* port - the port the databse is available at (defualt: '5432')
* user - the user to connect to the database as
* password - the password to connect to the database with
* database - the name of the database to connect to.
* instance - the instnace of the datbase to connect to.
* timeout - The timeout to use when attempting to check the database(default: 60)
* ping_interval - How long to wait before retrying a connection(default: 1)

##### Providers

* `tcp` - This provider attempts to make a tcp connection to the port.
* `postgres` - This will connect to a postgres database.

### Functions

#### `collect_component_titles`

Searches an applications node hash for all components of a given type and returns an array of their titles.

```
collect_component_titles($nodes, Wordpress_app::Web)
```

#### `collect_component_nodes`

Searches an applications node hash for all nodes that have a given component assigned to them and returns an array of the nodes titles.

```
collect_component_nodes($nodes, Wordpress_app::Web)
```
