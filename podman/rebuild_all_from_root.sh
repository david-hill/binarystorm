set -o pipefail
echo "Rebuilding all container images" | tee /config/podman/build_all_from_root.log
find -name \*.tgz -exec rm -rf {} \;
for dir in *; do
  if [ -d $dir ]; then
    if [[ $dir == "root" ]]; then
      continue
    fi
    cd $dir
    if [ -e buildroot.sh ]; then
      echo $dir | tee -a /config/podman/build_all_from_root.log
      bash /config/podman/root/buildroot.sh | tee -a /config/podman/build_all_from_root.log
      if [ $? -eq 0 ]; then
         echo "Nothing changed" | tee -a /config/podman/build_all_from_root.log
      elif [ -e import.sh ]; then
	 bash import.sh | tee -a /config/podman/build_all_from_root.log
      fi
    fi
    cd ..
  fi
done
echo "Task completed." | tee -a /config/podman/build_all_from_root.log
