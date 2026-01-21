source /root/binarystorm/podman/common/common.sh
service=saslauthd
entrypoint='ENTRYPOINT ["/usr/sbin/saslauthd","-d","-m","/run/saslauthd","-a","pam"]'
import_container
