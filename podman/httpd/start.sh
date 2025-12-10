# podman network create  --ipv6 ipv6 --gateway fd00::::1 --subnet fd00:0000:0000:0000:0000:0000:0000:0000/120 --gateway 10.89.0.1 --subnet 10.89.0.0/16 --disable-dns
podman stop httpd
podman rm httpd
#podman --debug run  --net host -v /etc/named:/etc/named:ro -v /etc/named.ca:/etc/named.ca:ro  -v /etc/named.conf:/etc/named.conf:ro -v /etc/named.rfc1912.zones:/etc/named.rfc1912.zones:ro -v /etc/named.root.key:/etc/named.root.key:ro --name=bind bind  &
podman  run -d --network ipv6 --ip6 fd00::6 --ip 10.89.0.6 -p 80:80/tcp -p 443:443/tcp -p [::]:80:80/tcp -p [::]:443:443/tcp -v /etc/httpd:/etc/httpd:ro -v /var/www/html:/var/www/html:ro -v /etc/roundcubemail:/etc/roundcubemail:ro -v /usr/share/roundcubemail:/usr/share/roundcubemail:ro -v /var/lib/sql:/var/lib/sql -v /run/php-fpm/www.sock:/run/php-fpm/www.sock -v /var/lib/php:/var/lib/php:ro -v /etc/pki/tls/certs/localhost.crt:/etc/pki/tls/certs/localhost.crt:ro -v /etc/pki/tls/private/localhost.key:/etc/pki/tls/private/localhost.key:ro -v /var/log/httpd:/var/log/httpd --mount=type=bind,src=/dev/log,dst=/dev/log --name=httpd httpd-root:latest
#-p 53:53/udp -p 53:53/tcp 
#-v /var/named:/var/named -v /etc/named:/etc/named:ro -v /etc/named.ca:/etc/named.ca:ro  -v /etc/named.conf:/etc/named.conf:ro -v /etc/named.rfc1912.zones:/etc/named.rfc1912.zones:ro -v /etc/named.root.key:/etc/named.root.key:ro -v /var/log/bind.log:/var/log/bind.log --mount=type=bind,src=/dev/log,dst=/dev/log --name=bind bind 
sleep 3
podman generate systemd --new --files --name httpd
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-httpd

