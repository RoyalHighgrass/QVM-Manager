#!/bin/bash

# Text colours
b="\033[34m"
w="\033[0m"

app_name_info() { echo -e "$(cat << 'EOF'
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

------------------------------------------------------------------------
=========> QEMU Virtual Machine Manager ©2024 <=========
------------------------------- Main Menu ------------------------------

Select one of the following options;

Options:
    1. Create or start VM
    2. List all VMs
    3. Save a VM snapshot
    4. View snapshots
    5. Delete a snapshot
    6. Delete a VM
    7. ISO images
    0. Exit
EOF
)"
}

trap 'echo -e "\n${b}Exiting... QVM was forced to stop running!${w}\n" && exit 1' SIGINT

vm_search() {
    echo -e "${b}Searching for VMs...\n${w}"
    echo -e "${b}VM Images Found:${w} $(find ~/QVM/config_files/VM_Images -type f -name '*.img' | wc -l)"
    
    # Find VM disk image files and extract names
    vms=$(find ~/QVM/config_files/VM_Images/ -type f -name "*.img" | cut -d"/" -f7 | cut -d"." -f1)
     
    # Get list of running VMs
    running_vms=$(ps aux | grep qemu-system | awk -F '/' '{print $NF}' | awk -F ".img" '{print $1}')
    
    echo -e "${b}VM Name:	     Status:${w}"
    
    # Loop through each VM and check its status
    echo "$vms" | while read -r vm; do
        if [ "$(find ~/QVM/config_files/VM_Images -type f -name '*.img' | wc -l)" = "0" ]; then
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
    echo -e "${b}Searching for${w} $vm_name ${b}snapshots...\nSnapshot Images Found:${w} $(\
		qemu-img snapshot -l "./../VM_Images/$vm_name.img" | grep 0 | wc -l)"
	qemu-img snapshot -l "./../VM_Images/$vm_name.img" | sed 's/_//g'
}

if [ "$1" = "-gv" ]; then
	vm_search
	exit 0
fi

# Name / Info displayed on launch
app_name_info

# Main menu loop
while true; do
    main_menu
    read -p "Enter a number between 0-7: " option
    case $option in
        1) 
            echo -e "${b}Starting a VM or starting VM creation...${w}"
            vm_search
			./Scripts/qvm.sh
            ;;
        2) 
            echo -e "${b}Listing all VMs...${w}"
            vm_search
            ;;
        3)
            echo -e "${b}Creating a snapshot...${w}"
            vm_search
            if (( $(vm_search | grep "Found" | awk '{print $NF}') != 0 )); then
				echo ""
				read -p "Enter a VM name (Enter '0' or leave blank to cancel): " vm_name
				if ! [ "$vm_name" = "0" ] || [ -z "$vm_name" ]; then
		            read -p "Enter snapshot name/tag: " snapshot_name
		            qemu-img snapshot -c "\_${snapshot_name}\_" "./../VM_Images/$vm_name.img" && \
						echo -e "Snapshot saved successfully!\n" || echo -e "Snapshot creation failed!\n"
				fi
			else
				echo -e "${b}You have not created any virtual machines yet! Please create a VM in order to save a snapshot.${w}"
			fi
            ;;
        4)
            echo -e "${b}Viewing snapshots...${w}"
            vm_search
            if (( $(vm_search | grep "Found" | awk '{print $NF}') != 0 )); then
	            echo ""
				read -p "Enter a VM name (Enter '0' or leave blank to cancel): " vm_name
				if ! [ "$vm_name" = "0" ] || [ -z "$vm_name" ]; then
		            ckss=$(qemu-img snapshot -l "./../VM_Images/$vm_name.img")
					if [ -z "$ckss" ]; then
						echo -e "${b}No snapshots have been saved of the ${w}$vm_name${b} virtual machine!${w}"
					else
						qemu-img snapshot -l "./../VM_Images/$vm_name.img" | sed 's/_//g'
					fi
				fi
			else
				echo -e "${b}You have not created any virtual machines yet! Please create a VM in order to view saved snapshots.${w}"
			fi
            ;;
        5)
            echo -e "${b}Deleting a snapshot...${w}"
            vm_search
            if (( $(vm_search | grep "Found" | awk '{print $NF}') != 0 )); then
				echo ""
	            read -p "Enter a VM name (Enter '0' or leave blank to cancel): " vm_name
				if ! [ "$vm_name" = "0" ] || [ -z "$vm_name" ]; then
		            ckss=$(qemu-img snapshot -l "./../VM_Images/$vm_name.img")
					if [ -z "$ckss" ]; then
						echo -e "${b}No snapshots have been saved of the ${w}$vm_name${b} virtual machine!${w}"
					else
						snapshot_search
			            read -p "Enter snapshot name/tag (Enter '0' to cancel): " snapshot_name
			            qemu-img snapshot -d "_${snapshot_name}_" "./../VM_Images/$vm_name.img" && \
							echo -e "${b}Snapshot deleted successfully!${w}\n" || echo -e "${b}Snapshot deletion failed!${w}\n"
					fi
				fi
			else
				echo -e "${b}You have not created any virtual machines yet! Please create a VM in order to delete a snapshot.${w}"
			fi
            ;;
        6)
            echo -e "${b}Deleting a VM...${w}"
            vm_search
            if (( $(vm_search | grep "Found" | awk '{print $NF}') != 0 )); then
	            echo ""
				read -p "Enter the name of the VM to delete (Enter '0' or leave blank to cancel): " vm_name
				if ! [ "$vm_name" = "0" ] || [ -z "$vm_name" ]; then
		            read -p "Are you sure? [y/N]: " confirm
		            if [[ "$confirm" =~ ^[yY]$ ]]; then
		                rm "$HOME/QVM/config_files/VM_Images/$vm_name.img" && \
						rm "$HOME/QVM/config_files/vm_log_files/${vm_name}_vm_specs" && \
						rm "$HOME/QVM/config_files/vm_log_files/${vm_name}_vm_restart" && \
						echo -e "The $vm_name VM has been deleted!\n" || echo -e "Failed to delete the $vm_name VM\n"
		            else
		                echo -e "${b}Deletion cancelled.${w}"
		            fi
				fi
			else
				echo -e "${b}You cannot delete a VM because you have not created any virtual machines yet!${w}"
			fi
            ;;
        7)  
            ./Scripts/iso.sh
            ;;
        0)
            echo -e "${b}QVM was properly stopped!${w}\n"
            exit 0
            ;;
        *)
            echo -e "${b}Invalid option. Please try again...${w}"
            ;;
    esac
done
