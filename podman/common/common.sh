creation_date=$(date '+%Y%m%d%H%M%S')

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
