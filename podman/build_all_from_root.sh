set -o pipefail
args=''
if [[ $SHELLOPTS =~ xtrace ]]; then
  args="-x"
fi

changed=0
echo "Building all container images" | tee /config/podman/build_all_from_root.log
for dir in *; do
  if [ -d $dir ]; then
    if [[ $dir == "root" ]]; then
      continue
    fi
#    if [[ $dir != "amavisd" ]]; then
#	    continue
#    fi
    cd $dir
    if [ -e buildroot.sh ]; then
      echo $dir | tee -a /config/podman/build_all_from_root.log
      bash $args /config/podman/root/buildroot.sh | tee -a /config/podman/build_all_from_root.log
      if [ $? -eq 0 ]; then
         echo "Nothing changed" | tee -a /config/podman/build_all_from_root.log
      elif [ -e import.sh ]; then
      	 bash $args import.sh | tee -a /config/podman/build_all_from_root.log
         changed=1
      fi
    fi
    cd ..
  fi
done
echo "Task completed." | tee -a /config/podman/build_all_from_root.log
exit $changed
