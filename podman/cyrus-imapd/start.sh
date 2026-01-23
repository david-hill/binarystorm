source /root/binarystorm/podman/common/common.sh
podman ps -a | grep -q cyrus-imapd
if [ $? -eq 0 ]; then
  podman stop cyrus-imapd
  podman rm cyrus-imapd
  podman pull $registry/cyrus-imapd-root:latest
fi
directories="/var/spool/imap /var/lib/imap"
for directory in $directories; do
  if [ ! -d $directory ]; then
    mkdir -p $directory
  fi
done
chown 76 /var/spool/imap
chmod 700 /var/spool/imap
chown 76:12 /var/lib/imap
chmod 750 /var/lib/imap
podman  run -d --network ipv6 --ip6 fd00::5 --ip 10.89.0.5 -p 995:995/tcp -p 993:993/tcp -p 143:143/tcp -p 110:110/tcp -p [::]:995:995/tcp -p [::]:993:993/tcp -p [::]:143:143/tcp -p [::]:110:110/tcp -h $(hostname) \
-v /var/lib/imap:/var/lib/imap \
-v /var/spool/imap:/var/spool/imap \
-v /etc/pki/cyrus-imapd:/etc/pki/cyrus-imapd:ro \
-v /etc/pki/tls/certs:/etc/pki/tls/certs:ro \
-v /root/binarystorm/etc/imapd.conf:/etc/imapd.conf:ro \
-v /root/binarystorm/etc/cyrus.conf:/etc/cyrus.conf:ro \
-v /etc/sasl2:/etc/sasl2:ro \
-v /etc/sasldb2:/etc/sasldb2:ro \
-v /run/saslauthd:/run/saslauthd \
--mount=type=bind,src=/dev/log,dst=/dev/log \
--name=cyrus-imapd \
$registry/cyrus-imapd-root:latest 
sleep 3
podman generate systemd --new --files --name cyrus-imapd
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-cyrus-imapd

