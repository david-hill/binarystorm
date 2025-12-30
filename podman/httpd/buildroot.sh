source ../common/common.sh
packages="httpd httpd-core mod_ssl roundcubemail"
service=httpd
entrypoint='ENTRYPOINT ["/usr/sbin/httpd","-DFOREGROUND"]'
build_container
