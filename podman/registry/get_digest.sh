source /root/binarystorm/podman/common/common.sh
#curl -v -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' \
curl -s -H 'Accept: application/vnd.oci.image.manifest.v1+json' \
$registry/v2/$1/manifests/$2 | jq .
