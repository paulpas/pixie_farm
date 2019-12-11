export XMR_HOME=/tmp/xmrig
alias hash='for i in $(arp -n | grep -v incomplete | grep bond0 | awk "{print \$1}"); do nc -w 1 $i 22 </dev/null &>/dev/null  && (ssh -o "StrictHostKeyChecking=no" $i journalctl -xe -u xmrig 2>/dev/null | grep [s]peed | tail -1 & wait) done'
alias hash_blur='for i in $(arp -n | grep -v incomplete | grep bond0 | awk "{print \$1}"); do nc -w 1 $i 22 </dev/null &>/dev/null  && (ssh -o "StrictHostKeyChecking=no" $i journalctl -xe -u blur 2>/dev/null | grep [s]peed | tail -1 & wait) done'
alias hash_total="hash | awk -v N=8 '{ sum += \$N } END { if (NR > 0) print sum  }'"
alias hash_blur_total="hash_blur | awk -v N=8 '{ sum += \$N } END { if (NR > 0) print sum  }'"
alias copy_ssh='for i in $(ls /tftpboot/nodes/); do mkdir /tftpboot/nodes/$i/root/.ssh; cp /root/.ssh/authorized_keys /tftpboot/nodes/$i/root/.ssh/authorized_keys; chmod -R 600 /tftpboot/nodes/$i/root/.ssh; done'
alias copy_resolvconf='drbl-cp-host /etc/resolvconf/resolv.conf /etc/resolv.conf'
alias update_xmrig='for i in $(showmount | grep -v "Hosts on"); do (ssh -o "StrictHostKeyChecking=no" $i "systemctl daemon-reload&&systemctl restart xmrig"); done'
alias update_xmrig_force='for i in $(showmount | grep -v "Hosts on"); do (ssh -o "StrictHostKeyChecking=no" $i "systemctl daemon-reload && systemctl stop xmrig && rm -rf /tmp/xmrig && systemctl start xmrig") ; done'
alias restart_xmrig='update_xmrig'
alias pixie_update_config='yes "y" | drblpush -c /etc/drbl/drblpush.conf && \
	systemctl enable resolvconf && \
	copy_ssh && \
	copy_resolvconf && \
	drbl-client-service resolvconf on && \
	drbl-client-service xmrig on && \
	systemctl enable isc-dhcp-server && \
	systemctl restart isc-dhcp-server'
