args=''
if [[ $SHELLOPTS =~ xtrace ]]; then
  args="-x"
fi

yum update -y

bash $args build_all_from_root.sh
if [ $? -eq 1 ]; then
  cd registry
  bash $args start_registry.sh rw
  sleep 60
  bash $args push_local_images_to_registry.sh
  if [ $? -eq 0 ]; then
    bash $args clean_local_images.sh
    bash $args clean_registry.sh
  else
    echo "Failed to push image to registry"
  fi
  sleep 60
  bash $args start_registry.sh
fi
