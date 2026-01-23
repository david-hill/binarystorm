source /root/binarystorm/podman/common/common.sh
systemctl | grep -q postfix
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
  mkdir -p /var/spool/postfix/$directory
done
chown -R 89:90 /var/spool/postfix
podman  run -d --network ipv6 --ip6 fd00::3 --ip 10.89.0.3 -p 25:25/tcp -p [::]:25:25/tcp -p 587:587/tcp -p [::]:587:587/tcp -h $(hostname) \
-v /root/binarystorm/etc/postfix/main.cf:/etc/postfix/main.cf:ro \
-v /root/binarystorm/etc/postfix/master.cf:/etc/postfix/master.cf:ro \
-v /root/binarystorm/etc/postfix/virtual.lmdb:/etc/postfix/virtual.lmdb:ro \
-v /etc/postfix/keys:/etc/postfix/keys:ro \
-v /var/spool/postfix:/var/spool/postfix \
-v /root/binarystorm/etc/imapd.conf:/etc/imapd.conf:ro \
-v /var/lib/imap:/var/lib/imap \
-v /root/binarystorm/etc/aliases.lmdb:/etc/aliases.lmdb:ro \
-v /root/binarystorm/etc/sasl2:/etc/sasl2:ro \
-v /run/saslauthd:/run/saslauthd \
--mount=type=bind,src=/dev/log,dst=/dev/log \
--hosts-file ../common/hosts \
--name=postfix \
$registry/postfix-root:latest
sleep 3
podman generate systemd --new --files --name postfix
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-postfix

