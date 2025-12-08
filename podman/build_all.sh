for dir in *; do
  if [ -d $dir ]; then
    cd $dir
    bash buildroot.sh
#    bash build.sh
    cd ..
  fi
done
