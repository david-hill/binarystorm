tmp=$(mktemp -d)
yum install -y --installroot=$tmp --nogpgcheck httpd httpd-core mod_ssl roundcubemail  | tee install.out
rm -rf $tmp/var/cache/dnf
rm -rf $tmp/var/lib/dnf
rm -rf $tmp/usr/share/man
rm -rf $tmp/usr/share/doc
rm -rf $tmp/usr/lib/.build-id
rm -rf $tmp/var/log/dnf*
rm -rf $tmp/var/log/hawkey*
tar zcvf httpd-root.tgz -C $tmp . | tee -a install.out
podman import httpd-root.tgz httpd-root:latest | tee -a install.out
rm -rf $tmp
