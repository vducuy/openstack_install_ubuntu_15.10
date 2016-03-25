#!/bin/sh

apt-get install -y chrony
service chrony restart
chronyc sources

#Enable the OpenStack repository
apt-get install -y software-properties-common
add-apt-repository cloud-archive:liberty

#Finalize the installation
apt-get update && apt-get dist-upgrade

#Install the OpenStack client:
apt-get install -y python-openstackclient


apt-get install -y mariadb-server python-pymysql

