#!/bin/bash
#Create the public network
source admin-openrc.sh
openstack flavor list
openstack image list
openstack network list
openstack security group list

echo -n "Copy Provider network ID > "
read PROVIDER_NET_ID
openstack server create --flavor m1.tiny --image cirros --nic net-id=$PROVIDER_NET_ID --security-group default --key-name mykey provider-instance


openstack server list

