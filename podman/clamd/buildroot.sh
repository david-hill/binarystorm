source ../common/common.sh
tmp=$(mktemp -d)
service=clamd
entrypoint='ENTRYPOINT ["/usr/sbin/clamd","-F","-c","/etc/clamd.d/amavisd.conf"]'
packages=clamd
build_container
