source ../common/common.sh
tmp=$(mktemp -d)
yum install -y --installroot=$tmp --nogpgcheck postfix cyrus-imapd bind-utils | tee install.out
cleanup_root
tar zcvf postfix-root.tgz -C $tmp . | tee -a install.out
podman import --change 'ENTRYPOINT ["/usr/sbin/postfix","start-fg"]' postfix-root.tgz postfix-root:$creation_date | tee -a install.out
rm -rf $tmp
