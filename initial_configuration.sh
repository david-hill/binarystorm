#!/bin/bash


yum install -y postfix bind cyrus-imapd
systemctl enable postfix
systemctl enable cyrus-imapd
systemctl start postfix
systemctl start cyrus-imapd

