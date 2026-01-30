podman ps -a | grep Exited | awk '{ print $1 }' | xargs podman rm
podman images | grep none | awk '{ print $3 }' | xargs podman rmi
podman images | grep localhost | grep -v registry | awk '{ print $3 }' | xargs podman rmi
podman images | grep registry.davidchill.ca | awk '{ print $3 }' | xargs podman rmi
