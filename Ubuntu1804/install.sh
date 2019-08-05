#!/usr/bin/env bash

# Installs DRBL and configures it

# Push new config



#### Install DRBL
cat > /etc/apt/sources.list.d/drbl.list << EOF
deb http://archive.ubuntu.com/ubuntu bionic main restricted universe multiverse
deb http://free.nchc.org.tw/drbl-core drbl stable
EOF
wget -q http://drbl.org/GPG-KEY-DRBL -O- | sudo apt-key add -
apt update
apt install -y drbl

#### Setup networking
apt -y purge netplan.io # Doesn't support aliased interfaces, so single NIC DRBL support isn't there
apt install -y ifupdown
systemctl disable ufw
systemctl stop ufw

#### Setup DNS resolution
apt install -y resolvconf

#### Packages to build xmrig
apt-get install -y git build-essential cmake libuv1-dev libmicrohttpd-dev libssl-dev libhwloc-dev 
# Disable sleep, and laptop lid closes
echo 'HandleLidSwitchDocked=ignore' | tee --append /etc/systemd/logind.conf
echo 'HandleLidSwitch=ignore' | tee --append /etc/systemd/logind.conf
# Clear out new configs
rm -rf /tftpboot/nodes/10.255.254.*
# Push DRBL config non-interactively
yes "y" | drblpush -c /etc/drbl/drblpush.conf
# Enable resolvconf
systemctl enable resolvconf
drbl-client-service resolvconf on

# Enable xmrig
drbl-client-service xmrig on

# I noticed dhcpd doesn't get restarted after a push, so this is a DRBL work-around
systemctl enable isc-dhcp-server
systemctl restart isc-dhcp-server

# Copy resolv.conf to clients
drbl-cp-host /etc/resolvconf/resolv.conf /etc/resolv.conf 

# Handle the the ssh keys manually
####################################

# Generate keys if they do not exist, and under all circumstances, populate authorized_keys
if [[ -f /root/.ssh/id_rsa.pub ]]
then
	cat /root/.ssh/id_rsa.pub > /root/.ssh/id_rsa.pub/authorized_keys
	chmod 600 /root/.ssh/id_rsa.pub/authorized_keys
else
	ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
	cat /root/.ssh/id_rsa.pub > /root/.ssh/id_rsa.pub/authorized_keys
	chmod 600 /root/.ssh/id_rsa.pub/authorized_keys
fi
# Deploy keys
for i in $(ls /tftpboot/nodes/); do
	mkdir /tftpboot/nodes/$i/root/.ssh 2>/dev/null
	cp /root/.ssh/authorized_keys /tftpboot/nodes/$i/root/.ssh/authorized_keys
	chmod -R 600 /tftpboot/nodes/$i/root/.ssh
done
