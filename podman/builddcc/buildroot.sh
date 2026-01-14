<<<<<<< HEAD
if bash /root/binarystorm/podman/builddcc/check_new_version.sh; then
  source /root/binarystorm/podman/common/common.sh
  packages="gcc curl tar rpm-build vim procps-ng perl-interpreter"
  service=builddcc
  entrypoint='ENTRYPOINT ["/bin/bash", "/builddcc.sh"]'
#  entrypoint='ENTRYPOINT ["/bin/bash"]'
  build_container
fi
=======
source ../common/common.sh
packages="gcc curl tar rpm-build vim procps-ng perl-interpreter"
service=builddcc
entrypoint='ENTRYPOINT ["/bin/bash", "/builddcc.sh"]'
#entrypoint='ENTRYPOINT ["/bin/bash"]'
build_container
>>>>>>> cc37894 (Adding dcc RPMS building scripts.)
