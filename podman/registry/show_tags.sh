source /root/binarystorm/podman/common/common.sh
curl -sS $registry/v2/$1/tags/list | jq .tags
