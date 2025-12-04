podman stop cyrus-imapd
podman rm cyrus-imapd
podman  run -d --network ipv6 --ip6 fd00::5 --ip 10.89.0.5 -p 995:995/tcp -p 993:993/tcp -p 143:143/tcp -p 110:110/tcp -p [::]:995:995/tcp -p [::]:993:993/tcp -p [::]:143:143/tcp -p [::]:110:110/tcp -h $(hostname) -v /var/lib/imap:/var/lib/imap -v /var/spool/imap:/var/spool/imap -v /usr/sbin/sendmail.postfix:/usr/sbin/sendmail.postfix:ro -v /etc/pki/cyrus-imapd:/etc/pki/cyrus-imapd:ro -v /etc/pki/tls/certs:/etc/pki/tls/certs:ro -v /etc/imapd.conf:/etc/imapd.conf:ro -v /etc/cyrus.conf:/etc/cyrus.conf:ro -v /etc/sasl2:/etc/sasl2:ro -v /etc/sasldb2:/etc/sasldb2:ro -v /run/saslauthd:/run/saslauthd --mount=type=bind,src=/dev/log,dst=/dev/log --name=cyrus-imapd cyrus-imapd 
sleep 3
podman generate systemd --new --files --name cyrus-imapd
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-cyrus-imapd

