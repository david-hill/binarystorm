systemctl | grep freshclam
if [ $? -eq 0 ]; then
	systemctl disable freshclam
	systemctl stop freshclam
fi
podman ps -a | grep freshclam
if [ $? -eq 0 ]; then
  podman stop freshclam
  podman rm freshclam
fi
chown 995 /run/clamd.scan
podman  run -d --network ipv6 --ip6 fd00::10 --ip 10.89.0.10 -h $(hostname) -v /etc/freshclam.conf:/etc/freshclam.conf:ro -v /var/lib/clamav:/var/lib/clamav --mount=type=bind,src=/dev/log,dst=/dev/log --hosts-file ../common/hosts --name=freshclam freshclam-root:latest
sleep 3
podman generate systemd --new --files --name freshclam
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-freshclam

