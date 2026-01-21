source /root/binarystorm/podman/common/common.sh
service=php-fpm
entrypoint='ENTRYPOINT ["/usr/sbin/php-fpm","-F"]'
import_container
