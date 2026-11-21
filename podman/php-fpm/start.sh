source /config/podman/common/common.sh
podman ps | grep -v container | grep -q php-fpm
if [ $? -eq 0 ]; then
  podman stop php-fpm
  podman rm php-fpm
  podman pull $registry/php-fpm-root:latest
fi
if [ ! -d $datadir/run/php-fpm ]; then
  mkdir $datadir/run/php-fpm
fi
if [ ! -d $datadir/var/log/php-fpm ]; then
  mkdir $datadir/var/log/php-fpm
fi
chown 48 $datadir/var/log/php-fpm
mkdir -p $datadir/var/lib/sql
chown -R 48:48 $datadir/var/lib/sql
mkdir -p $datadir/run/saslauthd
if [[ $(hostname) =~ dns01 ]]; then
  volargs="-v $gitlocation/etc/roundcubemail/config.inc.php:/etc/roundcubemail/config.inc.php:ro"
else
  volargs="-v $gitlocation/etc/roundcubemail/backup_mx/config.inc.php:/etc/roundcubemail/config.inc.php:ro"
fi

podman run -d --network ipv6 --ip6 fd00::7 --ip 10.89.0.7 \
-v $datadir/run/php-fpm:/run/php-fpm \
-v $datadir/run/saslauthd:/run/saslauthd:z \
-v $gitlocation/etc/php.d:/etc/php.d \
-v $gitlocation/etc/php-fpm.d:/etc/php-fpm.d \
-v $gitlocation/etc/php-fpm.conf:/etc/php-fpm.conf \
-v $gitlocation/etc/php.ini:/etc/php.ini \
$volargs \
-v $datadir/var/lib/sql:/var/lib/sql:z \
-v $datadir/var/log/php-fpm:/var/log/php-fpm:z \
-v /etc/pki:/etc/pki:ro \
--mount=type=bind,src=/dev/log,dst=/dev/log \
--name=php-fpm $registry/php-fpm-root:latest
sleep 3
podman generate systemd --new --files --name php-fpm
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-php-fpm
