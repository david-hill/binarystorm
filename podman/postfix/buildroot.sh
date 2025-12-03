tmp=$(mktemp -d)
yum install -y --installroot=$tmp --nogpgcheck postfix cyrus-imapd | tee install.out
tar zcvf postfix-root.tgz -C $tmp . | tee -a install.out
podman import postfix-root.tgz postfix-root:latest | tee -a install.out
rm -rf $tmp
