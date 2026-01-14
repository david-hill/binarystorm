if [ ! -d /root/rpmbuild/SOURCES ]; then
  mkdir -p /root/rpmbuild/SOURCES
fi
cd /root/rpmbuild/SOURCES
if [ ! -e dcc.tar.Z ]; then
  curl https://www.dcc-servers.net/dcc/source/dcc.tar.Z --output dcc.tar.Z
fi

#QA_SKIP_BUILD_ROOT=1 rpmbuild -ba /dcc.spec
rpmbuild -ba /dcc.spec

