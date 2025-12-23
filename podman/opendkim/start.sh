source ../common/common.sh
systemctl | grep opendkim
if [ $? -eq 0 ]; then
	systemctl disable opendkim
	systemctl stop opendkim
fi
podman ps -a | grep opendkim
if [ $? -eq 0 ]; then
  podman stop opendkim
  podman rm opendkim
fi
if [ ! -e /etc/imapd.conf ]; then
  touch /etc/imapd.conf
fi
podman  run -d --network ipv6 --ip6 fd00::12 --ip 10.89.0.12 -p 8891:8891/tcp -h $(hostname) -v /etc/opendkim.conf:/etc/opendkim.conf:ro -v /etc/opendkim:/etc/opendkim:ro --mount=type=bind,src=/dev/log,dst=/dev/log --hosts-file ../common/hosts --name=opendkim $registry/opendkim-root:latest
sleep 3
podman generate systemd --new --files --name opendkim
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-opendkim

