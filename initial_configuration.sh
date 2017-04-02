#!/bin/bash


yum install -y postfix bind cyrus-imapd cyrus-sasl vim bind-utils telnet httpd
systemctl enable cyrus-imapd
systemctl enable httpd
systemctl enable postfix
systemctl enable saslauthd
systemctl start cyrus-imapd
systemctl start httpd
systemctl start postfix
systemctl start saslauthd

saslpasswd2 -c cyrus
passwd cyrus

firewall-cmd --permanent --zone=public --add-port=25/tcp
firewall-cmd --permanent --zone=public --add-port=53/tcp
firewall-cmd --permanent --zone=public --add-port=53/udp
firewall-cmd --permanent --zone=public --add-port=80/tcp
firewall-cmd --permanent --zone=public --add-port=110/tcp
firewall-cmd --reload

