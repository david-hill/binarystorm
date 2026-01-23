source /root/binarystorm/podman/common/common.sh
if [ ! -e $scriptlocation/current_version ]; then
	current_version=''
else
	current_version=$( cat $scriptlocation/current_version )
fi

version=$(curl -I  https://www.dcc-servers.net/dcc/source/dcc.tar.Z 2>/dev/null| grep Last-Modified)

if [[ $current_version != $version ]]; then
	echo "A new version is available"
	echo $version > current_version
	exit 0
else
	echo "Same old version"
	exit 1
fi
