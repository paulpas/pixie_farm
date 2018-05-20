Put these in your DRBL node_root.

For example:
* /tftpboot/node_root/etc/systemd/system/multi-user.target.wants/claymore.service


I skipped the ``` /usr/lib/systemd/system/multi-user.target/<service>.service && systemctl enable <service>.service ``` method due to laziness and untestes DRBL operatbility.
