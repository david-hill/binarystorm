tmp=$(mktemp -d)
yum install -y --nodocs --installroot=$tmp --nogpgcheck bind iproute net-tools tcpdump iputils | tee install.out
tar zcvf root-bind.tgz -C $tmp .  | tee -a install.out
podman import root-bind.tgz root-bind:latest | tee -a install.out
rm -rf $tmp
