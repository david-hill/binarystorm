source /root/binarystorm/podman/common/common.sh
service=freshclam
entrypoint='ENTRYPOINT ["/usr/bin/freshclam", "-d", "--foreground=true"]'
import_container
