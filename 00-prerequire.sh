#!/bin/sh

apt-get install chrony
service chrony restart
chronyc sources

#Enable the OpenStack repository
apt-get install software-properties-common
add-apt-repository cloud-archive:liberty

#Finalize the installation
apt-get update && apt-get dist-upgrade

#Install the OpenStack client:
apt-get install python-openstackclient


apt-get install mariadb-server python-pymysql

