for image in $( bash show_catalog.sh  | grep \" | awk -F\" '{ print $2 }' ); do
  for manifest in $(  bash show_tags.sh $image | grep \" | awk -F \" '{ print $2 }' | tail -2 ); do
    bash delete_manifest.sh $image $manifest
  done
done
