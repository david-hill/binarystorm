source ../common/common.sh
tmp=$(mktemp -d)
service=amavisd
packages="amavis perl-Razor-Agent pyzor dcc"
entrypoint='ENTRYPOINT ["/usr/sbin/amavisd","-c","/etc/amavisd/amavisd.conf","foreground"]'
build_container
