systemctl list-unit-files | grep ^container | awk '{ print $1 }' | xargs systemctl restart
