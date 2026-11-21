source /config/podman/common/common.sh
rc=0
for image in $( podman images | grep -v latest  | grep root  | awk '{ print $1 }' ); do
   imagename=${image#*/}
   tag=$( podman images | grep -v latest | grep root | grep $image | awk '{ print $2 }' | head -1)
   echo "Pushing $image:$tag to $registry/$imagename:$tag"
   podman push $image:$tag $registry/$imagename:$tag
   if [ $? -eq 0 ]; then
     echo "Pushing $image:$tag to $registry/$imagename:latest"
     podman push $image:$tag $registry/$imagename:latest
     if [ $? -eq 0 ]; then
       echo "Deleting local copy"
       podman rmi $image:$tag
     else
       rc=1
     fi
   else
     rc=1
   fi
done

exit $rc
