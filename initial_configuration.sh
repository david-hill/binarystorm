#!/bin/bash

function configure_named {
  restart=0
  cmp named/named.conf /etc/named/named.conf
  if [ $? -ne 0 ]; then
    cp named/named.conf /etc/named
    restart=1
  fi
  
  if [ ! -d /etc/named/named ]; then
    mkdir -p /etc/named/named
  fi
  
  cd named/named
  for f in *.conf; do
    cmp $f /etc/named/named/$f
    if [ $? -ne 0 ]; then
      cp * /etc/named/named
      restart=1
    fi
  done
  cd ../..
  if [ $restart -eq 1 ]; then
    systemctl restart named
  fi
}

function configure_snmpd {
  cmp snmp/snmpd.conf /etc/snmp/snmpd.conf
  if [ $? -ne 0 ]; then
    cp snmp/snmpd.conf /etc/snmp/snmpd.conf
    systemctl restart snmpd
  fi
}

function enable_start {
  systemctl enable $1
  systemctl start $1
}

function add_port {
  firewall-cmd --list-all | grep " $1"
  if [ $? -ne 0 ]; then
    firewall-cmd --permanent --zone=public --add-port=$1
  fi
}

ifconfig eth0 | grep inet | grep -q 158.69.192.170
if [ $? -eq 0 ]; then
  sed -i 's/hostname: .*/hostname: dns1.binarystorm.net/' /etc/cloud/cloud.cfg
  hostnamectl set-hostname dns1.binarystorm.net
else
  sed -i 's/hostname: .*/hostname: dns2.binarystorm.net/' /etc/cloud/cloud.cfg
  hostnamectl set-hostname dns2.binarystorm.net
fi

yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y postfix bind cyrus-imapd cyrus-sasl vim bind-utils telnet httpd ntp wget net-snmp net-snmp-utils squirrelmail mod_ssl uptimed yum-utils selinux-policy-devel clamav amavisd-new clamav-scanner clamav-scanner-systemd clamav-update

yum update -y

enable_start cyrus_imapd
enable_start httpd
enable_start postfix
enable_start saslauthd
enable_start ntpd
enable_start named
enable_start snmpd
enable_start uptimed

if [ ! -e /etc/sasldb2 ]; then
  saslpasswd2 -c cyrus
  passwd cyrus
  cyradm -u cyrus localhost 
# cm user.dhill
fi

add_port 25/tcp
add_port 53/tcp
add_port 53/udp
add_port 80/tcp
add_port 110/tcp
add_port 143/tcp
add_port 143/udp
add_port 443/tcp
add_port 993/tcp
add_port 995/tcp
firewall-cmd --reload


if [[ "$HOSTNAME" =~ dns1 ]]; then
  mkdir -p /etc/postfix/keys
  cp postfix/* /etc/postfix 
  if [ ! -e /etc/postfix/keys/smtpd.key ]; then
    openssl req -newkey rsa:4096 -nodes -sha512 -x509 -days 3650 -nodes -out /etc/postfix/keys/smtpd.cert -keyout /etc/postfix/keys/smtpd.key
    openssl req -newkey rsa:4096 -nodes -sha512 -x509 -days 3650 -nodes -out /etc/pki/cyrus-imapd/cyrus-imapd.pem -keyout /etc/pki/cyrus-imapd/cyrus-imapd.pem
    openssl req -newkey rsa:4096 -nodes -sha512 -x509 -days 3650 -nodes -out /etc/httpd/keys/wildcard.crt -keyout /etc/httpd/keys/wildcard.key
  fi
  cp httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf
  cp httpd/conf.d/* /etc/httpd/conf.d/
  cp squirrelmail/* /etc/squirrelmail/
  systemctl restart httpd
  cp cyrus/imapd.conf /etc
  cp cyrus/cyrus.conf /etc
  systemctl restart cyrus-imapd
elif [[ "$HOSTNAME" =~ dns2 ]]; then
  cp postfix/master.cf /etc/postfix 
  cp postfix/backup_mx/* /etc/postfix 
fi
if [ -e /etc/postfix/virtual ]; then
  postmap /etc/postfix/virtual
elif [ -e /etc/postfix/transport ]; then
  postmap /etc/postfix/transport
fi
mkdir -p /etc/postfix/keys
cp postfix/keys/* /etc/postfix/keys
systemctl restart postfix

configure_named
configure_snmpd


cp ssh/authorized_keys /root/.ssh
chmod 600 /root/.ssh/authorized_keys

cp selinux/* /usr/share/selinux/devel
modules=$(find /usr/share/selinux/devel -name \*.pp)
for module in $(modules); do
  semodule -i $module
done


setsebool -P antivirus_can_scan_system on

cp yum/* /etc/yum.repos.d/
cp etc/* /etc/

cp etc/clamd.d/* /etc/clamd.d
cp etc/amavisd/* /etc/amavisd

touch /var/log/clamd.scan
chmod 777 /var/run/clamd.scan
chgrp virusgroup /var/run/clamd.scan
chgrp -R virusgroup /var/spool/amavisd
chmod 775 /var/spool/amavisd/tmp
chown clamscan. /var/log/clamd.scan 
restorecon -v /var/log/clamd.scan 
usermod -G virusgroup amavis

enable_start amavisd
enable_start spamassassin
enable_start clamd@scan

cp usr/lib/systemd/system/* /usr/lib/systemd/system 
systemctl daemon-reload
systemctl restart amavisd

cp etc/mail/spamassassin/* /etc/mail/spamassassin
systemctl restart spamassassin

if=/dev/zero of=/swapfile bs=1024 count=1024000
mkswap /swapfile 
swapon /swapfile 
chmod 600 /swapfile 

echo "/swapfile          swap            swap    defaults        0 0" >> /etc/fstab

cp etc/selinux/config /etc/selinux

cat /etc/selinux/config | grep ^SELINUX=enforcing
if [ $? -eq 0 ]; then
  setenforce 1
else
  setenforce 0
fi
