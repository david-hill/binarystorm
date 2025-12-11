source ../common/common.sh
tmp=$(mktemp -d)
yum install -y --installroot=$tmp --nogpgcheck cyrus-imapd cyrus-sasl-plain | tee install.out
cleanup_root
tar zcvf cyrus-imapd-root.tgz -C $tmp . | tee -a install.out
podman import --change 'ENTRYPOINT ["/usr/libexec/cyrus-imapd/master", "foreground"]' cyrus-imapd-root.tgz cyrus-imapd-root:$creation_date | tee -a install.out
rm -rf $tmp
