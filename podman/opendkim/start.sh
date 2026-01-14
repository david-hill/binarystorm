source /root/binarystorm/podman/common/common.sh
systemctl | grep -v container | grep opendkim
if [ $? -eq 0 ]; then
	systemctl disable opendkim
	systemctl stop opendkim
fi
podman ps -a | grep opendkim
if [ $? -eq 0 ]; then
  podman stop opendkim
  podman rm opendkim
  podman pull $registry/opendkim-root:latest
fi
chgrp -R 998 /etc/opendkim/keys
podman  run -d --network ipv6 --ip6 fd00::12 --ip 10.89.0.12 -p 8891:8891/tcp -h $(hostname) \
-v $gitlocation/etc/opendkim.conf:/etc/opendkim.conf:ro \
-v $gitlocation/etc/opendkim/TrustedHosts:/etc/opendkim/TrustedHosts:ro \
-v $gitlocation/etc/opendkim/SigningTable:/etc/opendkim/SigningTable:ro \
-v $gitlocation/etc/opendkim/KeyTable:/etc/opendkim/KeyTable:ro \
-v /etc/opendkim/keys:/etc/opendkim/keys:ro \
--mount=type=bind,src=/dev/log,dst=/dev/log \
--hosts-file $gitlocation/podman/common/hosts \
--name=opendkim \
$registry/opendkim-root:latest
sleep 3
podman generate systemd --new --files --name opendkim
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-opendkim

