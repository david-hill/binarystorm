source conf
curl -sS $registry/v2/$1/tags/list | jq .tags
