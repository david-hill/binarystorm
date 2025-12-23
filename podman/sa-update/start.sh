source ../common/common.sh
systemctl | grep \ sa-update
if [ $? -eq 0 ]; then
  systemctl disable sa-update
  systemctl stop sa-update
fi
podman ps -a | grep sa-update
if [ $? -eq 0 ]; then
  podman stop sa-update
  podman rm sa-update
fi
podman  run -d -h $(hostname) --network ipv6 --ip6 fd00::11 --ip 10.89.0.11 -v /etc/mail:/etc/mail:ro -v /var/lib/spamassassin:/var/lib/spamassassin --mount=type=bind,src=/dev/log,dst=/dev/log --hosts-file ../common/hosts --name=sa-update $registry/sa-update-root:latest
sleep 3
podman generate systemd --new --files --name sa-update
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-sa-update

