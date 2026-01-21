source /root/binarystorm/podman/common/common.sh
service=postfix
entrypoint='ENTRYPOINT ["/usr/sbin/postfix","start-fg"]'
import_container
