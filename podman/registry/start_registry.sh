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
if $( podman ps -f name=registry | grep -q registry); then
  if $( systemctl is-active --quiet container-registry ); then
    systemctl stop container-registry
  else
    podman stop registry > /dev/null
    podman rm registry > /dev/null
  fi
fi
echo -n "Starting registry in $permission mode... "
podman run -d --replace --name registry -p 5000:5000 -v /config/etc/distribution/config.yml:/etc/distribution/config.yml:ro -v /var/lib/registry:/var/lib/registry:$permission  localhost/registry:latest > /dev/null
if [ $? -eq 0 ]; then
  podman generate systemd --new --files --name registry > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    cp *.service /etc/systemd/system
    systemctl daemon-reload
    systemctl enable container-registry
    echo "done."
  else
    echo "failed."
  fi
fi
