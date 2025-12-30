source ../common/common.sh
service=opendkim
packages=opendkim
entrypoint='ENTRYPOINT ["/usr/sbin/opendkim","-f"]'
build_container
