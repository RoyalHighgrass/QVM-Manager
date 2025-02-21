h#!/bin/bash

b="\033[34m"
w="\033[0m"

iso_menu() {
echo -e "
------------------------------------------------------------------------
=================> QEMU Virtual Machine Manager ©2024 <================= 
----------------------- ISO File Management Menu -----------------------
${b}ISO File Management Menu:${w}

Options:
    1. View all ISO images
    2. Download an ISO image
    3. Import ISO images
    4. Eject an ISO image from the QVM cdrom
    5. Delete an ISO image
    0. Return to main menu"
}

delete-iso() { echo -e "
------------------------------------------------------------------------
================> ${b}QEMU Virtual Machine Manager © 2024${w} <================= 
------------------------------------------------------------------------
${b}ISO File Management Menu < Delete ISO image:${w}

Options:
    1. Delete a specific ISO image
    2. Delete all ISO images
    0. Return to iso management menu"

read -p "Enter a number to select an ISO image (Enter '0' or leave blank to cancel): " option

if ! [ "$option" = 0 ] || [ -z "$option" ]; then
	case $option in
		1)	iso_search
		echo ""
			read -p "Enter the filename of the ISO image to delete: " delete
			[ -z "$delete" ] && echo -e "Invalid entry: Operation Cancelled!\n" && exit 1
		    read -p "Are you sure? [y/N]: " confirm
		    if [[ "$confirm" =~ ^[yY]$ ]]; then
				sudo rm "./../ISO_Images/${delete}" && \
					echo -e "${b}ISO image${w} $delete ${b}deleted successfully!${w}\n" || \
					echo -e "${b}Failed to delete the${w} $delete ${b}image!${w}\n"
			fi
		;;
		2)	read -p "Are you sure that you want to permanently delete all ISO images in your local database? [y/N]: " confirm
			if [ -z "$confirm" ] || [ "$confirm" = ^[Nn]o$ ]; then
				echo -e "${b}Operation Cancelled! ISO images not deleted!${w}"
			elif [ "$confirm" = [Yy] ]; then
				sudo rm $HOME/QVM/config_files/ISO_Images/*.iso
				case $? in
					0)	echo -e "${b}All ISO images successfully deleted!${w}\n";;
					1)	echo -e "${b}Failed to delete local ISO images!${w}\n";;
				esac
			else
				echo -e "${b}Error: Invalid entry! Operation Cancelled.${w}\n" && exit 1
			fi
		;;
		0)	exit 0
		;;
		*)	echo -e "Error!"
		;;
	esac
fi
}

iso_search() {
    echo -e "${b}Searching for ISO images...\n${w}"
	echo -e "${b}ISO Images Found:${w} $(find ~/QVM/config_files/ISO_Images -type f -name '*.iso' | wc -l)"
    echo -e "${b}ISO images inside the QVM cdrom;${w}"
    find ~/QVM/ -type f -name "*.iso" | cut -d"/" -f8 | grep iso | sed 's/.iso/.iso (cdrom)/g'
    echo -e "\n${b}ISO images stored in the QVM filesystem;${w}"
	find ~/QVM/ -type f -name "*.iso" | cut -d"/" -f7 | grep -v cdrom
}

get_url() {
    if ! iso_search | grep "${1}.iso" &>/dev/null; then
		local url=$(./../settings/recommended_iso_files.sh "$1" "$2")
		echo "$url"
	else
		echo -e "qvm-manager: Operation cancelled! Image already downloaded!"
	fi
}

if [ "$1" = "-gi" ]; then
	iso_search
	exit 0
fi

while true; do
	echo -e "${b}"
 	iso_menu
	echo -e "${w}"
 	read -p "Enter a number between 0-5: " option
	case $option in
		1)	echo -e "${b}Listing ISO images..."
			iso_search
		;;
		
		2)	echo -e "${b}Available ISO images to download:${w}"
	        echo -e "Debian 12\nArchLinux\nKali Linux\nUbuntu Noble\nUbuntu Server\nRaspiOS\nManjaro\nParrotOS\nFedora\nLinux Mint\nOther..." | nl -s ". "
	        echo -e "${b}Note: Downloads can be cancelled by pressing '${w}CTRL+C${b}' once!${w}"
	        read -p "Enter a number to select an ISO image (Enter '0' or leave blank to cancel): " iso_img
			if [ "$iso_img" = "0" ]; then
				break
			fi
			[ -z "$iso_img" ] && echo -e "${b}qvm-manager: Error: Invalid entry! Operation Cancelled.${w}" && exit 1
			case $iso_img in
					1)	# Pull-ISO-Debian-12-Image
						echo -n -e "${b}Retrieving the Debian 12 image URL ... ${w}"
						iso_name="debian-12"
						url=$(get_url "$iso_name")
						echo -e "${b}done.${w}"
					;;
					2)	# Pull-ISO-Arch-Linux-Image
						echo -n -e "${b}Retrieving the Arch Linux image URL ... ${w}"
						iso_name="arch-linux"
						url=$(get_url "$iso_name")
						echo -e "${b}done.${w}"
					;;
					3)	# Pull-ISO-Kali-Linux-Image
						echo -n -e "${b}Retrieving the Kali Linux image URL ... ${w}"
						iso_name="kali-linux"
						url=$(get_url "$iso_name")
						echo -e "${b}done.${w}"
					;;
					4)	# Pull-ISO-Ubuntu-Noble-Image
						echo -n -e "${b}Retrieving the Ubuntu Noble image URL ... ${w}"
						iso_name="ubuntu-noble"
						url=$(get_url "$iso_name")
						echo -e "${b}done.${w}"
					;;
					5)	# Pull-ISO-Ubuntu-Server-Image
						echo -n -e "${b}Retrieving the Ubuntu Server image URL ... ${w}"
						iso_name="ubuntu-server"
						url=$(get_url "$iso_name")
						echo -e "${b}done.${w}"
					;;
					6)	# Pull-ISO-Raspi-OS-Image
						echo -n -e "${b}Retrieving the RaspiOS image URL ... ${w}"
						iso_name="raspi-os"
						url=$(get_url "$iso_name")
						echo -e "${b}done.${w}"
					;;
					7)	# Pull-ISO-Manjaro-Image
						echo -e "${b}Available Manjaro ISO images:${w}"
				        echo -e "Manjaro KDE Desktop\nManjaro Xfce Desktop\nManjaro Gnome Desktop" | nl -s ". "
				        echo -e "${b}Note: Downloads can be cancelled by pressing '${w}CTRL+C${b}' once!${w}"
				        read -p "Enter a number to select an ISO image (Enter '0' or leave blank to cancel): " manj_type
						if [ "$manj_type" = "0" ]; then
							echo -e "${b}qvm-manager: Error! Invalid input!${w}"
							break
						fi
						iso_name="manjaro-"
						case "$manj_type" in
							1)	echo -n "Retrieving the Manjaro KDE image URL ... ${w}"
								iso_name+="kde"
								url=$(get_url "$iso_name")
								echo -e "${b}done.${w}"
							;;
							2)	echo -n "Retrieving the Manjaro Xfce image URL ... ${w}"
								iso_name+="xfce"
								url=$(get_url "$iso_name")
								echo -e "${b}done.${w}"
							;;
							3)	echo -n "Retrieving the Manjaro Gnome image URL ... ${w}"
								iso_name+="gnome"
								url=$(get_url "$iso_name")
								echo -e "${b}done.${w}"
							;;
						esac
					;;
					8)	# Pull-ISO-Parrot-OS-Image
						echo -n "Retrieving the Parrot OS image URL ... ${w}"
						iso_name="parrot-os"
						url=$(get_url "$iso_name")
						echo -e "${b}done.${w}"
					;;
					9)	# Pull-ISO-Fedora-Image
						echo -n "Retrieving the Fedora image URL ... ${w}"
						iso_name="fedora"
						url=$(get_url "$iso_name")
						echo -e "${b}done.${w}"
					;;
					10)	# Pull-ISO-Linux-Mint-Image
						echo -e "${b}Available Linux Mint ISO images:${w}"
				        echo -e "Linux Mint Cinnamon Desktop\nLinux Mint Xfce Desktop\nLinux Mint Mate Desktop" | nl -s ". "
				        echo -e "${b}Note: Downloads can be cancelled by pressing '${w}CTRL+C${b}' once!${w}"
				        read -p "Enter a number to select an ISO image (Enter '0' or leave blank to cancel): " mint_type
						if [ "$mint_type" = "0" ]; then
							echo -e "${b}qvm-manager: Error! Invalid input!${w}"
							break
						fi
						iso_name="linux-mint"
						case "$mint_type" in
							1)	echo -n -e "${b}Retrieving the Linux Mint Cinnamon image URL ... ${w}"
								url=$(get_url "$iso_name" "cin")
								iso_name+="-cinnamon"
								echo -e "${b}done."${w}
							;;
							2)	echo -n -e "${b}Retrieving the Linux Mint Xfce image URL ... ${w}"
								url=$(get_url "$iso_name" "xfce")
								iso_name+="-xfce"
								echo -e "${b}done."${w}
							;;
							3)	echo -n -e "${b}Retrieving the Linux Mint Mate image URL ... ${w}"
								url=$(get_url "$iso_name" "mate")
								iso_name+="-mate"
								echo -e "${b}done.${w}"
							;;
						esac
					;;
					11)	# Pull-Other-Images
						read -p "Enter the full download URL for your desired ISO image (Enter '0' to cancel): " other_iso
						if ! [ "$other_iso" = "0" ] || [ -z "$other_iso" ]; then
							url="$other_iso"
							other_iso_name=$(echo $url | awk -F "/" '{print $NF}' | cut -d. -f1)
				            read -p "Are you sure? [y/N]: " confirm
				            if [[ "$confirm" =~ ^[yY]$ ]]; then
								echo -e "${b}Downloading the${w} $other_iso_name ${b}ISO image...${w}\n"
								if ! [ $(iso_search | grep "$other_iso_name") ]; then
									if sudo wget --no-cookies "$url" -O $HOME/QVM/config_files/ISO_Images/${other_iso_name}.iso; then
										echo -e "${b}The${w} ${b}image downloaded successfully!${w}\n"
								    else
								        echo -e "\n${b}qvm-manager: Operation Error: Download failed!${w}n\n"
								        sudo rm -f "$HOME/QVM/config_files/ISO_Images/${other_iso_name}.iso"
									fi
									break
								else
									echo -e "${b}qvm-manager: Error: That OS disk image has already been downloaded!${w}"
									break
								fi
							fi
						fi
						exit 0
					;;
					*)
					;;
				esac
			    if iso_search | grep "$iso_name.iso" &>/dev/null; then
					echo -e "${b}qvm-manager: Operation cancelled! That OS disk image has already been downloaded!${w}"
					exit 1
				fi
				echo -e "${b}$url${w}"
				if ! [ -z "$url" ]; then
			        read -p "Are you sure you want to download this image? [y/N]: " confirm
			        if [[ "$confirm" =~ ^[yY]$ ]]; then
						echo -e "${b}Downloading the $iso_name ISO image...${w}"
						if sudo wget --no-cookies "$url" -O $HOME/QVM/config_files/ISO_Images/${iso_name}.iso; then
							echo -e "${b}The${w} "$iso_name" ${b}image downloaded successfully!${w}\n"
						else
						    echo -e "\n${b}qvm-manager: Operation Error: Download failed!${w}\n"
						    sudo rm -f "$HOME/QVM/config_files/ISO_Images/${iso_name}.iso"
						fi
						break
					fi
				fi				
		;;
		3)	# Inform the user that the search for ISO images is starting
			echo -e "${b}Searching for ISO images...${w}"
			
			# Search for ISO files excluding the "ISO_Images" directory
			if ! find "$HOME" -type f -name "*.iso" | grep -v "ISO_Images"; then
			    echo -e "${b}The ISO search did not find any images to import!\n${w}"
			else
			    echo -e "\n${b}Moving the following ISO images to the QVM ISO image folder...${w}"
			
			    # Store the list of found ISO files in a variable
			    list=$(find "$HOME" -type f -name "*.iso" | grep -v "ISO_Images")
			    echo "$list"
			    # Iterate over each found file
			    for file in $list; do
			        # Construct the new file path
			        new_name="$HOME/QVM/config_files/ISO_Images/${file##*/}"  # Use ##*/ to get only the filename
			        new_name=$(echo $new_name | cut -d. -f1)
			        new_name="${new_name%.*}.iso"  # Ensure it has .iso extension
			        # Move the file and check if it was successful
			        sudo mv "$file" "$new_name"
			        case $? in
			            0)	echo -e "${b}Image '$file' successfully imported as '$new_name'!${w}";;
			            1)	echo -e "${b}qvm-manager: ISO import failed for '$file'!${w}";;
			        esac
			        echo -e ""
			    done || echo -e "${b}qvm-manager: ISO import failed!${w}"
			fi

		;;
		4)	echo -e "${b}Checking the QVM cdrom for ISO disk images...${w}"
			echo -e "${b}Images found...${w}"
			ckcdrom=$(find $HOME/QVM/ -type f -name '*.iso' | grep cdrom | awk -F '/' '{print $NF}' | nl -s ". ")
			if ! [ -z "$ckcdrom" ]; then
				while true; do
					find $HOME/QVM/ -type f -name '*.iso' | grep cdrom | awk -F '/' '{print $NF}' | nl -s ". "
					read -p "Which disk image should be ejected? (Enter '0' to cancel): " si
					if [ -z $si ] || [ "$si" = 0 ]; then
						echo -e "${b}Operation cancelled!${w}"
						exit 1
					fi
					if ! [[ "$si" =~ ^[0-9]+$ ]]; then
						echo -e "${b}qvm-manager: Error: Invalid entry!${w}"
					else
						break
					fi
				done
				iso=$(find $HOME/QVM/config_files/ISO_Images/cdrom/ -type f -name '*.iso' | tr -d '\0' | sed -n "${si}p")
				while true; do
					read -p "Eject the '$(basename $iso)' disk image? [Y/n]: " eject
					if [ "$eject" = "Y" ] || [ "$eject" = "y" ] || [ "$eject" = "yes" ]; then
						sudo mv "$iso" "../ISO_Images/" && \
						echo -e "${b}The '${w}$(echo $iso | xargs -0 basename -a)${b}' ISO disk image has been ejected!${w}" || \
						echo -e "${b}qvm-manager: Operation Failed: An unexpected error has ocurred!"
						break
					elif [ "$eject" = "N" ] || [ "$eject" = "n" ] || [ "$eject" = "no" ]; then
						break
					else
						echo "qvm-manager: Error: Invalid input!"
					fi
				done
			else
				echo -e "\n${b}The QVM cdrom is empty!${w}"
			fi
		;;
		5)	echo -e "${b}Listing ISO images..."
			delete-iso
		;;
		0)	exit 0
        ;;
		*)	echo -e "${b}qvm-manager: Invalid option! Please try again.${w}"
		;;
	esac
done
