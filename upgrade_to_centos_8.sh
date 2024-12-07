sudo dnf update -y
mkdir /root/backup
sudo mv /etc/yum.repos.d/*.repo /root/backup
dnf install http://vault.centos.org/8.5.2111/BaseOS/x86_64/os/Packages/{centos-linux-repos-8-3.el8.noarch.rpm,centos-linux-release-8.5-1.2111.el8.noarch.rpm,centos-gpg-keys-8-3.el8.noarch.rpm}
dnf -y upgrade https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf clean all
rpm -e `rpm -q kernel`
rpm -e --nodeps sysvinit-tools

cat << EOF > /etc/yum.repos.d/centos.repo
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
sudo rpm -e nss nss-pem nss-sysinit nss-tools

sudo dnf -y --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync --disablerepo=appstream
sudo dnf -y --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync
sudo dnf -y groupupdate "Core" "Minimal Install"
sudo dnf -y yum install kernel cloud-init vim
sudo dnf -y install centos-release-stream
sudo dnf -y swap centos-{linux,stream}-repos
cat << EOF > /etc/yum.repos.d/centos.repo
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

dnf install https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-stream-release-9.0-22.el9.noarch.rpm https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-gpg-keys-9.0-22.el9.noarch.rpm https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-stream-repos-9.0-22.el9.noarch.rpm
dnf --releasever=9 --allowerasing --setopt=deltarpm=false distro-sync -y
