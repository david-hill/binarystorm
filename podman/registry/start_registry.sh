if [ ! -d /var/lib/registry ]; then
  mkdir /var/lib/registry
fi
podman run -d --name registry -p 5000:5000 -v /etc/distribution/config.yml:/etc/distribution/config.yml:ro -v /var/lib/registry:/var/lib/registry --restart=always registry:latest

