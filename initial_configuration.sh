#!/bin/bash

ifconfig eth0 | grep inet | grep -q 158.69.192.170
if [ $? -eq 0 ]; then
  sed -i 's/hostname: .*/hostname: dns1.binarystorm.net/' /etc/cloud/cloud.cfg
  hostnamectl set-hostname dns1.binarystorm.net
else
  sed -i 's/hostname: .*/hostname: dns2.binarystorm.net/' /etc/cloud/cloud.cfg
  hostnamectl set-hostname dns2.binarystorm.net
fi

yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y postfix bind cyrus-imapd cyrus-sasl vim bind-utils telnet httpd ntp wget net-snmp net-snmp-utils squirrelmail mod_ssl uptimed yum-utils selinux-policy-devel
systemctl enable cyrus-imapd
systemctl enable httpd
systemctl enable postfix
systemctl enable saslauthd
systemctl enable ntpd
systemctl enable named
systemctl enable snmpd
systemctl enable uptimed
systemctl start cyrus-imapd
systemctl start httpd
systemctl start postfix
systemctl start saslauthd
systemctl start ntpd
systemctl start named
systemctl start snmpd
systemctl start uptimed

saslpasswd2 -c cyrus
passwd cyrus

cyradm -u cyrus localhost 
# cm user.dhill

firewall-cmd --permanent --zone=public --add-port=25/tcp
firewall-cmd --permanent --zone=public --add-port=53/tcp
firewall-cmd --permanent --zone=public --add-port=53/udp
firewall-cmd --permanent --zone=public --add-port=80/tcp
firewall-cmd --permanent --zone=public --add-port=110/tcp
firewall-cmd --permanent --zone=public --add-port=143/tcp
firewall-cmd --permanent --zone=public --add-port=143/udp
firewall-cmd --permanent --zone=public --add-port=443/tcp
firewall-cmd --permanent --zone=public --add-port=993/tcp
firewall-cmd --permanent --zone=public --add-port=995/tcp
firewall-cmd --reload



if [[ "$HOSTNAME" =~ dns1 ]]; then
  cp postfix/* /etc/postfix 
  cp httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf
  cp httpd/conf.d/* /etc/httpd/conf.d/
  cp squirrelmail/* /etc/squirrelmail/
  systemctl restart httpd
  cp cyrus/imapd.conf /etc
  cp cyrus/cyrus.conf /etc
  systemctl restart cyrus-imapd
elif [[ "$HOSTNAME" =~ dns2 ]]; then
  cp postfix/backup_mx/* /etc/postfix 
fi
if [ -e /etc/postfix/virtual ]; then
  postmap /etc/postfix/virtual
elif [ -e /etc/postfix/transport ]; then
  postmap /etc/postfix/transport
fi
systemctl restart postfix


cp named/named.conf /etc/named
if [ ! -d /etc/named/named ]; then
  mkdir -p /etc/named/named
fi
cp named/named/* /etc/named/named
systemctl restart named

cp snmp/snmpd.conf /etc/snmp/snmpd.conf
systemctl restart snmpd

cp ssh/authorized_keys /root/.ssh
chmod 600 /root/.ssh/authorized_keys

cp selinux/* /usr/share/selinux/devel
modules=$(find /usr/share/selinux/devel -name \*.pp)
for module in $(modules); do
  semodule -i $module
done
