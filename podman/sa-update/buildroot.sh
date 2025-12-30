source ../common/common.sh
tmp=$(mktemp -d)
packages="spamassassin cronie curl"
service=sa-update
entrypoint='ENTRYPOINT ["/usr/sbin/crond", "-f", "-s"]'
build_container
