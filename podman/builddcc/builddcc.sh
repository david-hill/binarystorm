<<<<<<< HEAD
set -ex
if [ ! -d /root/rpmbuild/SOURCES ]; then
  mkdir -p /root/rpmbuild/SOURCES
fi
if [ ! -d /root/rpmbuild/SPECS ]; then
  mkdir -p /root/rpmbuild/SPECS
fi
=======
if [ ! -d /root/rpmbuild/SOURCES ]; then
  mkdir -p /root/rpmbuild/SOURCES
fi
>>>>>>> cc37894 (Adding dcc RPMS building scripts.)
cd /root/rpmbuild/SOURCES
if [ ! -e dcc.tar.Z ]; then
  curl https://www.dcc-servers.net/dcc/source/dcc.tar.Z --output dcc.tar.Z
fi

<<<<<<< HEAD
specfile=/root/rpmbuild/SPECS/dcc.spec
cp /dcc.spec $specfile
#QA_SKIP_BUILD_ROOT=1 rpmbuild -ba /dcc.spec
version=$(tar ztf dcc.tar.Z | head -1 | xargs dirname)
version=${version/*-/}
current_version=$( grep ^Version: /dcc.spec | awk -F: '{ print $2 }' | sed -e 's/ //g')
if [[ $current_version != $version ]]; then
  sed -i "s/^Version:        .*/Version:        $version/" $specfile
  inc=0
else
  inc=$( cat /index )
  inc=$(( $inc + 1 ))
fi
echo $inc > /index
sed -i "s/^Release:        .*/Release:        $inc\%{\?dist}/" $specfile
date=$(date "+%a %b %d %Y")
buildcomment=$( cat /buildcomment )
sed -i "s/^%changelog/%changelog\n* $date David Hill <dhill@redhat.com> - $version-$inc\n- $buildcomment\n/" $specfile
rpmbuild -ba $specfile
if [ $? -eq 0 ]; then
   cp $specfile /dcc.spec
fi
=======
#QA_SKIP_BUILD_ROOT=1 rpmbuild -ba /dcc.spec
rpmbuild -ba /dcc.spec

>>>>>>> cc37894 (Adding dcc RPMS building scripts.)
