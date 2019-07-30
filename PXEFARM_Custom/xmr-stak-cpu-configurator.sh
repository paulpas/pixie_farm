#!/usr/bin/bash -xv
env

export GPU_FORCE_64BIT_PTR=1
export GPU_USE_SYNC_OBJECTS=1
export GPU_MAX_HEAP_SIZE=100
export GPU_MAX_ALLOC_PERCENT=100
export GPU_SINGLE_ALLOC_PERCENT=100

temp=$(mktemp)
echo $temp

##############################
# Load Needed GPU drivers
##############################
modprobe -i amdgpu

######################################################
# Detect unique identifiers to set worker information
######################################################
DetectCPUModel=$(lscpu | grep -w "Model name:" | awk -F: '{print $2}' | sed -r 's/^[ \t]*//;s/\(*..\)//g;s/  */_/g')
DetectComputerModel=$(dmidecode | grep -E 'Product Name' | awk -F: '{print $2}' | sed -e 's/^[ \t]*//;s/ /_/g;s/[[:space:]]*$//' | head -1)
DetectCPUCores="$(getconf _NPROCESSORS_ONLN)x"
echo $DetectCPUWorker
echo $DetectComputerModel
echo $DetectCPUCores
#WorkerID="$DetectComputerModel$DetectCPUCores$DetectCPUModel"
WorkerID="PXEfarm"
WorkerID=$(ip addr show $(route -n | awk '/^0/ {print $8}') | grep -Po 'inet \K[\d.]+' | grep -v 127.0.0.1 | awk -F. '{print $3"-"$4}')
echo $WorkerID

#####################################################
# Define miner binaries and configuration files
#####################################################
XMR_CPU_SRC=/usr/local/src/xmr-stak/build
XMR_CPU_MINER="$XMR_CPU_SRC/bin/xmr-stak -i 0" 
#ConfigSrc=/usr/local/src/xmr-stak-cpu/bin/config.txt.stock
PoolConfigDest=$temp


# Disable HT
for CPU in /sys/devices/system/cpu/cpu[0-9]*; do
    CPUID=`basename $CPU | cut -b4-`
    echo -en "CPU: $CPUID\t"
    [ -e $CPU/online ] && echo "1" > $CPU/online
    THREAD1=`cat $CPU/topology/thread_siblings_list | cut -f1 -d,`
    if [ $CPUID = $THREAD1 ]; then
        echo "-> enable"
        [ -e $CPU/online ] && echo "1" > $CPU/online
    else
        echo "-> disable"
        echo "1" > $CPU/online
    fi
done

# Enable max CPU clock on your CPUs
####################################
for CPUFREQ in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
do
    [ -f $CPUFREQ ] || continue
    echo -n performance > $CPUFREQ
done

for SETFREQ in /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq 
do
    [ -f $SETFREQ ] || continue
    Mhz=$(cat $SETFREQ)
    echo $Mhz > /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_min_freq
done
    

#################################################################################
## Delete default cpu_threads_conf and replace with detected ideal configuration
#################################################################################
#
##sed -e '/"cpu_threads_conf/,+1d' $ConfigSrc > $ConfigDest
### Append the detected CPU config to the configuration
##$XMR_CPU_MINER $ConfigSrc | sed -e '1,/BEGIN/d' -e '/END/,$d'  >> $ConfigDest
##sed -i "s/WORKERID/$WorkerID/" $ConfigDest
################################################################################

##########################################################
# Copy configuration into the hosts /tmp directory
##########################################################
cp -pr $XMR_CPU_SRC /tmp/
XMR_CPU_SRC=/tmp/build/bin
XMR_CPU_MINER=$XMR_CPU_SRC/xmr-stak
rm -f $XMR_CPU_SRC/{cpu.txt,nvidia.txt,amd.txt}
##########################################################
# Update worker ID to a unique identifier
##########################################################
XMR_CPU_POOLS=$XMR_CPU_SRC/pools.txt
sed -i "s/PXEFarm/$WorkerID/" $XMR_CPU_POOLS

###############################################################
# Apply all .conf files for custom CPU and GPU configurations
###############################################################
cd $XMR_CPU_SRC
for i in config/*.conf
do
	source $i
done

###########################################
# Apply CPU and GPU custom configurations
###########################################

#ryzen_1700_tune
#i3-6100_tune
rx_570_4g_tune
#gtx_1050_ti_tune
#gtx_1060_6GB_tune
#rx_550_4g_tune

# Set fan speed for AMD GPUs
amd_setfan
amd_setpwr

# Start the miner in the $XMR_CPU_SRC directory
$XMR_CPU_MINER #$ConfigDest
