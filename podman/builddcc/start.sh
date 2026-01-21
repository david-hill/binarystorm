source /root/binarystorm/podman/common/common.sh
podman ps -a | grep -q builddcc
if [ $? -eq 0 ]; then
  podman rm builddcc
fi
podman run -v /root/binarystorm/podman/builddcc/builddcc.sh:/builddcc.sh:ro -v /root/binarystorm/podman/builddcc/buildcomment:/buildcomment -v /root/binarystorm/podman/builddcc/dcc.spec:/dcc.spec:rw -v /root/binarystorm/podman/builddcc/index:/index:rw -v /root/binarystorm/podman/builddcc/rpms:/root/rpmbuild/RPMS/x86_64:rw --mount=type=bind,src=/dev/log,dst=/dev/log --hosts-file ../common/hosts --name=builddcc $registry/builddcc-root:latest

