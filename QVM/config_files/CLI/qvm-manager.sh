#!/bin/bash

app_name_info() { echo -e "$(cat << 'EOF'
\033[34m
	  ______   __     __  __       __ 
  H	 /     /\ / /|   / /|/ /\     / /|
  Y	/$$$$$$  |$$ |   $$ |$$  \   /$$ |          ©2024 - QVM CLI.
A P	$$ |  $$ |$$ |   $$ |$$$  \ /$$$ |    __________
  E	$$ |  $$ |$$  \ /$$/ $$$$  /$$$$ |   /         /|
Q R	$$ |__$$ | $$  /$$/  $$ $$ $$/$$ |   $$$$$$$$$$ |
E V	$$ /  $$ |  $$ $$/   $$ |$$$/ $$ |   $$$$$$$$$$/
M I	$$ $$ $$<    $$$/    $$ | $/  $$ |
U S	 $$$$$$\ |    $/     $$/      $$/ 	  QVM Manager v1.0.1
  O	     $$$/                         
  R
 __       __        Create & manage QEMU virtual machines with ease! 
/ /\     / /|                                                            
$$  \   /$$ |  ______   _______    ______    ______    ______    ______  
$$$  \ /$$$ | /     /\ /      /\  /     /\  /     /\  /     /\  /     /\ 
$$$$  /$$$$ | $$$$$$  |$$$$$$$  | $$$$$$  |/$$$$$$  |/$$$$$$  |/$$$$$$  |
$$ $$ $$/$$ | /    $$ |$$ |  $$ | /    $$ |$$ |  $$ |$$ /  $$ |$$ |  $$/ 
$$ |$$$/ $$ | $$$$$$$ |$$ |  $$ | $$$$$$$ |$$ \__$$ |$$$$$$$$/ $$ |      
$$ | $/  $$ |$$ /  $$ |$$ |  $$ |$$ /  $$ |$$ /  $$ |$$ /    `|$$ |      
$$/      $$/  $$$$$$$/ $$/   $$/  $$$$$$$/  $$$$$$$ | $$$$$$$/ $$/      
                                           / /\__$$ |                    
     https://github.com/RoyalHighgrass	   $$\/  $$/     Written by P.H   
                                            $$$$$$/                      
EOF
)"
}

main_menu() {
echo -e "$(cat << 'EOF'
\033[34m
------------------------------------------------------------------------
=================> QEMU Virtual Machine Manager ©2024 <=================
-------------------------------\033[0m Main Menu \033[34m------------------------------

\033[0mSelect one of the following options;

\033[34mOptions:\033[0m
    1. Create or start VM
    2. List all VMs
    3. Save a VM snapshot
    4. View snapshots
    5. Delete a snapshot
    6. Delete a VM
    7. ISO images
    0. Exit \033[0m
EOF
)"
}

trap 'echo -e "\n\033[34mExiting... QVM was forced to stop running!\033[0m\n" && exit 1' SIGINT

vm_search() {
    echo -e "\033[34mSearching for VMs...\n\033[0m"
    echo -e "\033[34mVM Images Found:\033[0m $(find ~/QVM/config_files/VM_Images -type f -name '*.img' | wc -l)"
    
    # Find VM image files and extract names
    vms=$(find ~/QVM/config_files/VM_Images/ -type f -name "*.img" | cut -d"/" -f7 | cut -d"." -f1)
     
    # Get list of running VMs
    running_vms=$(ps aux | grep qemu-system | awk -F '/' '{print $NF}' | awk -F ".img" '{print $1}')
    
    echo -e "\033[34mVM Name:	     Status:\033[0m"
    
    # Loop through each VM and check its status
    echo "$vms" | while read -r vm; do
        if [[ "$(find ~/QVM/config_files/VM_Images -type f -name '*.img' | wc -l)" == "0" ]]; then
	        status=""
		else
			if echo "$running_vms" | grep -q "$vm"; then
	            status="Running"
	        else
	            status="Powered off"
	        fi
		fi
        printf "%-20s %s\n" "$vm" "$status"
    done
}

snapshot_search() {
    echo -e "\033[34mSearching for\033[0m $vm_name \033[34msnapshots...\nSnapshot Images Found:\033[0m $(\
		qemu-img snapshot -l "./../VM_Images/$vm_name.img" | grep 0 | wc -l)"
	qemu-img snapshot -l "./../VM_Images/$vm_name.img"
}

# Name / Info displayed on launch
app_name_info

# Main menu loop
while true; do
    main_menu
    read -p "Enter a number between 0-7: " option
    case $option in
        1) 
            echo -e "\033[34mStarting a VM or starting VM creation...\033[0m"
            vm_search
			./Scripts/qvm.sh
            ;;
        2) 
            echo -e "\033[34mListing all VMs...\033[0m"
            vm_search
            ;;
        3)
            echo -e "\033[34mCreating a snapshot...\033[0m"
            vm_search
            read -p "Enter VM name: " vm_name
            read -p "Enter snapshot name: " snapshot_name
            qemu-img snapshot -c "$snapshot_name" "./../VM_Images/$vm_name.img" && \
				echo -e "Snapshot saved successfully!\n" || echo -e "Snapshot creation failed!\n"
            ;;
        4)
            echo -e "\033[34mViewing snapshots...\033[0m"
            vm_search
			echo ""
            read -p "Enter VM name: " vm_name
            ckss=$(qemu-img snapshot -l "./../VM_Images/$vm_name.img")
			if [[ -z "$ckss" ]]; then
				echo -e "\033[34mNo snapshots have been saved of the \033[0m$vm_name\033[34m virtual machine yet!\033[0m"
			else
				qemu-img snapshot -l "./../VM_Images/$vm_name.img"
			fi
            ;;
        5)
            echo -e "\033[34mDeleting a snapshot...\033[0m"
            vm_search
			echo ""
            read -p "Enter VM name: " vm_name
            ckss=$(qemu-img snapshot -l "./../VM_Images/$vm_name.img")
			if [[ -z "$ckss" ]]; then
				echo -e "\033[34mNo snapshots have been saved of the \033[0m$vm_name\033[34m virtual machine yet!\033[0m"
			else
				snapshot_search
	            read -p "Enter snapshot tag: " snapshot_name
	            qemu-img snapshot -d "$snapshot_name" "./../VM_Images/$vm_name.img" && \
					echo -e "Snapshot deleted successfully!\n" || echo -e "Snapshot deletion failed!\n"
			fi
            ;;
        6)
            echo "\033[34mDeleting a VM...\033[0m"
            vm_search
            read -p "Enter VM name to delete: " vm_name
            read -p "Are you sure? [y/N]: " confirm
            if [[ "$confirm" =~ ^[yY]$ ]]; then
                rm "$HOME/QVM/config_files/VM_Images/$vm_name.img" && echo -e "$vm_name deleted!\n" || echo -e "Failed to delete $vm_name\n"
            else
                echo -e "\033[34mDeletion cancelled.\033[0m"
            fi
            ;;
        7)  
            ./Scripts/iso.sh
            ;;
        0)
            echo -e "\033[34mExiting... QVM was properly stopped!\033[0m\n"
            exit 0
            ;;
        *)
            echo -e "\033[34mInvalid option. Please try again.\033[0m"
            ;;
    esac
done
