source /root/binarystorm/podman/common/common.sh
service=cyrus-imapd
entrypoint='ENTRYPOINT ["/usr/libexec/cyrus-imapd/master", "foreground"]'
import_container
