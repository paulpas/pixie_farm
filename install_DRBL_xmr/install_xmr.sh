#!/usr/bin/env bash

####################################################
# This must be set in the shell before you run it
# I will add logic oto do this for you another time:
#
#         scl enable devtoolset-4 bash
####################################################

# XMR-STAK git repo root directory
xmrstakInstallRepoRoot=/usr/local/src/

# Install CUDA repo from NVIDIA
#

VERSION=390.306 # manually setting this for development porposes

# Redhat / CentOS
if [[ ! -f /etc/yum.repos.d/cuda.repo ]] && [[ -f /etc/redhat-release ]]; then
cat << EOF > /etc/yum.repos.d/cuda.repo
[cuda]
name=cuda
baseurl=http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64
enabled=1
gpgcheck=1
gpgkey=http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/7fa2af80.pub
EOF
fi

# Download  AMD-APP-SDKInstaller-v3.0.130.136-GA-linux64.tar.bz2
################################################################
wget -O /tmp/AMD-APP-SDKInstaller-v3.0.130.136-GA-linux64.tar.bz2 https://downloads.sourceforge.net/project/nicehashsgminerv5viptools/APP%20SDK%20A%20Complete%20Development%20Platform/AMD%20APP%20SDK%203.0%20for%2064-bit%20Linux/AMD-APP-SDKInstaller-v3.0.130.136-GA-linux64.tar.bz2
cd /tmp
tar jxvf AMD-APP-SDKInstaller-v3.0.130.136-GA-linux64.tar.bz2

# This should interactively install it, I assume $AMDAPPSDKROOT is /opt/AMDAPPSDK-3.0
#####################################################################################
bash AMD-APP-SDK-v3.0.130.136-GA-linux64.sh
$AMDAPPSDKROOT="/opt/AMDAPPSDK-3.0"

# To fix libOpenCL issue:
########################
cd $AMDAPPSDKROOT/lib/x86_64
ln -sf sdk/libOpenCL.so.1 libOpenCL.so
cd -

# Clean out the system
######################
yum remove -y nvidia-kmod cuda
yum install -y nvidia-kmod-$VERSION cuda-drivers-$VERSION xorg-x11-drv-nvidia-$VERSION xorg-x11-drv-nvidia-devel-$VERSION xorg-x11-drv-nvidia-gl-$VERSION xorg-x11-drv-nvidia-libs-$VERSION
yum install -y cuda
source ~root/.bash_profile
cd $xmrstakInstallRepoRoot
if [[ -d $xmrstakInstallRepoRoot/xmr-stak ]] ; then
	cd xmr-stak
	git pull
else
	git clone https://github.com/fireice-uk/xmr-stak.git || echo "Unable to clone xmr-stak, aborting script" && exit 1
	cd xmr-stak
fi
rm -rf build
mkdir build
cd build
cmake3  .. -DOpenCL_ENABLE=ON
make
cd $xmrstakInstallRepoRoot/xmr-stak
# Add CustomPXE directory_stuff here
cp -pr PXEFARM_Custom/{config.txt,etn.pools.txt,pools.txt,stop-claymore.sh,xmr-stak-cpu-configurator.sh} build/bin/
cd build/bin/

# Update DRBL nodes with the new module information
###################################################
updatekernel

# Next, reboot all nodes, commented out until it's determined to be the best behavior
#####################################################################################
rebootnodes

# Used for local testing
systemctl restart xmr

