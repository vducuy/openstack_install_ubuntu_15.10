#!/bin/bash

#Dashboard install
apt-get install openstack-dashboard -y
#Edit the /etc/openstack-dashboard/local_settings.py file and complete the following actions:
sed -i 's/OPENSTACK_HOST = "127.0.0.1"/OPENSTACK_HOST = "controller"/g' /etc/openstack-dashboard/local_settings.py
sed -i 's/OPENSTACK_KEYSTONE_DEFAULT_ROLE = "_member_"/OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"/g' /etc/openstack-dashboard/local_settings.py
sed -i '675d' /etc/openstack-dashboard/local_settings.py
echo "ALLOWED_HOSTS = ['*', ]" >> /etc/openstack-dashboard/local_settings.py
service apache2 reload
#Restart Controller+network
source admin-openrc.sh
nova service-list
neutron agent-list

