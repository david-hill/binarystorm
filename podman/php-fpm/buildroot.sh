source ../common/common.sh
tmp=$(mktemp -d)
packages="php-fpm php-pdo php-process php-gd php-intl php-ldap php-mbstring php-xml php-pecl-zip php-enchant"
service=php-fpm
entrypoint='ENTRYPOINT ["/usr/sbin/php-fpm","-F"]'
build_container
