source ../common/common.sh
for image in $( podman images | grep -v latest  | grep root  | awk '{ print $1 }' ); do
   imagename=${image#*/}
   tag=$( podman images | grep -v latest | grep root | grep $image | awk '{ print $2 }' | head -1)
   echo "Pushing $image:$tag to $registry/$imagename:$tag"
   podman push $image:$tag $registry/$imagename:$tag
   echo "Pushing $image:$tag to $registry/$imagename:latest"
   podman push $image:$tag $registry/$imagename:latest
   echo "Deleting local copy"
   podman rmi $image:$tag
done
