for dir in *; do
  if [ -d $dir ]; then
    cd $dir
    bash start.sh
    cd ..
  fi
done
