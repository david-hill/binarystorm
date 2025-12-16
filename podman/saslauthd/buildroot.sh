source ../common/common.sh
tmp=$(mktemp -d)
rpms="cyrus-sasl cyrus-imapd" 
yum install -y --installroot=$tmp --nogpgcheck $rpms | tee install.out
cleanup_root
tar zcvf saslauthd-root.tgz -C $tmp . | tee -a install.out
podman import --change 'ENTRYPOINT ["/usr/sbin/saslauthd","-d","-m","/run/saslauthd","-a","pam"]' saslauthd-root.tgz saslauthd-root:$creation_date | tee -a install.out
podman tag saslauthd-root:$creation_date saslauthd-root:latest
rm -rf $tmp
