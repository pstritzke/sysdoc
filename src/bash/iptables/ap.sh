#!/bin/sh


AP_DEV_IF=wlp2s0
AP_STA_IF=wl_sta
AP_IF=wl_ap
PRV_IF=""

ADDR=192.168.1.254
MASK=24


case $1 in
	start)

            iw dev $AP_DEV_IF interface add $AP_STA_IF type station
            iw dev $AP_DEV_IF interface add $AP_IF type __ap

            ip link set dev $AP_STA_IF address 00:27:1e:28:b4:9a
            ip link set dev $AP_IF address     00:26:2e:28:b4:9a

	    /sbin/ip addr add ${ADDR}/${MASK} dev ${AP_IF} broadcast +
            /sbin/ip addr add ${ADDR} dev 
            /sbin/ip link set ${AP_IF} up

            #sysctl net.ipv4.ip_forward=1

		;;
	stop)

          iw dev $AP_STA_IF del

          iw dev $AP_IF del

		;;
	restart)
		$0 stop
		$0 start
		;;

        *)
		echo "Usage: $0 [start|stop|restart]"
		;;
esac

