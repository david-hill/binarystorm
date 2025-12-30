source ../common/common.sh
packages="cyrus-sasl cyrus-imapd postfix" 
service=saslauthd
entrypoint='ENTRYPOINT ["/usr/sbin/saslauthd","-d","-m","/run/saslauthd","-a","pam"]'
build_container
