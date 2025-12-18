source ../common/common.sh
tmp=$(mktemp -d)
yum install -y --installroot=$tmp --nogpgcheck opendkim | tee install.out
cleanup_root
tar zcvf opendkim-root.tgz -C $tmp . | tee -a install.out
podman import --change 'ENTRYPOINT ["/usr/sbin/opendkim","-f"]' opendkim-root.tgz opendkim-root:$creation_date | tee -a install.out
rm -rf $tmp
