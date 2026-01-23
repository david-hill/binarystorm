#!/bin/bash -e

function configure_firewall {
  ports="161/udp"
  reload=0
  for p in $ports; do
    add_port $p
    reload $?
  done
  if [ $reload -eq 1 ]; then
    firewall-cmd --reload
  fi
}


function add_port {
  lreload=0
  firewall-cmd --list-all | grep -q " $1"
  if [ $? -ne 0 ]; then
    firewall-cmd --permanent --zone=public --add-port=$1
    lreload=1
  fi
 return $lreload
}

configure_firewall
