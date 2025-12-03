tmp=$(mktemp -d)
yum install -y --installroot=$tmp --nogpgcheck cyrus-imapd | tee install.out
rm -rf $tmp/var/cache/dnf
rm -rf $tmp/var/lib/dnf
rm -rf $tmp/usr/share/man
rm -rf $tmp/usr/share/doc
tar zcvf cyrus-imapd-root.tgz -C $tmp . | tee -a install.out
podman import cyrus-imapd-root.tgz cyrus-imapd-root:latest | tee -a install.out
rm -rf $tmp
