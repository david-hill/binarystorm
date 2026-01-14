yum install -y vim git net-tools bind-utils fail2ban tcp_wrappers uptimed net-snmp certmonger
git config --global core.editor "vim"
cp /root/binarystorm/etc/containers/* /etc/containers

systemctl disable systemd-resolved.service
systemctl stop systemd-resolved.service

echo "nameserver 8.8.8.8" > /etc/resolv.conf

cp root/.vimrc /root/

git config --global user.name "David Hill"
git config --global user.email hostmaster@davidchill.ca

cp -pr etc/fail2ban/* /etc/fail2ban/

touch /var/log/fail2ban.log
systemctl enable fail2ban
systemctl start fail2ban

yum install rsyslog
systemctl start rsyslog
systemctl enable rsyslog

cp etc/pki/tls/certs/gen_localhost_crt.sh /etc/pki/tls/certs
cp etc/pki/tls/openssl.cnf /etc/pki/tls/

cp etc/pki/ca-trust/source/anchors/* /etc/pki/ca-trust/source/anchors
update-ca-trust

cp -pr etc/systemd/system/sshd@.service.d /etc/systemd/system
systemctl daemon-reload

systemctl disable sshd
systemctl stop sshd
systemctl enable --now sshd.socket

systemctl start uptimed
systemctl enable uptimed

cp etc/snmp/snmpd.conf /etc/snmp
systemctl enable snmpd
systemctl start snmpd

systemctl enable certmonger
systemctl start certmonger

cp etc/selinux/config /etc/selinux
setenforce 0
