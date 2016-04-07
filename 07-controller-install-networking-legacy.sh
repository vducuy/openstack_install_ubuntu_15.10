#!/bin/bash

source admin-openrc.sh
crudini --set /etc/nova/nova.conf DEFAULT network_api_class nova.network.api.API
crudini --set /etc/nova/nova.conf DEFAULT security_group_api nova
service nova-api restart
service nova-cert restart
service nova-consoleauth restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart

#Verify nova install
source admin-openrc.sh
nova service-list
nova image-list

