#!/bin/bash

#Add the compute service
#Prerequisites
mysql -u root --password=amcc1234 <<MYSQL_SCRIPT
CREATE DATABASE nova;
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'amcc1234';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'amcc1234';
MYSQL_SCRIPT
source admin-openrc.sh
#Create the service credentials, complete these steps:
openstack user create --domain default --password amcc1234 nova
openstack role add --project service --user nova admin
openstack service create --name nova \
  --description "OpenStack Compute" compute
openstack endpoint create --region RegionOne \
  compute public http://controller:8774/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne \
  compute internal http://controller:8774/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne \
  compute admin http://controller:8774/v2/%\(tenant_id\)s
#Install and configure components
apt-get install nova-api nova-cert nova-conductor \
  nova-consoleauth nova-novncproxy nova-scheduler \
  python-novaclient -y
#Edit the /etc/nova/nova.conf file and complete the following actions
crudini --set /etc/nova/nova.conf database connection mysql+pymysql://nova:amcc1234@controller/nova
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
crudini --set /etc/nova/nova.conf DEFAULT my_ip 192.168.0.11
crudini --set /etc/nova/nova.conf DEFAULT linuxnet_interface_driver nova.network.linux_net.NeutronLinuxBridgeInterfaceDriver
crudini --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
crudini --set /etc/nova/nova.conf vnc enabled False
crudini --set /etc/nova/nova.conf vnc vncserver_listen 192.168.0.11
crudini --set /etc/nova/nova.conf vnc vncserver_proxyclient_address 192.168.0.11
crudini --set /etc/nova/nova.conf glance host controller
crudini --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
crudini --set /etc/nova/nova.conf DEFAULT enabled_apis osapi_compute,metadata
crudini --set /etc/nova/nova.conf DEFAULT verbose True
#Restart nova services
su -s /bin/sh -c "nova-manage db sync" nova
service nova-api restart
service nova-cert restart
service nova-consoleauth restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart
rm -f /var/lib/nova/nova.sqlite

#Verify nova install
source admin-openrc.sh
nova service-list
nova image-list

