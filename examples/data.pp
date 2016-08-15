define data_app::producer (
  $base_data,
) { }


define data_app::consumer (
  $data,
) {
  notify { "Consumer passed data: ${data}": }
}

application data_app(
  $base_data = {} )
{
  data_app::producer {"${name}":
    base_data => $base_data,
    export    => Data_capability['produced-data'],
  }

  data_app::consumer {"${name}":
    consume => Data_capability['produced-data'],
  }
}

site {

  # In addition add the fqdn of the producer node to the data before exporting it.
  Data_app::Producer produces Data_capability {
    data => $base_data + { 'producer_node' => $::fqdn }
  }

  Data_app::Consumer consumes Data_capability { }

  data_app {'all-in-one':
    nodes => {
      Node['node1.example.com'] => [Data_app::Producer['all-in-one'],
                                    Data_app::Consumer['all-in-one'],]
    }
  }
  data_app {'example':
    nodes => {
      Node['node1.example.com'] => Data_app::Producer['example'],
      Node['node2.example.com'] => Data_app::Consumer['example'],
    }
  }
}
