source conf
rpm -qi skopeo > /dev/null
if [ $? -ne 0 ]; then
  yum install -y skopeo
fi

remotesha=$(skopeo inspect docker://$registry/httpd-root:latest | jq .Digest)
# "sha256:8858f5ccdb7f8acf6c7b8143612dbfc2d14dcba40ed6fafbab9fd3e1e6b8436b"
localsha=$(podman inspect $registry/httpd-root:latest 2>/dev/null | jq .[]."Digest")
# "sha256:8858f5ccdb7f8acf6c7b8143612dbfc2d14dcba40ed6fafbab9fd3e1e6b8436b"

if [[ $remotesha == $localsha ]]; then
	echo identical
else
	echo different
fi

