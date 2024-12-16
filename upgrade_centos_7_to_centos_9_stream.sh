set -e
sudo dnf update -y
sudo mkdir /root/backup_7
sudo mv /etc/yum.repos.d/*.repo /root/backup_7
sudo dnf install http://vault.centos.org/8.5.2111/BaseOS/x86_64/os/Packages/{centos-linux-repos-8-3.el8.noarch.rpm,centos-linux-release-8.5-1.2111.el8.noarch.rpm,centos-gpg-keys-8-3.el8.noarch.rpm}
sudo dnf clean all
sudo rpm -e `rpm -q kernel`
sudo rpm -e --nodeps sysvinit-tools
sudo mkdir /root/backup_7_1
sudo mv /etc/yum.repos.d/*.repo /root/backup_7_1
sudo cat << EOF > /etc/yum.repos.d/centos.repo
[appstream]
name=CentOS Linux $releasever - AppStream
baseurl=http://vault.centos.org/8.5.2111/AppStream/x86_64/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
[powertools]
name=CentOS Linux $releasever - PowerTools
baseurl=http://vault.centos.org/8.5.2111/PowerTools/x86_64/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
[baseos]
name=CentOS Linux $releasever - BaseOS
baseurl=http://vault.centos.org/8.5.2111/BaseOS/x86_64/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
[extras]
name=CentOS Linux $releasever - Extras
baseurl=http://vault.centos.org/8.5.2111/extras/x86_64/os/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
EOF
sudo dnf -y remove dracut-network vim-common yum yum-metadata-parser
sudo mv /etc/yum /etc/yum.old
sudo dnf -y --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync --disablerepo=appstream
sudo dnf -y --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync
sudo dnf -y groupupdate "Core" "Minimal Install"
sudo dnf -y install kernel cloud-init vim
#sudo dnf -y install centos-release-stream
#sudo dnf -y swap centos-{linux,stream}-repos
sudo mkdir /root/backup_8
sudo mv /etc/yum.repos.d/*.repo /root/backup_8
sudo cat << EOF > /etc/yum.repos.d/centos.repo
[Stream-AppStream]
name=CentOS-Stream - AppStream
#mirrorlist=https://vault.centos.org/centos/8-stream/AppStream/x86_64/os
baseurl=https://vault.centos.org/centos/8-stream/AppStream/x86_64/os
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
[powertools]
name=CentOS Linux $releasever - PowerTools
baseurl=http://vault.centos.org/centos/8-stream/PowerTools/x86_64/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
[baseos]
name=CentOS Linux $releasever - BaseOS
baseurl=http://vault.centos.org/centos/8-stream/BaseOS/x86_64/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
[extras]
name=CentOS Linux $releasever - Extras
baseurl=http://vault.centos.org/centos/8-stream/extras/x86_64/os/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
EOF
sudo mkdir /root/backup_8_0
sudo dnf -y swap centos-{linux,stream}-repos
sudo mv /etc/yum.repos.d/*.repo /root/backup_8_0
sudo cat << EOF > /etc/yum.repos.d/centos.repo
[Stream-AppStream]
name=CentOS-Stream - AppStream
#mirrorlist=https://vault.centos.org/centos/8-stream/AppStream/x86_64/os
baseurl=https://vault.centos.org/centos/8-stream/AppStream/x86_64/os
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
[powertools]
name=CentOS Linux $releasever - PowerTools
baseurl=http://vault.centos.org/centos/8-stream/PowerTools/x86_64/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
[baseos]
name=CentOS Linux $releasever - BaseOS
baseurl=http://vault.centos.org/centos/8-stream/BaseOS/x86_64/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
[extras]
name=CentOS Linux $releasever - Extras
baseurl=http://vault.centos.org/centos/8-stream/extras/x86_64/os/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
EOF
sudo dnf distro-sync
sudo mkdir /root/backup_8_stream
sudo mv /etc/yum.repos.d/*.repo /root/backup_8_stream
sudo rpm -e --nodeps iptables-ebtables
sudo dnf install -y https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-stream-release-9.0-22.el9.noarch.rpm https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-gpg-keys-9.0-22.el9.noarch.rpm https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-stream-repos-9.0-22.el9.noarch.rpm
sudo dnf --releasever=9 --allowerasing --setopt=deltarpm=false distro-sync -y
sudo dnf -y upgrade https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
sudo rpm --rebuilddb
sudo systemctl stop clamd@scan.service
sudo systemctl stop clamd@amavisd.service
sudo dnf -y install spamassassin amavis vim fail2ban git bind bind-utils net-snmp uptimed pyzor httpd tcp_wrappers yum mod_ssl roundcubemail.noarch whois net-snmp-utils clamav-freshclam clamd cyrus-imapd cyrus-imapd rpmconf
sudo cp /etc/named.conf.rpmsave /etc/named.conf
sudo cp /etc/amavisd/amavisd.conf.rpmsave /etc/amavisd/amavisd.conf
sudo cp /etc/mail/spamassassin/local.cf.rpmsave /etc/mail/spamassassin/local.cf
sudo cp /etc/mail/spamassassin/v310.pre.rpmsave /etc/mail/spamassassin/v310.pre
sudo cp /etc/snmp/snmpd.conf.rpmsave /etc/snmp/snmpd.conf
sudo cp /etc/clamd.d/scan.conf.rpmnew /etc/clamd.d/scan.conf
sudo cp /etc/clamd.d/amavisd.conf.rpmsave /etc/clamd.d/amavisd.conf
sudo cp /etc/cyrus.conf.rpmsave /etc/cyrus.conf
sudo cp /etc/imapd.conf.rpmsave /etc/imapd.conf
sudo mkdir /var/lib/razor
sudo /usr/bin/razor-admin  -register
sudo systemctl enable amavisd fail2ban spamassassin named snmpd uptimed clamav-freshclam.service sshd clamd@amavisd.service cyrus-imapd
sudo systemctl start amavisd fail2ban spamassassin named snmpd uptimed clamav-freshclam.service sshd clamd@amavisd.service cyrus-imapd
sudo setsebool -P ssh_use_tcpd=1
sudo setsebool -P antivirus_can_scan_system=1
sudo systemctl stop sshd
sudo systemctl disable sshd
sudo cp etc/hosts.deny /etc/hosts.deny
sudo systemctl enable --now sshd.socket
sudo mkdir -p /etc/systemd/system/sshd@.service.d/
sudo cp etc/systemd/system/sshd@.service.d/override.conf /etc/systemd/system/sshd@.service.d/override.conf
sudo systemctl daemon-reload
sudo sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
chown amavis /var/run/clamd.scan
sudo rm -f /etc/dnf/modules.d/*.module
sudo touch /.autorelabel
