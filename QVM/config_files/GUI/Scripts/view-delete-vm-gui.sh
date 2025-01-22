#!/bin/bash

# Function to get VM information
get_vm_info() {
    find ~/QVM/config_files/VM_Images -type f -name "*.img" | while read -r vm_path; do
        vm_name=$(basename "$vm_path" .img)
        if ps aux | grep -q "[q]emu-system.*$vm_name"; then
            status="Running"
        else
            status="Powered off"
        fi
        echo -e "$vm_name\t$status\t$vm_path"
    done
}
get_v=$(get_vm_info)

# Display VM list and handle user selection
path="$HOME/QVM/config_files/VM_Images/"
vvm=$(ls "$path" | sed 's/.img//g')

if [ "$1" = "-d" ]; then
	if [ -n "$2" ]; then
		yad --bar --on-top \
	        --title="QVM-v1.0.3 - Delete VM - $2" \
            --width=300 \
            --height=200 \
	        --text="Are you sure that you want delete this virtual machine?" \
	        --pulsate \
	        --auto-close \
			--button="Cancel":1 --button="OK":0
		case $? in
			0)	echo ""
				yad --text-info --title="QVM-v1.0.3 - Deleting the $2 VM" --text="<b>Deleting the $2 VM! Depending on its HD size (i.e. 65GB+), it may take up to a minute or more!</b>" --button="OK":0
				sudo rm "${path}${2}.img"
				sudo rm "$HOME/QVM/config_files/vm_log_files/${2}_vm_"*
				if ! $(get_vm_info | grep "$2" &>/dev/null); then
					yad --title="QVM-v1.0.3 - Operation successful" --on-top \
						--text="The $2 VM image has successfully been deleted." \
	        			--button="OK":0
	        		echo "The $2 VM image has successfully been deleted."
					exit 0
				else
					echo "Error: $2 VM image has not been deleted."
				fi
		        exit 1
			;;
			1)	exit 1	
			;;
		esac
    else
        echo "Error: No file specified for deletion"
        exit 1
    fi
fi

if [ "$1" = "-rn" ]; then
	echo -e "\033[34mRename a VM...\033[0m"
	rename=$(echo $vvm | yad --on-top --form --width=480 \
    	--image="$HOME/QVM/config_files/logo_images/qvm-2.png" \
		--title="QVM-v1.0.3 - Rename a VM" \
    	--on-top --separator='' \
		--text="Enter a new name for the '$vvm' virtual machine" \
		--field="New VM Name": "" \
		--button="Cancel":1 --button="Rename VM":0)
	case $? in
		0)	echo -e "\033[34mRenaming the\033[0m ${vvm} \033[34mVM to\033[0m ${rename}\033[34m!"
			sudo mv $HOME/QVM/config_files/VM_Images/${vvm}.img $HOME/QVM/config_files/VM_Images/${rename}.img && \
			sudo mv $HOME/QVM/config_files/vm_log_files/${vvm}_vm_restart $HOME/QVM/config_files/vm_log_files/${rename}_vm_restart && \
			sudo sed -i 's/'"${vvm}"'.img/'"${rename}"'.img/g' "$HOME/QVM/config_files/vm_log_files/${rename}_vm_restart" && \
			sudo mv $HOME/QVM/config_files/vm_log_files/${vvm}_vm_specs $HOME/QVM/config_files/vm_log_files/${rename}_vm_specs
			case $? in
				0)	echo -e "The '$2' VM was successfully renamed to '$rename'!"
					yad --title="QVM-v1.0.3 - Operation successful..." --on-top \
						--text="The '$2' VM was successfully renamed to '$rename'!" \
		        		--button="OK":0
				;;
				1)	echo -e "Error: Rename operation failed!"
					yad --title="QVM-v1.0.3 - Operation failed..." --on-top \
						--text="The $2 VM image has not been renamed." \
		        		--button="OK":0
				;;
			esac
			exit 0
		;;
		1)	exit 1
		;;
	esac
fi

if [ $(echo "$vvm" | wc -w) -le 1 ]; then
	vvme="$vvm"
else
	vvme=$(echo "$vvm" | tr '\n' '!')
fi

buttons="--button=Cancel:1"
if ! [ -z "$vvm" ]; then
	view_vm=" --button=View:0"
	buttons+="$view_vm"
fi

vms=$(echo $vvm | yad --on-top --form --width=300 --height=150 \
     --buttons-layout=center \
	 --image="$HOME/QVM/config_files/logo_images/qvm-2.png" \
	--title="QVM-1.0.3 - View VM Specs" \
    --text="<b>$(echo $1 | awk -F "VM" '{print $2}' | sed 's/I/VM I/g')</b>" \
	--field="<b>Select VM: </b>":CB "$vvme" \
    $buttons)

case $? in
    0) # View selected VMs
	    vms=$(echo $vms | awk -F "\|" '{print $1}' 2> /dev/null)
		vmss=$(cat $HOME/QVM/config_files/vm_log_files/${vms}_vm_specs)
		cpu=$(echo $vmss | awk -F '" "' '{print $1}')
		mem=$(echo $vmss | awk -F '" "' '{print $2}')
		os=$(echo $vmss | awk -F '" "' '{print $3}' | cut -d. -f1)
		kv=$(echo $vmss | awk -F '" "' '{print $6}')
		net=$(echo $vmss | awk -F '" "' '{print $7}')
		hd=$(echo $vmss | awk -F '" "' '{print $4}')
		format=$(echo $vmss | awk -F '" "' '{print $5}')
		display=$(echo $vmss | awk -F '" "' '{print $8}')
		vga=$(echo $vmss | awk -F '" "' '{print $9}')
		gmem=$(echo $vmss | awk -F '" "' '{print $10}' | cut -d"\"" -f1)
		
		if pgrep -f "qemu-system.*$vms" > /dev/null; then
		    status="Running!"
		else
		    status="Stopped"
		fi
		
		specs=$(yad --on-top --width=450 \
     		--buttons-layout=center \
    		--image="$HOME/QVM/config_files/logo_images/qvm-2.png" \
			--title="View VM" \
		    --text="<b>QVM-v1.0.3 - '$vms' VM Specs</b>" \
		    --form --on-top \
		    --field="VM Name":RO "$vms" \
		    --field="Status":RO "$status" \
		    --field="CPU Threads":RO "${cpu} Cores" \
		    --field="Memory (RAM)":RO "${mem}GB" \
		    --field="OS":RO "$os" \
		    --field="Display":RO "$display" \
		    --field="VGA":RO "$vga" \
		    --field="Graphical Memory":RO "$gmem" \
		    --field="Disk Size":RO "${hd}GB" \
		    --field="Format":RO "$format" \
		    --field="KVM Enabled":RO "$kv" \
		    --field="Network Interfaces":RO "$net" \
		    --button="Delete VM":2 --button="Rename":1 \
			--button="Close":0)

		case $? in
			0)	exit
			;;
			1)	../GUI/Scripts/view-delete-vm-gui.sh -rn $vms
			;;
			2)	../GUI/Scripts/view-delete-vm-gui.sh -d $vms
			;;
		esac
		
        ;;
    1) # Cancel
		exit 1
        ;;
esac
