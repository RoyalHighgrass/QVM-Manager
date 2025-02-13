#!/bin/bash

rproc=$(ps -e)
if echo "$rproc" | grep yad; then
	killall yad
elif echo "$rproc" | grep qvm; then
	killall qvm*
elif echo "$rproc" | grep zenity; then
	killall zenity
elif echo "$rproc" | grep qemu-system; then
	killall qemu-system-x86_64
fi
