#!/bin/bash


yum install -y postfix bind cyrus-imapd cyrus-sasl vim bind-utils
systemctl enable postfix
systemctl enable cyrus-imapd
systemctl enable saslauthd
systemctl start postfix
systemctl start cyrus-imapd
systemctl start saslauthd
