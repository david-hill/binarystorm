source ../common/common.sh
tmp=$(mktemp -d)
packages="cyrus-imapd cyrus-sasl-plain"
service=cyrus-imapd
entrypoint='ENTRYPOINT ["/usr/libexec/cyrus-imapd/master", "foreground"]'
build_container
