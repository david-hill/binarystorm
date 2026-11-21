source /config/podman/common/common.sh

for dir in ../*; do
  if [ -d $dir ]; then
    cd $dir
    if [ -e import.sh ]; then
      bash import.sh | tee -a /config/podman/import.out
    fi
  fi
done

cd ../registry
bash push_local_images_to_registry.sh
