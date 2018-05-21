# pixie_farm
Monero PXE farm using DRBL and a lot of custom scripts

* DRBL_systemd
  * The systemd service that gets places in the DRBL nodes_root for automatic service starting.

* PXEFARM_Custom
  * The scripts that automatically configure and start xmr-stak on a dkskless DRBL client.

* install_DRBL_xmr
  * The script that will take a fresh system and install EvErYtHiNg and make it run.

* profile.d
  * The functions for managing the farm exist here and are deployed in /etc/profile.d.
