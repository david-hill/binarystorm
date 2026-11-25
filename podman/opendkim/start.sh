source /config/podman/common/common.sh
stop_container opendkim
chgrp -R 998 /etc/opendkim/keys
podman  run -d --network ipv6 --ip6 fd00::12 --ip 10.89.0.12 -p 8891:8891/tcp -h $(hostname) \
$label \
-v $gitlocation/etc/opendkim.conf:/etc/opendkim.conf:ro \
-v $gitlocation/etc/opendkim/TrustedHosts:/etc/opendkim/TrustedHosts:ro \
-v $gitlocation/etc/opendkim/SigningTable:/etc/opendkim/SigningTable:ro \
-v $gitlocation/etc/opendkim/KeyTable:/etc/opendkim/KeyTable:ro \
-v $datadir/etc/opendkim/keys:/etc/opendkim/keys:ro \
--mount=type=bind,src=/dev/log,dst=/dev/log \
--hosts-file $gitlocation/podman/common/hosts \
--name=opendkim \
$registry/opendkim-root:latest
sleep 3
configure_systemd_service opendkim
