source /config/podman/common/common.sh
stop_container clamd
directories="$datadir/run/clamd.scan $datadir/var/spool/amavisd/tmp $datadir/var/lib/clamav $datadir/run/clamd.amavisd"
for directory in $directories; do
  mkdir -p $directory
done
chown 995 $datadir/run/clamd.scan
podman  run -d --network ipv6 --ip6 fd00::8 --ip 10.89.0.8 -h $(hostname) \
$label \
-v $gitlocation/etc/clamd.d:/etc/clamd.d:ro \
-v $datadir/run/clamd.scan/:/run/clamd.scan/:z \
-v $datadir/var/spool/amavisd/tmp/:/var/spool/amavisd/tmp/:z \
-v $datadir/var/lib/clamav:/var/lib/clamav:ro \
-v $datadir/run/clamd.amavisd:/run/clamd.amavisd \
--mount=type=bind,src=/dev/log,dst=/dev/log \
--hosts-file $gitlocation/podman/common/hosts \
--name=clamd \
$registry/clamd-root:latest
sleep 3
configure_systemd_service clamd

