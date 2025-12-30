creation_date=$(date '+%Y%m%d%H%M%S')
include="$tmp/var/cache/dnf $tmp/var/lib/dnf $tmp/usr/share/man $tmp/usr/share/doc $tmp/usr/lib/.build-id $tmp/var/log/dnf $tmp/var/log/hawkey"
registry=registry.davidchill.ca:5000
tmp=$(mktemp -d)

function cleanup_root {
  if [ ! -z $tmp ]; then
    rm -rf $tmp/var/cache/dnf
    rm -rf $tmp/var/lib/dnf
    rm -rf $tmp/usr/share/man
    rm -rf $tmp/usr/share/doc
    rm -rf $tmp/usr/lib/.build-id
    rm -rf $tmp/var/log/dnf*
    rm -rf $tmp/var/log/hawkey*
  fi
}

function build_container {
  if [ -e ${service}-root-diff.tgz ]; then
    tar xvf ${service}-root-diff.tgz -C $tmp
    tar xvf ${service}-root.tgz -C $tmp
    yum update -y --installroot=$tmp --nogpgcheck | tee install.out
  else
    yum install -y --installroot=$tmp --nogpgcheck $packages | tee install.out
  fi
  if declare -F customize_$service; then
    customize_$service
  fi
  tar zcvf ${service}-root-diff.tgz -C $tmp $include | tee -a install.out
  cleanup_root
  tar zcvf ${service}-root.tgz -C $tmp . | tee -a install.out
  import_container
  rm -rf $tmp
}

function customize_freshclam {
  chroot $tmp useradd -u 995 amavis | tee -a install.out
}

function customize_amavisd {
  chroot $tmp usermod -a -G virusgroup amavis  | tee -a install.out
}

function customize_clamd {
  chroot $tmp useradd -u 995 amavis | tee -a install.out
}
function customize_sa-update {
  chroot $tmp cp /usr/share/spamassassin/sa-update.cron /etc/cron.daily/sa-update
  sed -i 's/#SAUPDATE=yes/SAUPDATE=yes/' $tmp/etc/sysconfig/sa-update
  chroot $tmp usermod -a -G virusgroup amavis  | tee -a install.out
}

function import_container {
  podman import --change "$entrypoint" ${service}-root.tgz ${service}-root:$creation_date | tee -a install.out
}
