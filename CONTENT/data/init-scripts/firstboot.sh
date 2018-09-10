#!/bin/bash
#
# Check if system is able to receive packages from RHN 
# Satellite or other omline source
#
is_connected_to_rhn() {
  	# no proxy check yet !!!
	curl -k subscription.rhsm.redhat.com
	return $?
}

cd /var/lib/awx/projects/rhsap-demo;
#  If possible, load packages from update server
if grep -v "^ *#" myvars.yml | grep -q "^reg_"; then
  if is_connected_to_rhn; then
	  rm -f /etc/yum.repos.d/local-redhat.repo
	  ansible-playbook -e @myvars.yml connected-setup.yml
  else
	  echo "Red Hat Network not reachable, stay with local repos"
  fi
fi
# Install tower
# Need to be done in 3 steps because tower installation installs a new ansible version, which causes a single playbook to fail
[ -f install-demoserver-part1.yml ] && ansible-playbook -vv -e @myvars.yml install-demoserver-part1.yml 2>&1 | tee /var/log/firstboot.p1.log
[ -d /tmp/usb/downloads/ansible-tower-setup-bundle*.el7/ ] && ( cd /tmp/usb/downloads/ansible-tower-setup-bundle*.el7/; ./setup.sh 2>&1 | tee /var/log/firstboot.towerinst.log )
[ -f install-demoserver-part2.yml ] && ansible-playbook -vv -e @myvars.yml install-demoserver-part2.yml 2>&1 | tee /var/log/firstboot.p2.log
# Before installation starts the USB stick needs to be umounted
umount -f /dev/disk/by-label/RHEL_DEMO
umount -f /dev/disk/by-label/CONTENT
# Install virtualization packages
[ -f install-demoserver-part3.yml ] && ansible-playbook -vv -e @myvars.yml install-demoserver-part3.yml 2>&1 | tee /var/log/firstboot.p3.log

### Recover tower backup
[ ! -d /tmp/usb ] && mkdir -p /tmp/usb
mount /dev/disk/by-label/CONTENT /tmp/usb
if [ -f /tmp/usb/downloads/ansible-tower-setup-bundle*.el7/tower-backup-latest.tar.gz ]; then
  ( cd /tmp/usb/downloads/ansible-tower-setup-bundle*.el7/; ./setup.sh -r 2>&1 | tee /var/log/firstboot.towerrestore.log )
  ansible-playbook -e @myvars.yml install-demoserver-part2.yml -t update_nginx_conf
fi
umount /tmp/usb
### make sure ports for Cockpit are open
firewall-cmd --add-port=9090/tcp
firewall-cmd --permanent --add-port=9090/tcp
systemctl enable cockpit.socket
systemctl start cockpit.socket
