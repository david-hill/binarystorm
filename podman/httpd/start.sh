source /root/binarystorm/podman/common/common.sh
podman ps -a | grep -q httpd
if [ $? -eq 0 ]; then
  podman stop httpd
  podman rm httpd
  podman pull $registry/httpd-root:latest
fi
directories="/var/lib/sql /var/lib/php /var/log/httpd"
for directory in $directories; do
  mkdir -p $directory
done
podman  run -d --network ipv6 --ip6 fd00::6 --ip 10.89.0.6 -p 80:80/tcp -p 443:443/tcp -p [::]:80:80/tcp -p [::]:443:443/tcp -v /root/binarystorm/etc/httpd/conf/httpd.conf:/etc/httpd/conf/httpd.conf -v /root/binarystorm/etc/httpd/conf.d:/etc/httpd/conf.d:ro -v /root/binarystorm/var/www:/var/www:ro -v /root/binarystorm/etc/roundcubemail/config.inc.php:/etc/roundcubemail/config.inc.php:ro -v /var/lib/sql:/var/lib/sql -v /run/php-fpm/www.sock:/run/php-fpm/www.sock -v /var/lib/php:/var/lib/php:ro -v /etc/pki/tls/certs/localhost.crt:/etc/pki/tls/certs/localhost.crt:ro -v /etc/pki/tls/certs/wildcard.crt:/etc/httpd/keys/wildcard.crt:ro -v /etc/pki/tls/private/wildcard.key:/etc/httpd/keys/wildcard.key -v /etc/pki/tls/private/localhost.key:/etc/pki/tls/private/localhost.key:ro -v /var/log/httpd:/var/log/httpd --mount=type=bind,src=/dev/log,dst=/dev/log --name=httpd $registry/httpd-root:latest
sleep 3
podman generate systemd --new --files --name httpd
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-httpd

