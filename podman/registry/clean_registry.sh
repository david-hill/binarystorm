keep=3

for repo in $( bash show_catalog.sh | grep -E -v "\[|\]"); do
  echo "--------------"
  repo=${repo/\"/}
  repo=${repo/\"/}
  repo=${repo/,/}
  tags=($( bash show_tags.sh $repo | grep -E -v "\[|\]"))
  count=${#tags[@]}
  inc=0
  for tag in "${tags[@]}"; do
    tag=${tag/\"/}
    tag=${tag/\"/}
    tag=${tag/,/}
    if (( $count > $keep )) && (( $count - $inc > $keep )); then
      inc=$(( $inc + 1 ))
      echo $tag
      echo delete $repo / $tag
      bash delete_manifest.sh $repo $tag
    else
      echo keep $repo / $tag
    fi
  done
done

bash garbage_collect.sh
