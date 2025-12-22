source ../common/common.sh
systemctl | grep clamd
if [ $? -eq 0 ]; then
	systemctl disable clamd
	systemctl stop clamd
fi
podman ps -a | grep clamd
if [ $? -eq 0 ]; then
  podman stop clamd
  podman rm clamd
fi
chown 995 /run/clamd.scan
podman  run -d --network ipv6 --ip6 fd00::8 --ip 10.89.0.8 -h $(hostname) -v /etc/clamd.d:/etc/clamd.d:ro -v /var/run/clamd.scan/:/var/run/clamd.scan/ -v /var/spool/amavisd/tmp/:/var/spool/amavisd/tmp/ -v /var/lib/clamav:/var/lib/clamav:ro -v /run/clamd.amavisd:/run/clamd.amavisd --mount=type=bind,src=/dev/log,dst=/dev/log --hosts-file ../common/hosts --name=clamd clamd-root:latest
sleep 3
podman generate systemd --new --files --name clamd
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-clamd

