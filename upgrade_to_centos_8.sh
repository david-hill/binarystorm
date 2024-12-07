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

sudo dnf -y --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync --disablerepo=appstream
sudo dnf -y --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync
sudo dnf -y groupupdate "Core" "Minimal Install"

