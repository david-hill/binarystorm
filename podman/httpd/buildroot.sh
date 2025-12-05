source ../common/common.sh
tmp=$(mktemp -d)
yum install -y --installroot=$tmp --nogpgcheck httpd httpd-core mod_ssl roundcubemail  | tee install.out
cleanup_root
tar zcvf httpd-root.tgz -C $tmp . | tee -a install.out
podman import httpd-root.tgz httpd-root:$creation_date | tee -a install.out
rm -rf $tmp
