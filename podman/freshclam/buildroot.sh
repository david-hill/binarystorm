source ../common/common.sh
tmp=$(mktemp -d)
yum install -y --installroot=$tmp --nogpgcheck clamav-freshclam | tee install.out
chroot $tmp useradd -u 995 amavis | tee -a install.out
cleanup_root
tar zcvf freshclam-root.tgz -C $tmp . | tee -a install.out
podman import --change 'ENTRYPOINT ["/usr/bin/freshclam", "-d", "--foreground=true"]' freshclam-root.tgz freshclam-root:$creation_date | tee -a install.out
rm -rf $tmp
