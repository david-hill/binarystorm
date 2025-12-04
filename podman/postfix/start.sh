podman stop postfix
podman rm postfix
#podman --debug run  --net host -v /etc/named:/etc/named:ro -v /etc/named.ca:/etc/named.ca:ro  -v /etc/named.conf:/etc/named.conf:ro -v /etc/named.rfc1912.zones:/etc/named.rfc1912.zones:ro -v /etc/named.root.key:/etc/named.root.key:ro --name=bind bind  &
podman  run -d --network ipv6 --ip6 fd00::3 --ip 10.89.0.3 -p 25:25/tcp -p [::]:25:25/tcp -h $(hostname) -v /etc/postfix:/etc/postfix:ro -v /var/spool/postfix:/var/spool/postfix -v /var/lib/imap/socket/lmtp:/var/lib/imap/socket/lmtp -v /etc/imapd.conf:/etc/imapd.conf:ro -v /var/lib/imap:/var/lib/imap -v /etc/aliases.lmdb:/etc/aliases.lmdb:ro --mount=type=bind,src=/dev/log,dst=/dev/log --name=postfix postfix 
sleep 3
podman generate systemd --new --files --name postfix
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-postfix

