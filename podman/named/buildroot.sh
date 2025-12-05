source ../common/common.sh
tmp=$(mktemp -d)
yum install -y --nodocs --installroot=$tmp --nogpgcheck bind | tee install.out
cleanup_root
tar zcvf named-root.tgz -C $tmp .  | tee -a install.out
podman import --change 'ENTRYPOINT ["/usr/sbin/named", "-f", "-u", "named", "-c", "/etc/named.conf"]' named-root.tgz named-root:$creation_date | tee -a install.out
rm -rf $tmp
