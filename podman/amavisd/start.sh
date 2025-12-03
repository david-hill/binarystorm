podman stop amavisd
podman rm amavisd
#podman --debug run  --net host -v /etc/named:/etc/named:ro -v /etc/named.ca:/etc/named.ca:ro  -v /etc/named.conf:/etc/named.conf:ro -v /etc/named.rfc1912.zones:/etc/named.rfc1912.zones:ro -v /etc/named.root.key:/etc/named.root.key:ro --name=bind bind  &
#podman  run -d --publish 127.0.0.1:10024:10024/tcp -v /etc/amavisd:/etc/amavisd:ro -v /var/spool/amavisd:/var/spool/amavisd --mount=type=bind,src=/dev/log,dst=/dev/log --name=amavisd amavisd
podman  run -d -h $(hostname) --network ipv6 --ip6 fd00::4 --ip 10.89.0.4 -v /etc/mail:/etc/mail:ro -v /usr/local/bin/dccproc:/usr/local/bin/dccproc:ro -v /var/dcc:/var/dcc -v /etc/amavisd:/etc/amavisd:ro -v /var/spool/amavisd:/var/spool/amavisd -v /var/lib/spamassassin:/var/lib/spamassassin:ro -v /var/run/clamd.scan:/var/run/clamd.scan --mount=type=bind,src=/dev/log,dst=/dev/log --name=amavisd amavisd
sleep 10
podman generate systemd --new --files --name amavisd
