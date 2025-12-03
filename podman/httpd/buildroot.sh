tmp=$(mktemp -d)
yum install -y --installroot=$tmp --nogpgcheck httpd httpd-core mod_ssl roundcubemail  | tee install.out
rm -rf $tmp/var/cache/dnf
rm -rf $tmp/var/lib/dnf
tar zcvf httpd-root.tgz -C $tmp . | tee -a install.out
podman import httpd-root.tgz httpd-root:latest | tee -a install.out
rm -rf $tmp
