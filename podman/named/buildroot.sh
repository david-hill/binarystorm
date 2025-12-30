source ../common/common.sh
tmp=$(mktemp -d)
packages=bind
service=named
entrypoint='ENTRYPOINT ["/usr/sbin/named", "-f", "-u", "named", "-c", "/etc/named.conf"]'
build_container
