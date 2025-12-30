source ../common/common.sh
tmp=$(mktemp -d)
packages=clamav-freshclam
service=freshclam
entrypoint='ENTRYPOINT ["/usr/bin/freshclam", "-d", "--foreground=true"]'
build_container
