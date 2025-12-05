systemctl | grep postfix
if [ $? -eq 0 ]; then
	systemctl disable postfix
	systemctl stop postfix
fi
podman ps -a | grep postfix
if [ $? -eq 0 ]; then
  podman stop postfix
  podman rm postfix
fi
podman  run -d --network ipv6 --ip6 fd00::3 --ip 10.89.0.3 -p 25:25/tcp -p [::]:25:25/tcp -h $(hostname) -v /etc/postfix:/etc/postfix:ro -v /var/spool/postfix:/var/spool/postfix -v /var/lib/imap/socket/lmtp:/var/lib/imap/socket/lmtp -v /etc/imapd.conf:/etc/imapd.conf:ro -v /var/lib/imap:/var/lib/imap -v /etc/aliases.lmdb:/etc/aliases.lmdb:ro --mount=type=bind,src=/dev/log,dst=/dev/log --name=postfix postfix-root:latest
sleep 3
podman generate systemd --new --files --name postfix
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-postfix

