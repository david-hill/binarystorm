for dir in *; do
  if [ -d $dir ]; then
    cd $dir
    if [ -e buildroot.sh ]; then
      bash buildroot.sh
    fi
#    bash build.sh
    cd ..
  fi
done
