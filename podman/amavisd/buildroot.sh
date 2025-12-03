tmp=$(mktemp -d)
yum install -y --installroot=$tmp --nogpgcheck amavis perl-Razor-Agent pyzor | tee install.out
tar zcvf amavisd-root.tgz -C $tmp . | tee -a install.out
podman import amavisd-root.tgz amavisd-root:latest | tee -a install.out
rm -rf $tmp
