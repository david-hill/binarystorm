cat<<EOF>/etc/yum.repos.d/centos.repo
[baseos]
name=CentOS Stream 10 - BaseOS
metalink=https://mirrors.centos.org/metalink?repo=centos-baseos-10-stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
countme=1
enabled=1

[appstream]
name=CentOS Stream 10 - AppStream
metalink=https://mirrors.centos.org/metalink?repo=centos-appstream-10-stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
countme=1
enabled=1
EOF

cat<<EOF>/etc/yum.repos.d/epel.repo
[epel]
name=Extra Packages for Enterprise Linux 10 - $basearch
# It is much more secure to use the metalink, but if you wish to use a local mirror
# place its address here.
#baseurl=https://download.example/pub/epel/10/Everything/$basearch/
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-10&arch=$basearch&infra=$infra&content=$contentdir
enabled=1
gpgcheck=1
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-9
EOF

yum clean all
yum update -y
#dnf --releasever=10 --allowerasing --setopt=deltarpm=false distro-sync -y
