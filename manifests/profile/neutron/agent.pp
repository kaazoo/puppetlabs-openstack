# The profile to set up a neutron agent
class openstack::profile::neutron::agent {
  include ::openstack::common::neutron

  if ($::openstack::config::neutron_core_plugin == 'plumgrid') {
    include ::openstack::common::plumgrid
  } else {
    if ('linuxbridge' in $::openstack::config::neutron_mechanism_drivers) {
      include ::openstack::common::ml2::linuxbridge
    } else {
      include ::openstack::common::ml2::ovs
    }
  }

}
