source ../common/common.sh
packages="postfix cyrus-imapd bind-utils cyrus-sasl-plain"
entrypoint='ENTRYPOINT ["/usr/sbin/postfix","start-fg"]'
service=postfix
build_container
