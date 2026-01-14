source /root/binarystorm/podman/common/common.sh
systemctl | grep -v container | grep -q postfix
if [ $? -eq 0 ]; then
	systemctl disable postfix
	systemctl stop postfix
fi
podman ps -a | grep -q postfix
if [ $? -eq 0 ]; then
  podman stop postfix
  podman rm postfix
  podman pull $registry/postfix-root:latest
fi
directories="active bounce corrupt defer deferred flush hold incoming maildrop pid private public saved trace"
for directory in $directories; do
  if [ ! -d  /var/spool/postfix/$directory ]; then
    mkdir -p /var/spool/postfix/$directory
  fi
done
chown -R 89:90 /var/spool/postfix
podman  run -d --network ipv6 --ip6 fd00::3 --ip 10.89.0.3 -p 25:25/tcp -p [::]:25:25/tcp -p 587:587/tcp -p [::]:587:587/tcp -h $(hostname) \
-v $gitlocation/etc/postfix/main.cf:/etc/postfix/main.cf:ro \
-v $gitlocation/etc/postfix/master.cf:/etc/postfix/master.cf:ro \
-v $gitlocation/etc/postfix/virtual.lmdb:/etc/postfix/virtual.lmdb:ro \
-v $gitlocation/etc/imapd.conf:/etc/imapd.conf:ro \
-v $gitlocation/etc/aliases.lmdb:/etc/aliases.lmdb:ro \
-v $gitlocation/etc/sasl2:/etc/sasl2:ro \
-v /etc/postfix/keys:/etc/postfix/keys:ro \
-v /var/spool/postfix:/var/spool/postfix \
-v /var/lib/imap:/var/lib/imap \
-v /run/saslauthd:/run/saslauthd \
--mount=type=bind,src=/dev/log,dst=/dev/log \
--hosts-file $gitlocation/podman/common/hosts \
--name=postfix \
$registry/postfix-root:latest
sleep 3
podman generate systemd --new --files --name postfix
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-postfix

