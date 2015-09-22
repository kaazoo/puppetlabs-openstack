# Private class
# Set up the linuxbridge agent
class openstack::common::ml2::linuxbridge {

  file { '/etc/neutron/plugins/linuxbridge':
    ensure => directory,
    alias  => 'linuxbridge-confdir',
  }

  file { '/etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini':
    ensure  => link,
    target  => '/etc/neutron/plugin.ini',
    require => File['linuxbridge-confdir'],
    alias   => 'linuxbridge-conffile',
  }

  class { '::neutron::agents::ml2::linuxbridge':
    physical_interface_mappings => $::openstack::config::neutron_physical_interface_mappings,
    require                     => File['linuxbridge-conffile'],
  }
}

