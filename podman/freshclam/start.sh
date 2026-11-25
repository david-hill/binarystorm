source /config/podman/common/common.sh
stop_container freshclam
directories="$datadir/run/clamd.scan $datadir/var/spool/amavisd/tmp $datadir/var/lib/clamav $datadir/run/clamd.amavisd"
for directory in $directories; do
  mkdir -p $directory
done
chown 995 $datadir/run/clamd.scan
chown 995 $datadir/var/lib/clamav
podman run -d --network ipv6 --ip6 fd00::10 --ip 10.89.0.10 -h $(hostname) \
$label \
-v $gitlocation/etc/freshclam.conf:/etc/freshclam.conf:ro \
-v $datadir/var/lib/clamav:/var/lib/clamav:z \
--mount=type=bind,src=/dev/log,dst=/dev/log \
--hosts-file $gitlocation/podman/common/hosts \
--name=freshclam \
$registry/freshclam-root:latest
sleep 3
configure_systemd_service freshclam

