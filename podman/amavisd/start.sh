systemctl | grep \ amavis
if [ $? -eq 0 ]; then
  systemctl disable amavisd
  systemctl stop amavisd
fi
podman ps -a | grep amavisd
if [ $? -eq 0 ]; then
  podman stop amavisd
  podman rm amavisd
fi
chown 995 /var/spool/amavisd -R
chgrp -R 998 /run/clamd.scan
podman  run -d -h $(hostname) --network ipv6 --ip6 fd00::4 --ip 10.89.0.4 -v /etc/mail:/etc/mail:ro -v /usr/local/bin/dccproc:/usr/local/bin/dccproc:ro -v /var/dcc:/var/dcc -v /etc/amavisd:/etc/amavisd:ro -v /var/spool/amavisd:/var/spool/amavisd -v /var/lib/spamassassin:/var/lib/spamassassin:ro -v /var/run/clamd.scan:/var/run/clamd.scan --mount=type=bind,src=/dev/log,dst=/dev/log --name=amavisd amavisd-root:latest
sleep 3
podman generate systemd --new --files --name amavisd
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-amavisd

