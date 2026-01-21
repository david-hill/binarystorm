source /root/binarystorm/podman/common/common.sh
service=clamd
entrypoint='ENTRYPOINT ["/usr/sbin/clamd","-F","-c","/etc/clamd.d/amavisd.conf"]'
import_container
