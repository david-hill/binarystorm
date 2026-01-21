source /root/binarystorm/podman/common/common.sh
service=opendkim
entrypoint='ENTRYPOINT ["/usr/sbin/opendkim","-f"]'
import_container
