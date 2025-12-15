source ../common/common.sh
tmp=$(mktemp -d)
yum install -y --installroot=$tmp --nogpgcheck cyrus-sasl | tee install.out
cleanup_root
tar zcvf saslauthd -root.tgz -C $tmp . | tee -a install.out
podman import --change 'ENTRYPOINT ["/usr/sbin/saslauthd","-d","-m","/run/saslauthd","-a","pam"]' saslauthd-root.tgz saslauthd-root:$creation_date | tee -a install.out
rm -rf $tmp
