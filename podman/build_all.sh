for dir in *; do
  cd $dir
  bash buildroot.sh
  bash build.sh
  cd ..
done
