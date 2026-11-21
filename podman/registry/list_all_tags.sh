source /config/podman/common/common.sh
for image in $(bash show_catalog.sh  | grep root | grep '"' | awk -F\" '{ print $2 }'); do
  echo $image
  for tag in $(bash show_tags.sh $image | grep '"' | grep -v latest | awk -F\" '{ print $2 }'); do
     echo "$tag"
  done
done

