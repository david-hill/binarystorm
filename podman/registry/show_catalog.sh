source ../common/common.sh
curl -s -X GET $registry/v2/_catalog | jq .repositories
