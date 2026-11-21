source /root/binarystorm/podman/common/common.sh
podman rm cyrus-imapd
podman  run -it --entrypoint '/bin/bash' --network ipv6 --ip6 fd00::5 --ip 10.89.0.5 -p 995:995/tcp -p 993:993/tcp -p 143:143/tcp -p 110:110/tcp -p [::]:995:995/tcp -p [::]:993:993/tcp -p [::]:143:143/tcp -p [::]:110:110/tcp -h $(hostname) \
-v $gitlocation/etc/imapd.conf:/etc/imapd.conf:ro \
-v $gitlocation/etc/cyrus.conf:/etc/cyrus.conf:ro \
-v $gitlocation/etc/sasl2:/etc/sasl2:ro \
-v /var/lib/imap:/var/lib/imap \
-v /var/spool/imap:/var/spool/imap \
-v /etc/pki/cyrus-imapd:/etc/pki/cyrus-imapd:ro \
-v /etc/pki/tls/certs:/etc/pki/tls/certs:ro \
-v /etc/sasldb2:/etc/sasldb2:ro \
-v /run/saslauthd:/run/saslauthd \
--mount=type=bind,src=/dev/log,dst=/dev/log \
--name=cyrus-imapd \
$registry/cyrus-imapd-root:latest 
