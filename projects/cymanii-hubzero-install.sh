#!/bin/bash

#Install script for CYMANII HUBzero CMS

#Define ANSI color codes
red="\e[0;91m"
blue="\e[0;94m"
reset="\e[0m"

#Ensure root
if [ "$EUID" -ne 0 ];
	then echo -e "${red}ERROR: Script must be run as root${reset}"
	exit
fi


#Start Installation
echo -e "\n${blue}CYMANII HUBzero Installer${reset}\n"
echo -e "${blue}Starting installation process...${reset}\n"


#Firewall
echo -e "${blue}Removing default CentOS firewall...${reset}"
yum remove -y firewalld

echo -e "${blue}Installing/configuring HUBzero IP tables...${reset}"
yum install -y hubzero-iptables-basic
service hubzero-iptables-basic start
chkconfig hubzero-iptables-basic on

echo -e "${blue}Installing/configuring HUBzero tool infrastructure...${reset}"
yum install -y hubzero-mw2-iptables-basic
service hubzero-mw2-iptables-basic start
chkconfig hubzero-mw2-iptables-basic on


#Web Server
echo -e "${blue}Installing/configuring Apache httpd web server...${reset}"
yum install -y hubzero-apache2
service httpd start
chkconfig httpd on


#PHP and Related Dependencies
echo -e "${blue}Installing/configuring PHP interpreter and related dependencies...${reset}"
rpm -Uvh https://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum install -y hubzero-php56-remi
service php56-php-fpm start
chkconfig php56-php-fpm on


#MariaDB
echo -e "${blue}Creating MariaDB configuration file...${reset}"
touch /etc/yum.repos.d/mariadb-5.5.repo
echo -e "# MariaDB 5.5 CentOS repository list" >> /etc/yum.repos.d/mariadb-5.5.repo
echo -e "# http://downloads.mariadb.org/mariadb/repositories/" >> /etc/yum.repos.d/mariadb-5.5.repo
echo -e "[mariadb]" >> /etc/yum.repos.d/mariadb-5.5.repo
echo -e "baseurl = http://yum.mariadb.org/5.5/centos7-amd64" >> /etc/yum.repos.d/mariadb-5.5.repo
echo -e "gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB" >> /etc/yum.repos.d/mariadb-5.5.repo
echo -e "gpgcheck=1" >> /etc/yum.repos.d/mariadb-5.5.repo

echo -e "${blue}Installing/configuring MariaDB...${reset}"
yum install -y MariaDB-server
service mysql start
chkconfig mysql on


#Mail server
echo -e "${blue}Installing/configuring Postfix mail server...${reset}"
yum install -y postfix
service postfix start
chkconfig postfix on
postfix check

#HUBzero CMS
echo -e "${blue}Installing main HUBzero CMS and related dependencies...${reset}"
yum install -y hubzero-cms-2.2
yum install -y hubzero-texvc
yum install -y hubzero-textifier
yum install -y wkhtmltopdf

echo -e "${blue}Configuring main HUBzero with ${$1} as selected name...${reset}"
hzcms install $1
echo -e "${blue}***MAKE SURE TO SAVE THE ABOVE CREDENTIALS***${reset}"
hzcms update


#SSL (not configured yet)

#SOLR Search
echo -e "${blue}Installing SOLR Search...${reset}"
yum install -y hubzero-solr

#Mailgateway
echo -e "${blue}Installing/configuring Mailgateway...${reset}"
yum install -y hubzero-mailgateway
hzcms configure mailgateway --enable

#Submit Server
echo -e "${blue}Installing/configuring Submit Server and related dependencies...${reset}"
yum install -y hubzero-submit-pegasus
yum install -y hubzero-submit-condor
yum install -y hubzero-submit-common
yum install -y hubzero-submit-server
yum install -y hubzero-submit-distributor
yum install -y hubzero-submit-monitors
hzcms configure submit-server --enable
service submit-server start
chkconfig submit-server on

#Done
echo -e "${blue}Installation complete! Please check for errors in the output to ensure everything is configured correctly.${reset}"
