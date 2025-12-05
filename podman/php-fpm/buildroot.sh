tmp=$(mktemp -d)
packages="php-fpm php-pdo php-process php-gd php-intl php-ldap php-mbstring php-xml php-pecl-zip php-enchant"
yum install -y --installroot=$tmp --nogpgcheck $packages | tee install.out
rm -rf $tmp/var/cache/dnf
rm -rf $tmp/var/lib/dnf
rm -rf $tmp/usr/share/man
rm -rf $tmp/usr/share/doc
rm -rf $tmp/usr/lib/.build-id
rm -rf $tmp/var/log/dnf*
rm -rf $tmp/var/log/hawkey*
tar zcvf php-fpm-root.tgz -C $tmp . | tee -a install.out
podman import php-fpm-root.tgz php-fpm-root:latest | tee -a install.out
rm -rf $tmp
