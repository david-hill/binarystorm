podman ps -a | grep builddcc | awk '{ print $1 }' | xargs podman rm
podman images | grep builddcc | awk '{ print $3 }' | xargs podman rmi
