source /root/binarystorm/podman/common/common.sh
podman ps | grep -q httpd
if [ $? -eq 0 ]; then
  podman stop httpd
  podman rm httpd
  podman pull $registry/httpd-root:latest
fi
if [ ! -d /var/lib/sql ]; then
  mkdir /var/lib/sql
fi
if [ ! -d /var/lib/php ]; then
  mkdir /var/lib/php
fi
if [ ! -d /etc/roundcubemail ]; then
  mkdir /etc/roundcubemail
fi
if [ ! -d /usr/share/roundcubemail ]; then
  mkdir /usr/share/roundcubemail
fi
podman  run -d --network ipv6 --ip6 fd00::6 --ip 10.89.0.6 -p 80:80/tcp -p 443:443/tcp -p [::]:80:80/tcp -p [::]:443:443/tcp -v /root/binarystorm/etc/httpd:/etc/httpd:ro -v /root/binarystorm/var/www:/var/www:ro -v /root/binarystorm/etc/roundcubemail/config.inc.php:/etc/roundcubemail/config.inc.php:ro -v /var/lib/sql:/var/lib/sql -v /run/php-fpm/www.sock:/run/php-fpm/www.sock -v /var/lib/php:/var/lib/php:ro -v /etc/pki/tls/certs/localhost.crt:/etc/pki/tls/certs/localhost.crt:ro -v /etc/pki/tls/private/localhost.key:/etc/pki/tls/private/localhost.key:ro -v /var/log/httpd:/var/log/httpd --mount=type=bind,src=/dev/log,dst=/dev/log --name=httpd $registry/httpd-root:latest
sleep 3
podman generate systemd --new --files --name httpd
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-httpd

