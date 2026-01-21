source /root/binarystorm/podman/common/common.sh
systemctl | grep -q \ amavis
if [ $? -eq 0 ]; then
  systemctl disable amavisd
  systemctl stop amavisd
fi
podman ps -a | grep -q amavisd
if [ $? -eq 0 ]; then
  podman stop amavisd
  podman rm amavisd
  podman pull $registry/amavisd-root:latest
fi
chown 995 /var/spool/amavisd -R
chgrp 998 /var/lib/clamav -R
chgrp -R 998 /run/clamd.scan
podman  run -d -h $(hostname) --network ipv6 --ip6 fd00::4 --ip 10.89.0.4 -v /etc/mail:/etc/mail:ro -v /var/dcc:/var/dcc -v /etc/amavisd:/etc/amavisd:ro -v /var/spool/amavisd:/var/spool/amavisd -v /var/lib/spamassassin:/var/lib/spamassassin:ro -v /var/run/clamd.scan:/var/run/clamd.scan -v /var/lib/clamav:/var/lib/clamav:ro --mount=type=bind,src=/dev/log,dst=/dev/log --hosts-file ../common/hosts --name=amavisd $registry/amavisd-root:latest
sleep 3
podman generate systemd --new --files --name amavisd
cp *.service /etc/systemd/system
systemctl daemon-reload
systemctl enable container-amavisd

