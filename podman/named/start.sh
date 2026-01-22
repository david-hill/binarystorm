source /root/binarystorm/podman/common/common.sh
systemctl | grep named.service
if [ $? -eq 0 ]; then
  systemctl stop named
  systemctl disable named
fi
podman network ls | grep ipv6
if [ $? -ne 0 ]; then
  podman network create  --ipv6 ipv6 --gateway fd00::1 --subnet fd00:0000:0000:0000:0000:0000:0000:0000/120 --gateway 10.89.0.1 --subnet 10.89.0.0/16 --disable-dns
fi
podman ps -a | grep named
if [ $? -eq 0 ]; then
  podman stop named
  podman rm named
  podman pull $registry/named-root:latest
fi
directories="/var/named/dynamic /var/named/data /var/named"
for directory in $directories; do
  mkdir -p $directory
done
touch /var/log/named.log
chown 25:25 /var/log/named.log
chown -R 25:25 /var/named
podman  run -d --network ipv6 --ip6 fd00::2 --ip 10.89.0.2 -p 53:53/udp -p 53:53/tcp -p [::]:53:53/udp -p [::]:53:53/tcp -v /var/named:/var/named -v /root/binarystorm/etc/named:/etc/named:ro -v /root/binarystorm/etc/named.conf:/etc/named.conf:ro -v /var/log/named.log:/var/log/named.log --mount=type=bind,src=/dev/log,dst=/dev/log --name=named $registry/named-root:latest
sleep 3
podman generate systemd --new --files --name named
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-named
