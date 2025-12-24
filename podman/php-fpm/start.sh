source ../common/common.sh
# podman network create  --ipv6 ipv6 --gateway fd00::::1 --subnet fd00:0000:0000:0000:0000:0000:0000:0000/120 --gateway 10.89.0.1 --subnet 10.89.0.0/16 --disable-dns
podman ps | grep -q php-fpm
if [ $? -eq 0 ]; then
  podman stop php-fpm
  podman rm php-fpm
  podman pull $registry/php-fpm-root:latest
fi
#podman --debug run  --net host -v /etc/named:/etc/named:ro -v /etc/named.ca:/etc/named.ca:ro  -v /etc/named.conf:/etc/named.conf:ro -v /etc/named.rfc1912.zones:/etc/named.rfc1912.zones:ro -v /etc/named.root.key:/etc/named.root.key:ro --name=bind bind  &
if [ ! -d /run/php-fpm ]; then
  mkdir /run/php-fpm
fi
if [ ! -d /var/lib/roundcubemail ]; then
  mkdir /var/lib/roundcubemail
fi
if [ ! -d /var/log/php-fpm ]; then
  mkdir /var/log/php-fpm
fi

podman  run -d --network ipv6 --ip6 fd00::7 --ip 10.89.0.7 -v /run/php-fpm:/run/php-fpm -v /run/saslauthd:/run/saslauthd --mount=type=bind,src=/dev/log,dst=/dev/log -v /var/lib/php:/var/lib/php -v /etc/php.d:/etc/php.d -v /etc/php-fpm.d:/etc/php-fpm.d -v /etc/php-fpm.conf:/etc/php-fpm.conf -v /etc/php.ini:/etc/php.ini -v /usr/share/roundcubemail:/usr/share/roundcubemail -v /etc/roundcubemail:/etc/roundcubemail -v /var/lib/roundcubemail:/var/lib/roundcubemail -v /var/lib/sql:/var/lib/sql -v /var/log/php-fpm:/var/log/php-fpm -v /etc/pki:/etc/pki:ro --name=php-fpm $registry/php-fpm-root:latest
#-p 53:53/udp -p 53:53/tcp 
#-v /var/named:/var/named -v /etc/named:/etc/named:ro -v /etc/named.ca:/etc/named.ca:ro  -v /etc/named.conf:/etc/named.conf:ro -v /etc/named.rfc1912.zones:/etc/named.rfc1912.zones:ro -v /etc/named.root.key:/etc/named.root.key:ro -v /var/log/bind.log:/var/log/bind.log --mount=type=bind,src=/dev/log,dst=/dev/log --name=bind bind 
sleep 3
podman generate systemd --new --files --name php-fpm
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-php-fpm
