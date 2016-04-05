!/bin/bash
echo "#Install Nova components"
apt-get install crudini -y
apt-get install nova-compute sysfsutils -y
echo "#Edit the /etc/nova/nova.conf file and complete the following actions:"
crudini --set /etc/nova/nova.conf DEFAULT rpc_backend rabbit
crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_host controller
crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_password amcc1234
crudini --set /etc/nova/nova.conf DEFAULT auth_strategy keystone
crudini --del /etc/nova/nova.conf keystone_authtoken
crudini --set /etc/nova/nova.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/nova/nova.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/nova/nova.conf keystone_authtoken auth_plugin password
crudini --set /etc/nova/nova.conf keystone_authtoken project_domain_id default
crudini --set /etc/nova/nova.conf keystone_authtoken user_domain_id default
crudini --set /etc/nova/nova.conf keystone_authtoken project_name service
crudini --set /etc/nova/nova.conf keystone_authtoken username nova
crudini --set /etc/nova/nova.conf keystone_authtoken password amcc1234
crudini --set /etc/nova/nova.conf DEFAULT my_ip 192.168.0.21
crudini --set /etc/nova/nova.conf DEFAULT network_api_class nova.network.neutronv2.api.API
crudini --set /etc/nova/nova.conf DEFAULT security_group_api neutron
crudini --set /etc/nova/nova.conf DEFAULT linuxnet_interface_driver nova.network.linux_net.NeutronLinuxBridgeInterfaceDriver
crudini --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
crudini --set /etc/nova/nova.conf vnc my_ip 192.168.0.21
crudini --set /etc/nova/nova.conf vnc vncserver_listen 0.0.0.0
crudini --set /etc/nova/nova.conf vnc vncserver_proxyclient_address 192.168.0.21
crudini --set /etc/nova/nova.conf vnc novncproxy_base_url http://controller:6080/vnc_auto.html
crudini --set /etc/nova/nova.conf glance host controller
crudini --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
crudini --set /etc/nova/nova.conf DEFAULT verbose True
echo "Finalize installation"
echo "If this command returns a value of one or greater, your compute node supports hardware acceleration which typically requires no additional configuration.
If this command returns a value of zero,
your compute node does not support hardware acceleration and
you must configure libvirt to use QEMU instead of KVM."
egrep -c '(vmx|svm)' /proc/cpuinfo
sleep 8
echo "#Edit the [libvirt] section in the /etc/nova/nova-compute.conf file as follows"
crudini --set /etc/nova/nova-compute.conf libvirt virt_type qemu
service nova-compute restart
rm -f /var/lib/nova/nova.sqlite

