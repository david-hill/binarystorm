#!/bin/bash

ifconfig eth0 | grep inet | grep -q 158.69.192.170
if [ $? -eq 0 ]; then
  sed -i 's/hostname: .*/hostname: dns1.binarystorm.net/' /etc/cloud/cloud.cfg
  hostnamectl set-hostname dns1.binarystorm.net
else
  sed -i 's/hostname: .*/hostname: dns2.binarystorm.net/' /etc/cloud/cloud.cfg
  hostnamectl set-hostname dns2.binarystorm.net
fi

yum install -y postfix bind cyrus-imapd cyrus-sasl vim bind-utils telnet httpd ntp wget net-snmp net-snmp-utils squirrelmail
systemctl enable cyrus-imapd
systemctl enable httpd
systemctl enable postfix
systemctl enable saslauthd
systemctl enable ntpd
systemctl enable named
systemctl enable snmpd
systemctl start cyrus-imapd
systemctl start httpd
systemctl start postfix
systemctl start saslauthd
systemctl start ntpd
systemctl start named
systemctl start snmpd

saslpasswd2 -c cyrus
passwd cyrus

cyradm -u cyrus localhost 
# cm user.dhill

firewall-cmd --permanent --zone=public --add-port=25/tcp
firewall-cmd --permanent --zone=public --add-port=53/tcp
firewall-cmd --permanent --zone=public --add-port=53/udp
firewall-cmd --permanent --zone=public --add-port=80/tcp
firewall-cmd --permanent --zone=public --add-port=110/tcp
firewall-cmd --reload

wget https://copr-be.cloud.fedoraproject.org/results/vrusinov/vrusinov/epel-7-x86_64/uptimed-0.4.0-1.fc21/uptimed-0.4.0-1.el7.centos.x86_64.rpm
rpm -i uptimed*
systemctl enable uptimed
systemctl start uptimed
