source /config/podman/common/common.sh
stop_container amavisd
directories="db quarantine tmp"
for directory in $directories; do
  mkdir -p $datadir/var/spool/amavisd/$directory
done
mkdir -p $datadir/run/amavisd
chown 995 $datadir/run/amavisd
chown 995 $datadir/var/spool/amavisd -R
chgrp 998 $datadir/var/lib/clamav -R
chgrp -R 998 $datadir/run/clamd.scan
podman  run -d -h $(hostname) --network ipv6 --ip6 fd00::4 --ip 10.89.0.4 \
$label \
-v $gitlocation/etc/mail/spamassassin/local.cf:/etc/mail/spamassassin/local.cf:ro \
-v $gitlocation/etc/mail/spamassassin/v310.pre:/etc/mail/spamassassin/v310.pre:ro \
-v $gitlocation/etc/amavisd:/etc/amavisd:ro \
-v $gitlocation/podman/common/etc/resolv.conf:/etc/resolv.conf:ro \
-v $datadir/var/spool/amavisd:/var/spool/amavisd:z \
-v $datadir/var/lib/spamassassin:/var/lib/spamassassin:ro \
-v $datadir/run/amavisd:/run/amavisd:z \
-v $datadir/run/clamd.scan:/run/clamd.scan:z \
-v $datadir/var/lib/clamav:/var/lib/clamav:ro \
--mount=type=bind,src=/dev/log,dst=/dev/log \
--hosts-file $gitlocation/podman/common/hosts \
--name=amavisd \
$registry/amavisd-root:latest
sleep 3
configure_systemd_service amavisd

