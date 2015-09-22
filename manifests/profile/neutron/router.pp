# The profile to set up a neutron ovs network router
class openstack::profile::neutron::router {
  ::sysctl::value { 'net.ipv4.ip_forward':
    value     => '1',
  }

  $controller_management_address = $::openstack::config::controller_address_management

  include ::openstack::common::neutron

  if ('linuxbridge' in $::openstack::config::neutron_mechanism_drivers) {
    include ::openstack::common::ml2::linuxbridge
    $external_network_bridge = ''
    $interface_driver = 'neutron.agent.linux.interface.BridgeInterfaceDriver'
  } else {
    include ::openstack::common::ml2::ovs
    $external_network_bridge = 'brex'
    $interface_driver = 'neutron.agent.linux.interface.OVSInterfaceDriver'
  }


  ### Router service installation
  class { '::neutron::agents::l3':
    debug                   => $::openstack::config::debug,
    external_network_bridge => $external_network_bridge,
    interface_driver        => $interface_driver,
    enabled                 => true,
  }

  class { '::neutron::agents::dhcp':
    debug            => $::openstack::config::debug,
    interface_driver => $interface_driver,
    enabled          => true,
  }

  class { '::neutron::agents::metadata':
    auth_password => $::openstack::config::neutron_password,
    shared_secret => $::openstack::config::neutron_shared_secret,
    auth_url      => "http://${controller_management_address}:35357/v2.0",
    debug         => $::openstack::config::debug,
    auth_region   => $::openstack::config::region,
    metadata_ip   => $controller_management_address,
    enabled       => true,
  }

  class { '::neutron::agents::lbaas':
    debug            => $::openstack::config::debug,
    interface_driver => $interface_driver,
    enabled          => true,
  }

  class { '::neutron::agents::vpnaas':
    interface_driver => $interface_driver,
    enabled          => true,
  }

  class { '::neutron::agents::metering':
    interface_driver => $interface_driver,
    enabled          => true,
  }

  class { '::neutron::services::fwaas':
    enabled => true,
  }

  if ('ovs' in $::openstack::config::neutron_mechanism_drivers) {
    $external_network = $::openstack::config::network_external
    $external_device = device_for_network($external_network)
    vs_bridge { $external_network_bridge:
      ensure => present,
    }
     if $external_device != $external_network_bridge {
      vs_port { $external_device:
        ensure => present,
        bridge => $external_network_bridge,
      }
    } else {
      # External bridge already has the external device's IP, thus the external
      # device has already been linked
    }

    $defaults = { 'ensure' => 'present' }
    create_resources('neutron_network', $::openstack::config::networks, $defaults)
    create_resources('neutron_subnet', $::openstack::config::subnets, $defaults)
    create_resources('neutron_router', $::openstack::config::routers, $defaults)
    create_resources('neutron_router_interface', $::openstack::config::router_interfaces, $defaults)
  }

}
