#!/bin/bash

function checkAndInstallJdk() {
    sudo apt update

    dpkg -s openjdk-11-jdk
    JDK_FOUND=$?
    if [ $JDK_FOUND -ne 0 ] 
    then
        echo "installing jdk11..."
        sudo apt install -y openjdk-11-jdk
    else 
        echo "jdk11 already found on the machine, so skipping installation..."
    fi    
}

function setupTomcat() {
    if [ -d /u01/data/apache-tomcat-9.0.46 ]   
    then
        echo "found tomcat server installation, so skipping..."
        return 1
    else
        sudo mkdir -p /u01/data
        sudo chown -R vagrant:vagrant /u01/
        sudo chmod -R 755 /u01        
        wget https://apachemirror.wuchna.com/tomcat/tomcat-9/v9.0.46/bin/apache-tomcat-9.0.46.tar.gz -P /u01/data
        cd /u01/data
        gunzip apache-tomcat-9.0.46.tar.gz
        tar -xvf apache-tomcat-9.0.46.tar
        rm apache-tomcat-9.0.46.tar
        sudo chown -R vagrant:vagrant /u01/data
        sudo chmod -R 755 /u01/data        
        echo "apache tomcat server installed"
        return 0
    fi
}

function configureTomcatService() {
    sudo cp /tmp/tomcat.service.template /etc/systemd/system/tomcat.service
    sudo systemctl daemon-reload
    sudo systemctl restart tomcat
}

checkAndInstallJdk
setupTomcat
TOMCAT_INSTALLATION_STATUS=$?
if [ $TOMCAT_INSTALLATION_STATUS -eq 0 ]
then
    echo "tomcat server is installed, configuring it as an ubuntu service"
    #configureTomcatService
fi






