source /config/podman/common/common.sh
basename=$(pwd | xargs basename)
rpm -qi podman > /dev/null
if [ $? -ne 0 ]; then
  yum install -y podman shadow-utils
fi
podman run -it --privileged --rm --entrypoint="[\"/usr/bin/bash\", \"/config/podman/$basename/buildroot.sh\"]" -v /config/podman:/config/podman:rw centos:stream10
exit $?
