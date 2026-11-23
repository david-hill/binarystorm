set -o pipefail
args=''
if [[ $SHELLOPTS =~ xtrace ]]; then
  args="-x"
fi
changed=0
logfile=/config/podman/rebuild_all_from_root.log
echo "Rebuilding all container images" | tee $logfile
find -name \*.tgz -exec rm -rf {} \;
for dir in *; do
  if [ -d $dir ]; then
    if [[ $dir == "root" ]]; then
      continue
    fi
    cd $dir
    if [ -e buildroot.sh ]; then
      echo $dir | tee -a $logfile
      bash $args /config/podman/root/buildroot.sh | tee -a $logfile
      if [ $? -eq 0 ]; then
        echo "Nothing changed" | tee -a $logfile
      elif [ -e import.sh ]; then
        bash $args import.sh | tee -a $logfile
        changed=1
      fi
    fi
    cd ..
  fi
done
if [ $changed -eq 1 ]; then
  msg="Don't forget to push local images to registry."
fi
echo "Task completed.  $msg" | tee -a $logfile
exit $changed
