#!/bin/bash -e

function configure_amavisd {
  restart=0
  install_package amavisd-new
  cmp etc/amavisd/amavisd.conf /etc/amavisd/amavisd.conf
  if [ $? -ne 0 ]; then
    cp etc/amavisd/amavisd.conf /etc/amavisd/amavisd.conf
    restart=1
  fi
  chgrp -R virusgroup /var/spool/amavisd
  chmod 775 /var/spool/amavisd/tmp
  chown clamscan. /var/log/clamd.scan 
  usermod -G virusgroup amavis
  cmp usr/lib/systemd/system/amavisd.service /usr/lib/systemd/system/amavisd.service
  if [ $? -ne 0 ]; then
    restart=1
    cp usr/lib/systemd/system/amavisd.service /usr/lib/systemd/system 
  fi
  if [ $restart -eq 1 ]; then
    systemctl daemon-reload
    systemctl restart amavisd
  fi
}

function configure_authorized_keys {
  cp ssh/authorized_keys /root/.ssh
  chmod 600 /root/.ssh/authorized_keys
}

function configure_clamd {
  packages="clamav clamav-scanner clamav-scanner-systemd clamav-update"
  for p in $packages; do
    install_package $p
  done
  restart=0
  if [ -e /var/lib/clamav/bytecode.cld ]; then
    rm -rf /var/lib/clamav/bytecode.cld
  fi
  if [ -e /var/lib/clamav/main.cld ]; then
    rm -rf /var/lib/clamav/main.cld
  fi
  cmp etc/clamd.d/scan.conf /etc/clamd.d/scan.conf
  if [ $? -ne 0 ]; then
    cp etc/clamd.d/scan.conf /etc/clamd.d/scan.conf
    restart=1
  fi
  cmp etc/clamd.d/amavisd.conf /etc/clamd.d/amavisd.conf
  if [ $? -ne 0 ]; then
    cp etc/clamd.d/amavisd.conf /etc/clamd.d/amavisd.conf
    restart=1
  fi
  touch /var/log/clamd.scan
  chmod 777 /var/run/clamd.scan
  chgrp virusgroup /var/run/clamd.scan
  restorecon -v /var/log/clamd.scan 
  getsebool -a | grep -q antivirus_can_scan_system.*off 
  if [ $? -eq 0 ]; then
    setsebool -P antivirus_can_scan_system on
    restart=1
  fi
  if [ $restart -eq 1 ]; then
    systemctl restart amavisd
  fi
  if [ ! -e /var/run/clamd.scan/clamd.sock ]; then
    python -c "import socket as s; sock = s.socket(s.AF_UNIX); sock.bind('/var/run/clamd.scan/clamd.sock')"
    systemctl restart clamd@scan
  fi
  if [ -e /var/run/clamd.scan/clamd.sock ]; then
    chown amavis:virusgroup /var/run/clamd.scan/clamd.sock
    chmod 666 /var/run/clamd.scan/clamd.sock
  fi
  cmp usr/lib/systemd/system/clamd@.service /usr/lib/systemd/system/
  if [ $? -ne 0 ]; then
    restart=1
    cp usr/lib/systemd/system/clamd@.service /usr/lib/systemd/system 
  fi
  if [ $restart -eq 1 ]; then
    systemctl daemon-reload
    systemctl restart amavisd
  fi
}

function configure_cyrus_passwd {
  if [ ! -e /etc/sasldb2 ]; then
    saslpasswd2 -c cyrus
    passwd cyrus
    cyradm -u cyrus localhost 
  # cm user.dhill
  fi
}

function reload {
  if [ $1 -eq 1 ]; then
    reload=1
  fi
}

function configure_firewall {
  ports="25/tcp 53/tcp 53/udp 80/tcp 110/tcp 143/tcp 143/udp 161/udp 443/tcp 993/tcp 995/tcp"
  reload=0
  for p in $ports; do
    add_port $p
    reload $?
  done
  if [ $reload -eq 1 ]; then
    firewall-cmd --reload
  fi
}

function configure_hostname {
  ifconfig eth0 | grep inet | grep -q 158.69.192.170
  if [ $? -eq 0 ]; then
    sed -i 's/hostname: .*/hostname: dns1.binarystorm.net/' /etc/cloud/cloud.cfg
    hostnamectl set-hostname dns1.binarystorm.net
  else
    ifconfig eth0 | grep inet | grep -q 145.239.80.189
    if [ $? -eq 0 ]; then
      sed -i 's/hostname: .*/hostname: dns3.binarystorm.net/' /etc/cloud/cloud.cfg
      hostnamectl set-hostname dns3.binarystorm.net
    else
      sed -i 's/hostname: .*/hostname: dns2.binarystorm.net/' /etc/cloud/cloud.cfg
      hostnamectl set-hostname dns2.binarystorm.net
    fi
  fi
}

function configure_hostsdeny {
  cp etc/hosts.deny /etc/
}

function configure_selinux_modules {
  install_package selinux-policy-devel
  for f in usr/share/selinux/devel/*; do
    cmp $f /$f
    if [ $? -ne 0 ]; then  
      cp $f /$f
      if [[ $f =~ .pp ]]; then
        semodule -i /$f
      fi
    fi
  done
}

function configure_named {
  packages="bind bind-utils"
  for p in $packages; do
    install_package $p
  done
  restart=0
  cmp etc/named.conf /etc/named.conf
  if [ $? -ne 0 ]; then
    cp etc/named.conf /etc/named.conf
    restart=1
  fi
  
  if [ ! -d /etc/named ]; then
    mkdir -p /etc/named
  fi
  cmp etc/named.conf /etc/named.conf
  if [ $? -ne 0 ]; then 
    cp etc/named.conf /etc/named.conf
    restart=1
  fi
  for f in etc/named/*; do
    cmp $f /$f
    if [ $? -ne 0 ]; then
      cp $f /$f
      restart=1
    fi
  done
  if [ $restart -eq 1 ]; then
    systemctl restart named
  fi
}

function configure_snmpd {
  packages="net-snmp net-snmp-utils"
  for p in $packages; do
    install_package $p
  done
  cmp etc/snmp/snmpd.conf /etc/snmp/snmpd.conf
  if [ $? -ne 0 ]; then
    cp etc/snmp/snmpd.conf /etc/snmp/snmpd.conf
    systemctl restart snmpd
  fi
}

function configure_selinux {
  cmp etc/selinux/config /etc/selinux/config
  if [ $? -ne 0 ]; then
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
  install_package spamassassin
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
  list="swapfile swapfile1 swapfile2 swapfile3"
  for swap in $list; do
    if [ ! -e /$swap ]; then
      dd if=/dev/zero of=/$swap bs=1024 count=1024000
      mkswap /$swap 
      swapon /$swap 
      chmod 600 /$swap
      echo "/$swap          swap            swap    defaults        0 0" >> /etc/fstab
    fi
  done
}

function enable_start {
  s=$1
  if $( systemctl list-unit-files | grep -q $s) ; then
    systemctl status $s | grep -q enabled
    if [ $? -ne 0 ]; then
      systemctl enable $s
    fi
    systemctl status $s | grep -q running
    if [ $? -ne 0 ]; then
      systemctl start $s
    fi
  fi
}

function add_port {
  lreload=0
  firewall-cmd --list-all | grep -q " $1"
  if [ $? -ne 0 ]; then
    firewall-cmd --permanent --zone=public --add-port=$1
    lreload=1
  fi
 return $lreload
}

function configure_yumreposd {
  cp etc/yum.repos.d/* /etc/yum.repos.d/
}

function install_package {
  p=$1
  rpm -qi $p > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    yum install -y $p
  fi
}

function configure_cyrus {
  packages="cyrus-imapd cyrus-sasl"
  if [[ "$HOSTNAME" =~ dns1 ]]; then
    for p in $packages; do
      install_package $p
    done
    restart=0
    if [ ! -e /etc/pki/cyrus-imapd/cyrus-imapd.pem ]; then
      openssl req  -new -extensions 'extendedkey' -nodes -sha512  -days 398 -key /etc/pki/cyrus-imapd/cyrus-imapd.key -nodes -out /etc/pki/cyrus-imapd/cyrus-imapd.csr

      openssl req -newkey rsa:4096 -extensions 'extendedkey' -nodes -sha512 -x509 -days 825 -nodes -out /etc/pki/cyrus-imapd/cyrus-imapd.pem -keyout /etc/pki/cyrus-imapd/cyrus-imapd.pem
    fi
    cmp etc/imapd.conf /etc/imapd.conf
    if [ $? -ne 0 ]; then
      cp etc/imapd.conf /etc
      restart=1
    fi
    cmp etc/cyrus.conf /etc/cyrus.conf
    if [ $? -ne 0 ]; then
      cp etc/cyrus.conf /etc
      restart=1
    fi
    if [ $restart -eq 1 ]; then
      systemctl restart cyrus-imapd
    fi
  fi
}
function configure_squirrelmail {
  if [[ "$HOSTNAME" =~ dns1 ]]; then
    install_package squirrelmail
    restart=0
    for f in etc/squirrelmail/*; do
      cmp $f /$f
      if [ $? -ne 0 ]; then
       cp $f /$f
       restart=1
      fi
    done
    if [ $restart -eq 1 ]; then
      systemctl restart httpd
    fi
  fi
}
function configure_httpd {
  if [[ "$HOSTNAME" =~ dns1 ]]; then
    install_package httpd
    install_package mod_ssl
    restart=0
    if [ ! -e /etc/httpd/keys/wildcard.key ]; then
      mkdir -p /etc/httpd/keys
      openssl req -newkey rsa:4096 -extensions 'extendedkey' -nodes -sha512 -x509 -days 825 -nodes -out /etc/httpd/keys/wildcard.crt -keyout /etc/httpd/keys/wildcard.key
    fi
    cmp etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf
    if [ $? -ne 0 ]; then
      cp etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf
      restart=1
    fi
    for f in etc/httpd/conf.d/*; do
      cmp $f /$f
      if [ $? -ne 0 ]; then
        cp $f /$f
        restart=1
      fi
    done
    if [ $restart -eq 1 ]; then
      systemctl restart httpd
    fi
  fi
}

function run_postmap {
  f=$1
  if [[ $f =~ virtual ]] || [[ $f =~ transport ]]; then
    if [ -e /etc/postfix/$f ]; then
      postmap /etc/postfix/$f
    fi
  fi
}

function configure_sshd {
  setsebool -P ssh_use_tcpd=1
  systemctl stop sshd
  systemctl disable sshd
  systemctl enable --now sshd.socket
  mkdir -p /etc/systemd/system/sshd@.service.d/
  sudo cp etc/systemd/system/sshd@.service.d/override.conf /etc/systemd/system/sshd@.service.d/override.conf
  systemctl daemon-reload
}

function configure_fail2ban {
  /usr/bin/razor-admin  -register
}

function configure_fail2ban {
  install_package fail2ban
  restart=0
  cmp etc/fail2ban/jail.conf /etc/fail2ban/jail.conf
  if [ $? -ne 0 ]; then
    cp etc/fail2ban/jail.conf /etc/fail2ban/jail.conf
    restart=1
  fi
  if [ $restart -eq 1 ]; then 
    systemctl restart postfix
  fi
}

function configure_openssl {
  cmp etc/pki/tls/openssl.cnf /etc/pki/tls/openssl.cnf
  if [ $? -ne 0 ]; then
    cp etc/pki/tls/openssl.cnf /etc/pki/tls/openssl.cnf
  fi
}

function configure_postfix {
  install_package postfix
  restart=0
  if [ ! -e /etc/postfix/keys ]; then
    mkdir -p /etc/postfix/keys
  fi
  cmp etc/postfix/keys/smtpd.cert /etc/postfix/keys/smtpd.cert
  if [ $? -ne 0 ]; then
    cp etc/postfix/keys/smtpd.cert /etc/postfix/keys
    restart=1
  fi
  if [[ "$HOSTNAME" =~ dns1 ]]; then
    if [ ! -e /etc/postfix/keys/smtpd.key ]; then
      openssl req -newkey rsa:4096 -extensions 'extendedkey' -nodes -sha512 -x509 -days 825 -nodes -out /etc/postfix/keys/smtpd.cert -keyout /etc/postfix/keys/smtpd.key
    fi
    cd etc/postfix
    for f in *; do
      if [ -f $f ]; then
        cmp $f /etc/postfix/$f
        if [ $? -ne 0 ]; then
          cp $f /etc/postfix/$f
          run_postmap $f
          restart=1
        fi
      fi
    done
    cd ../../
  elif [[ "$HOSTNAME" =~ dns2 ]] || [[ "$HOSTNAME" =~ dns3 ]]; then
    cmp etc/postfix/master.cf /etc/postfix/master.cf
    if [ $? -ne 0 ]; then
      cp etc/postfix/master.cf /etc/postfix 
      restart=1
    fi
    cd etc/postfix/backup_mx
    for f in *; do
      cmp $f /etc/postfix/$f
      if [ $? -ne 0 ]; then
        cp $f /etc/postfix/
        run_postmap $f
        restart=1
      fi
    done
    cd ../../../
  fi
  if [ $restart -eq 1 ]; then 
    systemctl restart postfix
  fi
}

function install_packages_and_update {
  rpm -qa | grep -q epel-release
  if [ $? -ne 0 ]; then
    dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
  fi
  packages="uptimed vim yum-utils telnet wget ntp tmux sysstat gcc tcp_wrappers"
  for p in $packages; do 
    install_package $p
  done
  yum update -y
}

function install_dcc {
  cd /tmp
  wget https://www.dcc-servers.net/dcc/source/dcc.tar.Z
  tar xvf dcc.tar.Z
  cd dcc-2.3.169
  ./configure
  make
  make install
}
function diff_changes {
  for p in $( find -name \*rpmnew ); do q=${p%\.rpmnew}; diff -u $p $q;  done | less
}

function resize_disk {
  growpart /dev/sda 1
  resize2fs /dev/sda
}
configure_hostname
configure_yumreposd
configure_hostsdeny
install_packages_and_update
install_dcc
resize_disk
configure_firewall
configure_httpd
configure_openssl
configure_cyrus
configure_cyrus_passwd
configure_fail2ban
configure_squirrelmail
configure_sshd
configure_postfix
configure_named
configure_snmpd
configure_authorized_keys
configure_selinux_modules
configure_clamd 
configure_amavisd
configure_razor
configure_spamassassin
configure_swap
configure_selinux
enable_start amavisd
enable_start spamassassin
#enable_start clamd@scan
enable_start clamav-freshclam
enable_start clamd@amavisd
enable_start fail2ban
enable_start cyrus-imapd
enable_start httpd
enable_start saslauthd
enable_start ntpd
enable_start named
enable_start snmpd
enable_start uptimed
diff_changes
