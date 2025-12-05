source ../common/common.sh
tmp=$(mktemp -d)
yum install -y --nodocs --installroot=$tmp --nogpgcheck bind | tee install.out
cleanup_root
tar zcvf root-named.tgz -C $tmp .  | tee -a install.out
podman import root-named.tgz root-named:$creation_date | tee -a install.out
rm -rf $tmp
