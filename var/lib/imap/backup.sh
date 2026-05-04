tdate=$(date "+%Y%m%d")
if ! [ -e /var/spool/imap/mailbox-$tdate.tgz ]; then
  cd  /var/spool/imap
  tar zcvf mailbox-$tdate.tgz *
  find /var/spool/imap/ -name mailbox\*tgz -mtime +7 -delete
fi

if ! [ -e /var/lib/imap/backup-$tdate.tgz ]; then
  cd /var/lib/imap
  tar zcvf backup-$tdate.tgz *
  find /var/lib/imap/ -name backup\*tgz -mtime +7 -delete
fi
