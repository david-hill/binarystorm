systemctl | grep saslauthd
if [ $? -eq 0 ]; then
        systemctl disable saslauthd
        systemctl stop saslauthd
fi
podman ps -a | grep saslauthd
if [ $? -eq 0 ]; then
  podman stop saslauthd
  podman rm saslauthd
fi
chmod 755 /run/saslauthd
podman  run -d --network ipv6 --ip6 fd00::9 --ip 10.89.0.9 -h $(hostname) -v /etc/sasl2:/etc/sasl2:ro -v /etc/sasldb2:/etc/sasldb2:ro -v /run/saslauthd:/run/saslauthd --mount=type=bind,src=/dev/log,dst=/dev/log --name=saslauthd saslauthd-root:latest 
sleep 3
podman generate systemd --new --files --name saslauthd
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-saslauthd

