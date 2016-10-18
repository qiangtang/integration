#!/bin/bash -v
#
# This file was auto-generated by gen-all-dockerfiles.sh; do not modify manually.
#
# ./gso-service-manager/init-mysql.sh
#

# Wait for mysql to initialize; Set mysql root password
echo Initializing mysql
for i in {1..10}; do
    /usr/bin/mysqladmin -u root password 'rootpass' &> /dev/null && break
    sleep $i
done
