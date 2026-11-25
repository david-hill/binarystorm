source /config/podman/common/common.sh
stop_container named
podman network ls | grep ipv6
if [ $? -ne 0 ]; then
  podman network create  --ipv6 ipv6 --gateway fd00::1 --subnet fd00:0000:0000:0000:0000:0000:0000:0000/120 --gateway 10.89.0.1 --subnet 10.89.0.0/16 --disable-dns
fi
directories="$datadir/var/named/dynamic $datadir/var/named/data $datadir/var/named $datadir/var/log"
for directory in $directories; do
  mkdir -p $directory
done
touch $datadir/var/log/named.log
chown 25:25 $datadir/var/log/named.log
chown -R 25:25 $datadir/var/named
if myrelease 45; then
portargs=''
else
portargs='-p [::]:53:53/tcp -p [::]:53:53/udp'
fi
podman  run -d --network ipv6 --ip6 fd00::2 --ip 10.89.0.2 -p 53:53/udp -p 53:53/tcp \
$label \
-v $gitlocation/etc/named:/etc/named:ro \
-v $gitlocation/etc/named.conf:/etc/named.conf:ro \
-v $datadir/var/named:/var/named:z \
-v $datadir/var/log/named.log:/var/log/named.log:z \
--mount=type=bind,src=/dev/log,dst=/dev/log \
--name=named \
$registry/named-root:latest
sleep 3
configure_systemd_service named
