tmp=$(mktemp -d)
yum install -y --installroot=$tmp --nogpgcheck cyrus-imapd | tee install.out
tar zcvf cyrus-imapd-root.tgz -C $tmp . | tee -a install.out
podman import cyrus-imapd-root.tgz cyrus-imapd-root:latest | tee -a install.out
rm -rf $tmp
