source /root/binarystorm/podman/common/common.sh
service=named
entrypoint='ENTRYPOINT ["/usr/sbin/named", "-f", "-u", "named", "-c", "/etc/named.conf"]'
import_container
