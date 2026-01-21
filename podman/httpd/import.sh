source /root/binarystorm/podman/common/common.sh
service=httpd
entrypoint='ENTRYPOINT ["/usr/sbin/httpd","-DFOREGROUND"]'
import_container
