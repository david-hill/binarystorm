# podman network create  --ipv6 ipv6 --gateway fd00::::1 --subnet fd00:0000:0000:0000:0000:0000:0000:0000/120 --gateway 10.89.0.1 --subnet 10.89.0.0/16 --disable-dns
podman stop bind
podman rm bind
#podman --debug run  --net host -v /etc/named:/etc/named:ro -v /etc/named.ca:/etc/named.ca:ro  -v /etc/named.conf:/etc/named.conf:ro -v /etc/named.rfc1912.zones:/etc/named.rfc1912.zones:ro -v /etc/named.root.key:/etc/named.root.key:ro --name=bind bind  &
touch /var/log/named.log
chown named:named /var/log/named.log
podman  run -d --network ipv6 --ip6 fd00::2 --ip 10.89.0.2 -p 53:53/udp -p 53:53/tcp -p [::]:53:53/udp -p [::]:53:53/tcp -v /var/named:/var/named -v /etc/named:/etc/named:ro -v /etc/named.ca:/etc/named.ca:ro  -v /etc/named.conf:/etc/named.conf:ro -v /etc/named.rfc1912.zones:/etc/named.rfc1912.zones:ro -v /etc/named.root.key:/etc/named.root.key:ro -v /var/log/named.log:/var/log/named.log --mount=type=bind,src=/dev/log,dst=/dev/log --name=bind bind 
#-p 53:53/udp -p 53:53/tcp 
#-v /var/named:/var/named -v /etc/named:/etc/named:ro -v /etc/named.ca:/etc/named.ca:ro  -v /etc/named.conf:/etc/named.conf:ro -v /etc/named.rfc1912.zones:/etc/named.rfc1912.zones:ro -v /etc/named.root.key:/etc/named.root.key:ro -v /var/log/bind.log:/var/log/bind.log --mount=type=bind,src=/dev/log,dst=/dev/log --name=bind bind 
sleep 10
podman generate systemd --new --files --name bind
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-bind
