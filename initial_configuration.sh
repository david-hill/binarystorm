#!/bin/bash

function configure_amavisd {
  cp etc/amavisd/amavisd.conf /etc/amavisd/amavisd.conf
  chgrp -R virusgroup /var/spool/amavisd
  chmod 775 /var/spool/amavisd/tmp
  chown clamscan. /var/log/clamd.scan 
  usermod -G virusgroup amavis
  cmp usr/lib/systemd/system/amavisd.service /usr/lib/systemd/system/amavisd.service
  if [ $? -ne 0 ]; then
    cp usr/lib/systemd/system/amavisd.service /usr/lib/systemd/system 
    systemctl daemon-reload
    systemctl restart amavisd
  fi
}

function configure_authorized_keys {
  cp ssh/authorized_keys /root/.ssh
  chmod 600 /root/.ssh/authorized_keys
}

function configure_clamd {
  restart=0
  cmp etc/clamd.d/scan.conf /etc/clamd.d/scan.conf
  if [ $? -ne 0 ]; then
    cp etc/clamd.d/scan.conf /etc/clamd.d/scan.conf
    restart=1
  fi
  touch /var/log/clamd.scan
  chmod 777 /var/run/clamd.scan
  chgrp virusgroup /var/run/clamd.scan
  restorecon -v /var/log/clamd.scan 
  setsebool -P antivirus_can_scan_system on
  if [ $restart -eq 1 ]; then
    systemctl restart amavisd
  fi
}


function configure_hostsdeny {
  cp etc/hosts.deny /etc/
}
function configure_selinux_modules {
  for f in usr/share/selinux/devel/*; do
    cmp $f /$f
    if [ $? -ne 0 ]; then  
      cp $f /$f
      if [[ $f =~ .pp ]]; then
        semodule -i $module
      fi
    fi
  done
}

function configure_named {
  restart=0
  cmp etc/named/named.conf /etc/named/named.conf
  if [ $? -ne 0 ]; then
    cp etc/named/named.conf /etc/named
    restart=1
  fi
  
  if [ ! -d /etc/named/named ]; then
    mkdir -p /etc/named/named
  fi
  
  cd etc/named/named
  for f in *.conf; do
    cmp $f /etc/named/named/$f
    if [ $? -ne 0 ]; then
      cp $f /etc/named/named
      restart=1
    fi
  done
  cd ../../..
  if [ $restart -eq 1 ]; then
    systemctl restart named
  fi
}

function configure_snmpd {
  cmp etc/snmp/snmpd.conf /etc/snmp/snmpd.conf
  if [ $? -ne 0 ]; then
    cp etc/snmp/snmpd.conf /etc/snmp/snmpd.conf
    systemctl restart snmpd
  fi
}

function configure_selinux {
  cmp etc/selinux/config /etc/selinux/config
  if [ $? -ne 0]; then
    cp etc/selinux/config /etc/selinux
    cat /etc/selinux/config | grep ^SELINUX=enforcing
    if [ $? -eq 0 ]; then
      setenforce 1
    else
      setenforce 0
    fi
  fi
}

function configure_spamassassin {
  restart=0
  for f in etc/mail/spamassassin/*; do
    cmp $f /$f
    if [ $? -ne 0 ]; then
      cp $f /$f
      restart=1
    fi
  done
  if [ $restart -eq 1 ]; then
    systemctl restart spamassassin
  fi
}

function configure_swap {
  if [ ! -e /swapfile ]; then
    if=/dev/zero of=/swapfile bs=1024 count=1024000
    mkswap /swapfile 
    swapon /swapfile 
    chmod 600 /swapfile 
    echo "/swapfile          swap            swap    defaults        0 0" >> /etc/fstab
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

function configure_yumreposd {
  cp etc/yum.repos.d/* /etc/yum.repos.d/
}

ifconfig eth0 | grep inet | grep -q 158.69.192.170
if [ $? -eq 0 ]; then
  sed -i 's/hostname: .*/hostname: dns1.binarystorm.net/' /etc/cloud/cloud.cfg
  hostnamectl set-hostname dns1.binarystorm.net
else
  sed -i 's/hostname: .*/hostname: dns2.binarystorm.net/' /etc/cloud/cloud.cfg
  hostnamectl set-hostname dns2.binarystorm.net
fi

configure_yumreposd
configure_hostsdeny

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
  cp etc/postfix/* /etc/postfix 
  if [ ! -e /etc/postfix/keys/smtpd.key ]; then
    openssl req -newkey rsa:4096 -nodes -sha512 -x509 -days 3650 -nodes -out /etc/postfix/keys/smtpd.cert -keyout /etc/postfix/keys/smtpd.key
    openssl req -newkey rsa:4096 -nodes -sha512 -x509 -days 3650 -nodes -out /etc/pki/cyrus-imapd/cyrus-imapd.pem -keyout /etc/pki/cyrus-imapd/cyrus-imapd.pem
    openssl req -newkey rsa:4096 -nodes -sha512 -x509 -days 3650 -nodes -out /etc/httpd/keys/wildcard.crt -keyout /etc/httpd/keys/wildcard.key
  fi
  cp etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf
  cp etc/httpd/conf.d/* /etc/httpd/conf.d/
  cp etc/squirrelmail/* /etc/squirrelmail/
  systemctl restart httpd
  cp etc/imapd.conf /etc
  cp etc/cyrus.conf /etc
  systemctl restart cyrus-imapd
elif [[ "$HOSTNAME" =~ dns2 ]]; then
  cp etc/postfix/master.cf /etc/postfix 
  cp etc/postfix/backup_mx/* /etc/postfix 
fi
if [ -e /etc/postfix/virtual ]; then
  postmap /etc/postfix/virtual
elif [ -e /etc/postfix/transport ]; then
  postmap /etc/postfix/transport
fi

mkdir -p /etc/postfix/keys
cp etc/postfix/keys/* /etc/postfix/keys
systemctl restart postfix

configure_named
configure_snmpd
configure_authorized_keys
configure_selinux_modules
configure_clamd 
configure_amavisd
enable_start amavisd
enable_start spamassassin
enable_start clamd@scan
configure_spamassassin
configure_swap
configure_selinux
