source ~/keystonerc_admin

for i in 01 02 03 04 05 06 07 08 09;
do

PROJECT=project$i
USER=user$i
USER_HOME=`eval echo "~$USER"`

echo $PROJECT $USER $USER_HOME

# userXX/openstack
adduser -p 42ZTHaRqaaYvI $USER
USER_HOME=`getent passwd $USER |  cut -f6 -d:`

cp -R ~root/.ssh $USER_HOME
chown -R $USER.$USER $USER_HOME/.ssh/

IP=`hostname -I | cut -d' ' -f 1`

# create a keystone credential file for the new user
cat >> $USER_HOME/keystonerc << EOF
unset OS_SERVICE_TOKEN
export OS_USERNAME=$USER
export OS_PASSWORD=openstack
export OS_AUTH_URL=http://$IP:5000/v3
export PS1='[\u@\h \W(keystone_$USER)]\$ '

export OS_PROJECT_NAME=$PROJECT
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_IDENTITY_API_VERSION=3
EOF

# have the keystone credentials read upon login of the new user
cat >> $USER_HOME/.bashrc << EOF

# OpenStack
. ~/keystonerc
EOF



PROJECT_ID=`openstack project create $PROJECT -f value -c id`

openstack user create --password "openstack" $USER

openstack role create $USER

openstack role add --project $PROJECT --user $USER $USER
openstack role add --project $PROJECT --user $USER _member_

NETWORK_ID=`openstack network create internal --project $PROJECT_ID -f value -c id`

DNS_NAMESERVER=`grep -i nameserver /etc/resolv.conf | cut -d ' ' -f2 | head -1`
INTERNAL_SUBNET=192.168.10.0/24

SUBNET_ID=`openstack subnet create              \
        --network $NETWORK_ID                   \
        --dns-nameserver $DNS_NAMESERVER        \
        --subnet-range $INTERNAL_SUBNET         \
        --project $PROJECT_ID                   \
        $INTERNAL_SUBNET -f value -c id`


ROUTER_ID=`openstack router create --project $PROJECT_ID router -f value -c id`
openstack router add subnet $ROUTER_ID $SUBNET_ID

PUBLIC_NETWORK_ID=`openstack network show public -f value -c id`
openstack router set --external-gateway $PUBLIC_NETWORK_ID $ROUTER_ID

# allow SSH and HTTP traffic in the default security group
SECURITY_GROUP=`openstack security group list --project $PROJECT -f value -c ID`

openstack security group rule create --dst-port 80 --protocol tcp --ingress $SECURITY_GROUP
openstack security group rule create --dst-port 22 --protocol tcp --ingress $SECURITY_GROUP

done







