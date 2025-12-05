tmp=$(mktemp -d)
yum install -y --nodocs --installroot=$tmp --nogpgcheck bind | tee install.out
rm -rf $tmp/var/cache/dnf
rm -rf $tmp/var/lib/dnf
rm -rf $tmp/usr/share/man
rm -rf $tmp/usr/share/doc
rm -rf $tmp/usr/lib/.build-id
rm -rf $tmp/var/log/dnf*
tar zcvf root-named.tgz -C $tmp .  | tee -a install.out
podman import root-named.tgz root-named:latest | tee -a install.out
rm -rf $tmp
