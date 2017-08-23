

## Overview



## Amazon EC2



## OpenStack Nova

https://www.serfish.com/console/ajaxterm.html?ip=147.75.83.202&user=admin&port=22


## Amazon EC2 Walk Through

Log into the AWS EC2 console at:

* https://console.aws.amazon.com/ec2

### Launch Instance
Click the "Launch Instance" button
Click the "Select" Amazon Linux button
Review the Instance and EBS storage options



## OpenStack Nova Walkthough

Log into the OpenStack Horizon web dashboard and proceed to the compute page.

* Project->Compute->Instance

### Launch Instance
Click the "Launch Instance" button
* Instance Name: web
* Source: CirrosWeb
* Flavor: a1.tiny (Review the other available flavors)
* Launch

### Log In
* Click "Associate Floating IP" and allocate/add an external IP address
* Run PuTTY/SSH and login to assigned floating IP as admin/openstack

### Utilize the ephemeral disk
* Become superuser (root)
* Examine disks
* Mount the ephemeral disk

```
sudo su -
fdisk -l
mkdir /var/www/
mkfs -t ext4 -L www /dev/vdb
blkid
mount /dev/vdb /var/www/
df
ls /var/www
echo "hello world" > /var/www/index.html
cat /var/www/index.html

## Wrap Up

Once you're done, return back to the <A HREF="../master/README.md">main page</A> for the next type of storage!
