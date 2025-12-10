source ../common/common.sh
tmp=$(mktemp -d)
packages="php-fpm php-pdo php-process php-gd php-intl php-ldap php-mbstring php-xml php-pecl-zip php-enchant"
yum install -y --installroot=$tmp --nogpgcheck $packages | tee install.out
cleanup_root
tar zcvf php-fpm-root.tgz -C $tmp . | tee -a install.out
podman import --change 'ENTRYPOINT ["/usr/sbin/php-fpm","-F"]' php-fpm-root.tgz php-fpm-root:$creation_date | tee -a install.out
rm -rf $tmp
