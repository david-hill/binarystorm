bash build_all_from_root.sh
if [ $? -eq 1 ]; then
  cd registry
  bash start_registry.sh rw
  sleep 60
  bash push_local_images_to_registry.sh
  bash clean_local_images.sh
  bash clean_registry.sh
  sleep 60
  bash start_registry.sh
fi
