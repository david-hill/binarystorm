podman exec -it registry bin/registry garbage-collect /etc/distribution/config.yml
podman exec -it registry bin/registry garbage-collect /etc/distribution/config.yml --delete-untagged
