if [ "$#" -gt 0 ]; then
  if [ $1 == "ro" ] || [ $1 == "rw" ]; then
    permission=$1
  else
    permission="ro"
  fi
else
  permission="ro"
fi

if [ ! -d /var/lib/registry ]; then
  mkdir /var/lib/registry
fi
podman run -d --replace --name registry -p 5000:5000 -v /root/binarystorm/etc/distribution/config.yml:/etc/distribution/config.yml:ro -v /var/lib/registry:/var/lib/registry:$permission --restart=always localhost/registry:latest

