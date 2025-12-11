source ../common/common.sh
tmp=$(mktemp -d)
yum install -y --installroot=$tmp --nogpgcheck clamd | tee install.out
chroot $tmp useradd -u 995 amavis | tee -a install.out
cleanup_root
tar zcvf clamd-root.tgz -C $tmp . | tee -a install.out
podman import --change 'ENTRYPOINT ["/usr/sbin/clamd","-F","-c","/etc/clamd.d/amavisd.conf"]' clamd-root.tgz clamd-root:$creation_date | tee -a install.out
rm -rf $tmp
