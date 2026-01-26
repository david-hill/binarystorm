mkdir /etc/postfix
rsync -avgo dns1.davidchill.ca:/etc/postfix/keys /etc/postfix
rsync -avgo dns1.davidchill.ca:/etc/pki/cyrus-imapd /etc/pki
rsync -avgo dns1.davidchill.ca:/etc/sasldb2 /etc
mkdir /etc/httpd
rsync -avgo dns1.davidchill.ca:/etc/httpd/keys /etc/httpd
mkdir /etc/opendkim
rsync -avgo dns1.davidchill.ca:/etc/opendkim/keys /etc/opendkim
rsync -avgo dns1.davidchill.ca:/var/lib/sql /var/lib
rsync -avgo dns1.davidchill.ca:/var/lib/imap /var/lib
rsync -avgo dns1.davidchill.ca:/var/spool/imap /var/spool
rsync -avgo dns01.davidchill.ca:/etc/pki/tls/certs/wildcard.crt /etc/pki/tls/certs
rsync -avgo dns01.davidchill.ca:/etc/pki/tls/private/wildcard.key /etc/pki/tls/private

