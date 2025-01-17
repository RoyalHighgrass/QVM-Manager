#!/bin/bash

b="\033[34m"
w="\033[0m"

if [ "$1" = "-um" ]; then
	yad --text-info --filename="../../User_Manual_-_QVM_Documentation.txt" \
		--title="File Contents" --width=850 --height=800 --on-top \
		--buttons-layout=center \
		--image="$HOME/QVM/config_files/logo_images/qemu2-1.png" \
		--text="<b>This User Manual contains the contents of the QVM man page, \
which is updated with each new release to reflect new features and methodologies. QVM offers \
a user-friendly interface for creating, managing, and running virtual machines \
within your existing Linux environment. By leveraging the host OS for hardware \
resource management, QVM ensures isolation between guest operating systems. \
This manual aims to guide you through the QVM experience, helping you maximize \
its capabilities.</b>" \
		--button="Close":1
		exit 0
fi

export GTK_IM_MODULE=none
export XDG_RUNTIME_DIR=none
export WAYLAND_DISPLAY=wayland-0

credit() { echo -e "$(cat << 'EOF'
\033[34m
------------------------------------------------------------------------
===============> 01010001 01010110 01001101 10101001 <==================
------------------------------------------------------------------------
     __  __   __   _,      __  _,        
    / _ \\ \ / / \/ | ___ |  \/ | __ _  _ ___  __ _  __ _  __   _ _     
   ( (_) |\ \ / |\/ ||___|| |\/ || _` || `/\ || _` || _` || -_)| `_|    
    \__\_\ \_/|_| |_|     |_| |_|\__,_||_| |_|\__,_|\__, |\___||_|  ©   
                                                    |____/              
------------------------------------------------------------------------
=============> QEMU Virtual Machine Manager v1.0.3 © 2024 <=============
----------------------------- GUI Interface ----------------------------

EOF
)"
}
credit

echo -e "${b}Starting QVM-v1.0.3 & Launching the QEMU Virtual Machine Manager GUI ...${w}"

zenity --notification --title="QEMU Virtual Machine Manager v1.0.3" \
    --text="Starting QVM-v1.0.3 & Launching QEMU Virtual Machine Manager GUI" --timeout=1 2>/dev/null

# You must place file "COPYING" in same folder of this script.
FILE=`dirname $0`/../../LICENSE

trap 'echo -e "\n${b}Warning: Abruptly shutting down QVM could result in data loss in a running VM.\nUse CTRL+C with caution!\n\nQVM-v1.0.3 was forced to stop running!${w}"' SIGINT

# Get screen dimensions
SCREEN_WIDTH=$(xrandr | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f1)
SCREEN_HEIGHT=$(xrandr | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f2)

echo -e "${w}Licensing Agreement.... pending!"
zenity --text-info --title="QVM-v1.0.3 - License" --width=550 --height=500 \
    --filename=$FILE --checkbox="I read and accept the terms." 2>/dev/null

case $? in
    0)
        # Licensing agreement
		echo -e "${b}Licensing Agreement.... accepted!${w}"
		echo -e "${b}QVM-v1.0.3 is running...${w}"
		
		#Check for manually downloaded ISO images
		result=$(find "$HOME" -type f -name "*.iso" -not -path "$HOME/QVM/*" -print0 | xargs -0 printf "%s " &>/dev/null)
		if [ -z "$result" ]; then
			echo -n ""
		else
			echo -e -n "${b}Updating QVM ISO Management....${w}"
			if eval sudo mv "$result" "$HOME/QVM/config_files/ISO_Images/" &>/dev/null; then
			    if [ $? -eq 0 ]; then
					echo -e "${b}done!"
			        echo -e "Image(s) successfully imported!${w}"
			    else
			        echo -e "${b}ISO import failed!\n\nAn unexpected error has occured.${w}"
			    fi
			fi
		fi

		# Main script
		dev_message=$(cat ./../../DevMessage.txt)
		main_menu() { yad --title "QVM-v1.0.3 - QEMU Virtual Machine Manager GUI" \
		    --form --columns=2 --width="$SCREEN_WIDTH" --height="$SCREEN_HEIGHT" \
		    --text="<b>$dev_message</b>"\
		    --no-escape \
		    --image="$HOME/QVM/config_files/logo_images/qemu2-4.png" \
		    --field="<b>Create/Start VM</b>":fbtn "./Scripts/qvm-gui.sh" \
		    --field="<b>View/Delete VMs</b>":fbtn "./Scripts/qvm-gui.sh -vv" \
		    --field="<b>Save Snapshot</b>":fbtn "./Scripts/view-delete-snapshot-gui.sh -sss" \
		    --field="<b>View/Delete Snapshots</b>":fbtn "./Scripts/view-delete-snapshot-gui.sh -vs" \
		    --field="<b>ISO Management</b>":fbtn "./Scripts/iso-gui.sh" \
		    --field="<b>Settings</b>":fbtn "./../settings/settings.sh" \
		    --field="<b>System Information</b>":fbtn "./../settings/sys_info.sh" \
		    --field="<b>User Manual</b>":fbtn "./qvm-manager-gui.sh -um" \
		    --no-buttons
		echo -e "${b}QVM-v1.0.3 has stopped!${w}"
		}
		main_menu
        ;;
    1)
        echo -e "${b}Licensing Agreement.... rejected!"
        echo -e "QVM-v1.0.3 has stopped!${w}"
        ;;
    -1)
        echo -e "${b}qvm-manager: An unexpected error has occurred.${w}"
        ;;
esac


exit 0



