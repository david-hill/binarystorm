source /root/binarystorm/podman/common/common.sh
for image in $(bash show_catalog.sh  | grep root | grep '"' | awk -F\" '{ print $2 }'); do
  for tag in $(bash show_tags.sh $image | grep '"' | grep -v latest | awk -F\" '{ print $2 }'| tail -1); do
    digesta=$(bash get_digest.sh $image $tag)
    digestb=$(bash get_digest.sh $image latest)
    if [ "$digesta" != "$digestb" ]; then
      podman pull $registry/$image:$tag
      podman push $registry/$image:$tag $registry/$image:latest
    else
      echo "$registry/$image:$tag is already the latest"
    fi
  done
done

