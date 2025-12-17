source ../common/common.sh
tmp=$(mktemp -d)
yum install -y --installroot=$tmp --nogpgcheck spamassassin cronie curl | tee install.out
chroot $tmp cp /usr/share/spamassassin/sa-update.cron /etc/cron.daily/sa-update
sed -i 's/#SAUPDATE=yes/SAUPDATE=yes/' $tmp/etc/sysconfig/sa-update
chroot $tmp usermod -a -G virusgroup amavis  | tee -a install.out
cleanup_root
tar zcvf sa-update-root.tgz -C $tmp . | tee -a install.out
podman import --change 'ENTRYPOINT ["/usr/sbin/crond", "-f"]' sa-update-root.tgz sa-update-root:$creation_date | tee -a install.out
rm -rf $tmp
