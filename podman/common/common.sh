creation_date=$(date '+%Y%m%d%H%M%S')
tmp=$(mktemp -d)
include="var/cache/dnf var/lib/dnf usr/share/man usr/share/doc usr/lib/.build-id var/log/dnf var/log/hawkey usr/share/licenses usr/share/X11 usr/lib/systemd usr/lib/rpm usr/lib/tmpfiles.d usr/share/dbus-1"
registry=registry.davidchill.ca:5000
scriptlocation=$(echo $0 | xargs dirname)
decompressargs='xf'
compressargs='zcf'

function cleanup_root {
  if [ ! -z $tmp ]; then
    for rmpath in $include; do
      rm -rf $tmp/$rmpath
    done
  fi
}

function install_required_packages {
  rpm -qi shadow-utils >/dev/null
  if [ $? -ne 0 ]; then
    yum install -y shadow-utils | tee -a $scriptlocation/install.out
  fi
}

function install_epel_repo {
  rpm -qi epel-release > /dev/null
  if [ $? -ne 0 ]; then
    rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm  2>/dev/null 1>/dev/null
  fi
}

function pre_amavisd {
  install_epel_repo
}
function pre_clamd {
  install_epel_repo
}
function pre_freshclam {
  install_epel_repo
}
function pre_httpd {
  install_epel_repo
}
function pre_opendkim {
  install_epel_repo
}
function pre_php-fpm {
  install_epel_repo
}
function pre_sa-update {
  install_epel_repo
}

function build_container {
  changed=0
  update=0
  install=0
  if declare -F pre_$service > /dev/null; then
    pre_$service
  fi
  if [ -e $scriptlocation/${service}-root-diff.tgz ]; then
    tar $decompressargs $scriptlocation/${service}-root-diff.tgz -C $tmp | tee $scriptlocation/install.out
    tar $decompressargs $scriptlocation/${service}-root.tgz -C $tmp | tee -a $scriptlocation/install.out
    cp /root/binarystorm/podman/common/etc/yum.repos.d/*.repo /etc/yum.repos.d
    yum check-update -q --installroot=$tmp | tee -a $scriptlocation/install.out
    if [ $? -ne 0 ]; then
      yum update -y --installroot=$tmp --nogpgcheck | tee -a $scriptlocation/install.out
      update=1
    else
      echo "No new updates" | tee -a $scriptlocation/install.out
    fi
  else
    cp /root/binarystorm/podman/common/etc/yum.repos.d/*.repo /etc/yum.repos.d
    yum install -y --installroot=$tmp --nogpgcheck $packages | tee $scriptlocation/install.out
    install=1
  fi
  if [[ $install -ne 0 ]] || [[ $update -ne 0 ]]; then
    changed=1
    if declare -F customize_$service > /dev/null; then
      customize_$service
    fi
    tar $compressargs $scriptlocation/${service}-root-diff.tgz -C $tmp $include | tee -a $scriptlocation/install.out
    cleanup_root
    tar $compressargs $scriptlocation/${service}-root.tgz -C $tmp . | tee -a $scriptlocation/install.out
  fi
  rm -rf $tmp
  exit $changed
}

function customize_freshclam {
  install_required_packages
  chroot $tmp useradd -u 995 amavis | tee -a $scriptlocation/install.out
}

function customize_amavisd {
  install_required_packages
  chroot $tmp usermod -a -G virusgroup amavis  | tee -a $scriptlocation/install.out
}

function customize_clamd {
  install_required_packages
  chroot $tmp useradd -u 995 amavis | tee -a $scriptlocation/install.out
}
function customize_sa-update {
  install_required_packages
  chroot $tmp cp /usr/share/spamassassin/sa-update.cron /etc/cron.daily/sa-update
  sed -i 's/#SAUPDATE=yes/SAUPDATE=yes/' $tmp/etc/sysconfig/sa-update
  chroot $tmp usermod -a -G virusgroup amavis  | tee -a $scriptlocation/install.out
}

function customize_builddcc {
#  cp builddcc.sh $tmp/
#  cp dcc.spec $tmp/
  cp macros $tmp/root/.rpmmacros
}
function import_container {
  install_required_packages
  podman import --change "$entrypoint" $scriptlocation/${service}-root.tgz ${service}-root:$creation_date | tee -a $scriptlocation/install.out
}
