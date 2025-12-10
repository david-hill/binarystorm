source ../common/common.sh
tmp=$(mktemp -d)
yum install -y --installroot=$tmp --nogpgcheck amavis perl-Razor-Agent pyzor | tee install.out
cleanup_root
tar zcvf amavisd-root.tgz -C $tmp . | tee -a install.out
podman import --change 'ENTRYPOINT ["/usr/sbin/amavisd","-c","/etc/amavisd/amavisd.conf","foreground"]' amavisd-root.tgz amavisd-root:$creation_date | tee -a install.out
rm -rf $tmp
