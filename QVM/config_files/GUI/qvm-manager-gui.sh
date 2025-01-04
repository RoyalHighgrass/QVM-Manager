#!/bin/bash


export GTK_IM_MODULE=none
export XDG_RUNTIME_DIR=none
export WAYLAND_DISPLAY=wayland-0

credit() { cat << 'EOF'
------------------------------------------------------------------------
===============> 01010001 01010110 01001101 10101001 <==================
------------------------------------------------------------------------
     __  __   __   _,      __  _,        
    / _ \\ \ / / \/ | ___ |  \/ | __ _  _ ___  __ _  __ _  __   _ _     
   ( (_) |\ \ / |\/ ||___|| |\/ || _` || `/\ || _` || _` || -_)| `_|    
    \__\_\ \_/|_| |_|     |_| |_|\__,_||_| |_|\__,_|\__, |\___||_|  ©   
                                                    |____/              
------------------------------------------------------------------------
==============> QEMU Virtual Machine Manager v1.0.2©2024 <==============
------------------------- --- GUI Interface ----------------------------

EOF
}

credit

echo -e "Starting QVM-1.0.3 & Launching the QEMU Virtual Machine Manager GUI ..."

zenity --notification --title="QEMU Virtual Machine Manager v1.0.3" \
    --text="Starting QVM-1.0.3 & Launching QEMU Virtual Machine Manager GUI" --timeout=1

# You must place file "COPYING" in same folder of this script.
FILE=`dirname $0`/../../license.txt

trap 'echo -e "\nWarning: Abruptly shutting down QVM could result in data loss in a running VM.\nUse CTRL+C with caution!\n\nQVM-v1.0.3 was forced to stop running!"' SIGINT

# Get screen dimensions
SCREEN_WIDTH=$(xrandr | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f1)
SCREEN_HEIGHT=$(xrandr | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f2)

echo -e "Licensing Agreement.... pending!"
zenity --text-info --title="License" --width=550 --height=500 \
    --filename=$FILE --checkbox="I read and accept the terms." 

case $? in
    0)
        # Licensing agreement
		echo -e "Licensing Agreement.... accepted!"
		echo "QVM-v1.0.3 is running..."
		
		#Check for manually downloaded ISO images
		result=$(find "$HOME" -type f -name "*.iso" -not -path "$HOME/QVM/*" -print0 | xargs -0 printf "%s " &>/dev/null)
		if [[ -z "$result" ]]; then
			echo -n ""
		else
			echo -n "Updating QVM ISO Management...."
			if eval sudo mv "$result" "$HOME/QVM/config_files/ISO_Images/" &>/dev/null; then
			    if [[ $? -eq 0 ]]; then
					echo "done!"
			        echo "Image(s) successfully imported!"
			    else
			        echo "ISO import failed!\n\nAn unexpected error has occured."
			    fi
			fi
		fi

		# Main script
		dev_message=$(cat ./../../DevMessage.txt)
		main_menu() { yad --title "QVM-1.0.3 - QEMU Virtual Machine Manager GUI" \
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
		    --field="<b>System Information</b>":fbtn "./../sys_info.sh" \
		    --field="<b>User Manual</b>":fbtn "" \
		    --no-buttons
		echo -e "QVM-v1.0.3 has stopped!"
		}
		main_menu
        ;;
    1)
        echo -e "Licensing Agreement.... rejected!"
        echo "QVM-v1.0.3 has stopped!"
        ;;
    -1)
        echo "An unexpected error has occurred."
        ;;
esac


exit 0



