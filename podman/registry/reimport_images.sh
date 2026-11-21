source /config/podman/common/common.sh

for dir in ../*; do
  if [ -d $dir ]; then
    cd $dir
    if [ -e import.sh ]; then
      bash import.sh | tee -a /root/binarystorm/podman/build_all_from_root.log
    fi
  fi
done

cd ../registry
bash push_local_images_to_registry.sh
