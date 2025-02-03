#!/bin/bash

rproc=$(ps -e)
ryp=$(echo \"$rproc\" | grep yad)
rqp=$(echo \"$rproc\" | grep qvm)
rzp=$(echo \"$rproc\" | grep zenity)
rvp=$(echo \"$rproc\" | grep qemu-system)
if ! [[ -z \"$ryp\" ]]; then
	killall yad
fi
if [[ \"$rqp\" ]]; then
	killall qvm*
fi
if [[ \"$rzp\" = \"zenity\" ]]; then
	killall zenity
fi
if [[ \"$rvp\" = \"qemu-system*\" ]]; then
	killall zenity
fi
