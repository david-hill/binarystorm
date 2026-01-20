for dir in *; do
  if [ -d $dir ]; then
    cd $dir
    if [ -e start.sh ]; then
      bash start.sh
    fi
    cd ..
  fi
done
