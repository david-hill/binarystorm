source /root/binarystorm/podman/common/common.sh
basename=$(pwd | xargs basename)
rpm -qi podman > /dev/null
if [ $? -ne 0 ]; then
  yum install -y podman shadow-utils
fi
podman run -it --privileged --rm --entrypoint="[\"/usr/bin/bash\", \"/root/binarystorm/podman/$basename/buildroot.sh\"]" -v /root/binarystorm/podman:/root/binarystorm/podman:rw centos:stream10
exit $?
