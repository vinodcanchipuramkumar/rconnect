#!/bin/bash
sudo apt update -y

function checkAndInstallMySQLServer() {
    dpkg -s mysql-server-8.0
    local MYSQL_FOUND=$?
    echo "MYSQL_FOUND : $MYSQL_FOUND"
    if [ $MYSQL_FOUND -ne 0 ] 
    then
        sudo apt install -y debconf-utils
        export DEBAIN_FRONTEND="noninteractive"
        echo "mysql-server-8.0 mysql-server/root_password password root" | sudo debconf-set-selections
        echo "mysql-server-8.0 mysql-server/root_password_again password root" | sudo debconf-set-selections
        sudo apt install -y mysql-server-8.0
        return $?
    else
        echo "mysql server installation already found, so skipping..."
        return 1
    fi   
}

function secureMySqlServerInstallation() {
    echo "running mysql_secure_installation"
    sudo apt install -y expect
    SECURE_MYSQL=$(expect -c '
        set timeout -1
        spawn sudo mysql_secure_installation

        expect "Enter password for user root:"
        send "root\r"

        expect "Press y|Y for Yes, any other key for No:"
        send "No\r"

        expect "Change the password for root ? ((Press y|Y for Yes, any other key for No) :"
        send "No\r"

        expect "Remove anonymous users? (Press y|Y for Yes, any other key for No) :"
        send "Y\r"

        expect "Disallow root login remotely? (Press y|Y for Yes, any other key for No) :"
        send "No\r"

        expect "Remove test database and access to it? (Press y|Y for Yes, any other key for No) :"
        send "Y\r"

        expect "Reload privilege tables now? (Press y|Y for Yes, any other key for No) :"
        send "Y\r"
        expect eof  
    ')
    echo $SECURE_MYSQL
}

function bindMySqlServerToGlobalIp() {
    sudo sed -i 's/^bind-address.*=.*/bind-address=0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
}

function grantRemoteAccessToRailUser() {
    sudo mysql -uroot -proot -e "create user 'railuser'@'%' identified by 'welcome1'"
    sudo mysql -uroot -proot -e "grant all privileges on *.* to 'railuser'@'%'"
    sudo mysql -uroot -proot -e "flush privileges"
}

checkAndInstallMySQLServer
MYSQL_INSTALL_STATUS=$?
echo "MYSQL INSTALLATION STATUS : $MYSQL_INSTALL_STATUS"
if [ $MYSQL_INSTALL_STATUS -eq 0 ]
then  
    secureMySqlServerInstallation
    bindMySqlServerToGlobalIp
    grantRemoteAccessToRailUser
    sudo systemctl restart mysql
fi








