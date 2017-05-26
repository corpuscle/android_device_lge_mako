#!/system/bin/sh

# Workaround for conn_init not copying the updated firmware
rm /data/misc/wifi/WCNSS_qcom_cfg.ini
rm /data/misc/wifi/WCNSS_qcom_wlan_nv.bin

/system/bin/conn_init

echo 1 > /dev/wcnss_wlan

enable_bt () {
	if [[ `getprop ro.qualcomm.bt.hci_transport` != "smd" ]]; then
		setprop ro.qualcomm.bt.hci_transport smd
	fi

	#initialize bt device
	/system/bin/hci_qcomm_init -e
	sleep 1 
	logi "start bluetooth smd transport"
	echo 1 > /sys/module/hci_smd/parameters/hcismd_set
}

for i in 1 2 3 4 5; do
    # sleep first to avoid issue when called after conn_init
    sleep 2 
    if [ ! -f /sys/devices/platform/wcnss_wlan.0/net/wlan0/address ]; then
        echo sta > /sys/module/wlan/parameters/fwpath
    else
	enable_bt
        break
    fi
done
