podman images | grep none | awk '{ print $3 }' | xargs podman rmi
