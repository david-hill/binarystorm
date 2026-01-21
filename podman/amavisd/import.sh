source /root/binarystorm/podman/common/common.sh
service=amavisd
entrypoint='ENTRYPOINT ["/usr/sbin/amavisd","-c","/etc/amavisd/amavisd.conf","foreground"]'
import_container
