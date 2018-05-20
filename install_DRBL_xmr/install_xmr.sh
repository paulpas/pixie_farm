scl enable devtoolset-4 bash

VERSION=390.306
yum remove -y nvidia-kmod cuda
yum install -y nvidia-kmod-$VERSION cuda-drivers-$VERSION xorg-x11-drv-nvidia-$VERSION xorg-x11-drv-nvidia-devel-$VERSION xorg-x11-drv-nvidia-gl-$VERSION xorg-x11-drv-nvidia-libs-$VERSION
yum install -y cuda
source ~root/.bash_profile
cd /usr/local/src/
if [[ -d /usr/local/src/xmr-stak ]] ; then
	cd xmr-stak
	git pull
else
	git clone https://github.com/fireice-uk/xmr-stak.git
	cd xmr-stak
fi
rm -rf build
mkdir build
cd build
cmake3  .. -DOpenCL_ENABLE=ON
make
cd /usr/local/src/xmr-stak/
# Add CustomPXE directory_stuff here
cp -pr PXEFARM_Custom/{config.txt,etn.pools.txt,pools.txt,stop-claymore.sh,xmr-stak-cpu-configurator.sh} build/bin/
cd build/bin/
updatekernel
#./xmr-stak -i 0
systemctl restart xmr

