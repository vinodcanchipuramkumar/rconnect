#!/bin/bash
dpkg -s mysql-server-8.0
MYSQL_FOUND=$?
if [ $MYSQL_FOUND -eq 0 ]
then
    echo "create railway reservation db schema...."
    mysql -uroot -proot < /tmp/db-schema.sql
else 
    echo "no mysql install detected, so skipping schema creation"
fi

