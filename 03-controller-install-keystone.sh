#!/bin/bash
#Install Message Queue Install and configure components
apt-get install rabbitmq-server -y
rabbitmqctl add_user openstack RABBIT_PASS
rabbitmqctl set_permissions openstack ".*" ".*" ".*"
#Install the identity
#Prerequisites
mysql -u root --password=stack <<MYSQL_SCRIPT
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'KEYSTONE_DBPASS';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'KEYSTONE_DBPASS';
MYSQL_SCRIPT
#Generate a random value to use as the administration token during initial configuration
export ADMIN_TOKEN=$(openssl rand -hex 10)
#Disable the keystone service from starting automatically after installation
echo "manual" > /etc/init/keystone.override
#Run the following command to install the packages
apt-get install keystone apache2 libapache2-mod-wsgi \
  memcached python-memcache -y
#Edit the /etc/keystone/keystone.conf file and complete the following actions
crudini --set /etc/keystone/keystone.conf DEFAULT admin_token $ADMIN_TOKEN
crudini --set /etc/keystone/keystone.conf DEFAULT verbose True
crudini --set /etc/keystone/keystone.conf database connection mysql+pymysql://keystone:KEYSTONE_DBPASS@controller/keystone
crudini --set /etc/keystone/keystone.conf memcache servers localhost:11211
crudini --set /etc/keystone/keystone.conf token provider uuid
crudini --set /etc/keystone/keystone.conf token driver memcache
crudini --set /etc/keystone/keystone.conf revoke driver sql
#Populate the Identity service database:
su -s /bin/sh -c "keystone-manage db_sync" keystone
#Configure the Apache HTTP server
sed -i '14 a ServerName controller' /etc/apache2/apache2.conf
cp wsgi-keystone.conf /etc/apache2/sites-available/wsgi-keystone.conf
#Enable the Identity service virtual hosts
ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled
#Finalize the installation
service apache2 restart
rm -f /var/lib/keystone/keystone.db

#Create Service Enty and API endpoints
export OS_TOKEN=$ADMIN_TOKEN
export OS_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
#Create the service entity and API endpoints
openstack service create \
  --name keystone --description "OpenStack Identity" identity
openstack endpoint create --region RegionOne \
  identity public http://controller:5000/v2.0
openstack endpoint create --region RegionOne \
  identity internal http://controller:5000/v2.0
openstack endpoint create --region RegionOne \
  identity admin http://controller:35357/v2.0
#Create projects, users and roles
openstack project create --domain default \
  --description "Admin Project" admin
openstack user create --domain default \
  --password ADMIN_PASS admin
openstack role create admin
openstack role add --project admin --user admin admin
openstack project create --domain default \
  --description "Service Project" service
openstack project create --domain default \
  --description "Demo Project" demo
openstack user create --domain default \
  --password DEMO_PASS demo
openstack role create user
openstack role add --project demo --user demo user
#Verify Operation
#For security reasons, disable the temporary authentication token mechanism.Unset the temporary OS_TOKEN and OS_URL environment variables
unset OS_TOKEN OS_URL
sed -i 's/sizelimit url_normalize request_id build_auth_context token_auth admin_token_auth json_body ec2_extension user_crud_extension public_service/sizelimit url_normalize request_id build_auth_context token_auth json_body ec2_extension user_crud_extension public_service/g' /etc/keystone/keystone-paste.ini
sed -i 's/sizelimit url_normalize request_id build_auth_context token_auth admin_token_auth json_body ec2_extension s3_extension crud_extension admin_service/sizelimit url_normalize request_id build_auth_context token_auth json_body ec2_extension s3_extension crud_extension admin_service/g' /etc/keystone/keystone-paste.ini

sed -i 's/sizelimit url_normalize request_id build_auth_context token_auth admin_token_auth json_body ec2_extension_v3 s3_extension simple_cert_extension revoke_extension federation_extension oauth1_extension endpoint_filter_extension service_v3/sizelimit url_normalize request_id build_auth_context token_auth json_body ec2_extension_v3 s3_extension simple_cert_extension revoke_extension federation_extension oauth1_extension endpoint_filter_extension service_v3/g' /etc/keystone/keystone-paste.ini
#Actually test
openstack --os-auth-url http://controller:35357/v3 \
  --os-project-domain-id default --os-user-domain-id default \
  --os-project-name admin --os-username admin --os-password ADMIN_PASS\
  token issue
openstack --os-auth-url http://controller:5000/v3 \
  --os-project-domain-id default --os-user-domain-id default \
  --os-project-name demo --os-username demo --os-password DEMO_PASS \
  token issue

source admin-openrc.sh
openstack token issue

