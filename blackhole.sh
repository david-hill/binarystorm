history=200
blacklist=$(grep SASL /var/log/maillog | grep failed | grep -v Password|  awk '{ print $7 }' | sort | uniq -c | sort -k1,1n | tail -$history | sed -e 's/.*\[\(.*\)\].*/\1/' | awk -F\. '{ print $1 "." $2 "." $3 ".0/24," }' | grep -v -e "[a-z]" |  sort | uniq | xargs echo -n)
blacklist=$blacklist$(cat /var/log/secure | grep failure | grep sshd-session | awk '{ print $14 }' | sort | uniq -c | sort -k1,1n | tail -$history | grep -v "::" | grep -v tty=ssh | sed -e 's/.*=\(.*\)/\1/g' | awk -F\. '{ print $1 "." $2 "." $3 ".0/24," }' | grep -v "\ "  | sort |uniq | xargs echo -n)

blacklist6=$(cat /var/log/secure | grep failure | grep sshd-session | awk '{ print $14 }' | sort | uniq -c | sort -k1,1n | tail -$history | grep "::" | grep -v tty=ssh | sed -e 's/.*=\(.*\)/\1/g' | awk -F: '{ print $1":"$2":"$3":"$4"::/64," }' | sort |uniq | xargs echo -n)

nft add set inet f2b-table blackhole { type ipv4_addr\; flags interval\; size $history \;}
nft add element inet f2b-table blackhole { $blacklist }

nft add set inet f2b-table blackhole6 { type ipv6_addr\; flags interval\; }
if [ ! -z "$blacklist6" ]; then
  nft add element inet f2b-table blackhole6 { $blacklist6 }
fi

if ! $(nft list ruleset | grep blackhole); then
  nft add rule inet f2b-table f2b-chain ip saddr @blackhole counter drop
  nft add rule inet f2b-table f2b-chain ip saddr @blackhole6 counter drop
fi

#[root@dns2 ~]# nft -a list ruleset | grep black
#	set blackhole { # handle 39
#		ip saddr @blackhole counter packets 10 bytes 508 drop # handle 42
#		ip saddr @blackhole counter packets 0 bytes 0 drop # handle 43
#		ip saddr @blackhole counter packets 0 bytes 0 drop # handle 44
#		ip saddr @blackhole counter packets 0 bytes 0 drop # handle 45
#		ip saddr @blackhole counter packets 0 bytes 0 drop # handle 46
#		ip saddr @blackhole counter packets 0 bytes 0 drop # handle 47
#[root@dns2 ~]# nft delete rule inet f2b-table f2b-chain handle 43
#[root@dns2 ~]# nft delete rule inet f2b-table f2b-chain handle 44
#[root@dns2 ~]# nft delete rule inet f2b-table f2b-chain handle 45
#[root@dns2 ~]# nft delete rule inet f2b-table f2b-chain handle 46
#[root@dns2 ~]# nft delete rule inet f2b-table f2b-chain handle 47


