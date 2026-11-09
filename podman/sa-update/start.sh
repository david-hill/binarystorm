source /config/podman/common/common.sh
systemctl | grep -v container | grep \ sa-update
if [ $? -eq 0 ]; then
  systemctl disable sa-update
  systemctl stop sa-update
fi
podman ps -a | grep sa-update
if [ $? -eq 0 ]; then
  podman stop sa-update
  podman rm sa-update
  podman pull $registry/sa-update-root:latest
fi
if [ ! -d $datadir/var/lib/spamassassin ]; then
  mkdir -p $datadir/var/lib/spamassassin
fi
podman  run -d -h $(hostname) --network ipv6 --ip6 fd00::11 --ip 10.89.0.11 \
-v $gitlocation/etc/mail/spamassassin/local.cf:/etc/mail/spamassassin/local.cf:ro \
-v $datadir/var/lib/spamassassin:/var/lib/spamassassin:z \
-v /var/spool/postfix:/var/spool/postfix \
--mount=type=bind,src=/dev/log,dst=/dev/log \
--hosts-file $gitlocation/podman/common/hosts \
--name=sa-update \
$registry/sa-update-root:latest
sleep 3
podman generate systemd --new --files --name sa-update
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-sa-update

