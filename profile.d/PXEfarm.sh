function stats
{
	for i in `arp -n | grep -v incomplete | grep enp2 | awk '{print $1}'`
	do
		nc -w 1 $i 22 </dev/null &>/dev/null  && echo -n "$i "; ssh -o ConnectTimeout=1 $i "grep -i total /var/log/mining.log | tail -1" 2>/dev/null
	done | sort -rn -k 5 
}

function show-stats
{
	while true
	do
		stats
		echo "^^^   $(date)   ^^^"
	done
}

function updatekernel
{
	kernel=$(cat /tftpboot/nbi_img/kernel_version_in_initrd.txt || exit 1)
	arch=$(cat /tftpboot/nbi_img/client_kernel_arch.txt || exit 1)

	depmod -a $kernel
	mknic-nbi -k $kernel -i $arch
}

