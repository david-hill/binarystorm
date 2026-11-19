for p in *; do 
  if [ -d $p ] && [[ ! "$p" =~ "common" ]] && [[ ! "$p" =~ "builddcc" ]] ; then 
    echo -n $p
    if $(podman ps | grep -q $p); then 
      echo " UP"
    else
      echo " XXX"
    fi 
  fi
done
