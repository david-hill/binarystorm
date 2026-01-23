source /root/binarystorm/podman/common/common.sh
podman ps | grep -q php-fpm
if [ $? -eq 0 ]; then
  podman stop php-fpm
  podman rm php-fpm
  podman pull $registry/php-fpm-root:latest
fi
if [ ! -d /run/php-fpm ]; then
  mkdir /run/php-fpm
fi
if [ ! -d /var/lib/roundcubemail ]; then
  mkdir /var/lib/roundcubemail
  chown 48:48 -R /var/lib/roundcubemail
fi
if [ ! -d /var/log/php-fpm ]; then
  mkdir /var/log/php-fpm
fi
mkdir -p /var/lib/php
chown -R 0:48 /var/lib/php
chown 48 /var/log/php-fpm
mkdir -p /var/lib/sql
chown -R 48:48 /var/lib/sql
mkdir -p /run/saslauthd
podman  run -d --network ipv6 --ip6 fd00::7 --ip 10.89.0.7 \
-v /run/php-fpm:/run/php-fpm \
-v /run/saslauthd:/run/saslauthd \
-v /var/lib/php:/var/lib/php \
-v /root/binarystorm/etc/php.d:/etc/php.d \
-v /root/binarystorm/etc/php-fpm.d:/etc/php-fpm.d \
-v /root/binarystorm/etc/php-fpm.conf:/etc/php-fpm.conf \
-v /root/binarystorm/etc/php.ini:/etc/php.ini \
-v /root/binarystorm/etc/roundcubemail/config.inc.php:/etc/roundcubemail/config.inc.php \
-v /var/lib/roundcubemail:/var/lib/roundcubemail \
-v /var/lib/sql:/var/lib/sql \
-v /var/log/php-fpm:/var/log/php-fpm \
-v /etc/pki:/etc/pki:ro \
--mount=type=bind,src=/dev/log,dst=/dev/log \
--name=php-fpm $registry/php-fpm-root:latest
sleep 3
podman generate systemd --new --files --name php-fpm
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-php-fpm
