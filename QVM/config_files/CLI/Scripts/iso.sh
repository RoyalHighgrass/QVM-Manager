#!/bin/bash

b="\033[34m"
w="\033[0m"

iso_menu() {
echo -e "$(cat << 'EOF'

------------------------------------------------------------------------
=================> QEMU Virtual Machine Manager ©2024 <================= 
----------------------- ISO File Management Menu ----------------------- 

Options:
    1. View all ISO images
    2. Download an ISO image
    3. Import ISO images
    4. Eject an ISO image from the QVM cdrom
    5. Delete an ISO image
    0. Return to main menu 
EOF
)"
}

delete-iso() { echo -e "$(cat << 'EOF'

------------------------------------------------------------------------
=================> QEMU Virtual Machine Manager ©2024 <================= 
-------------- ISO File Management Menu: Delete ISO image -------------- 

Options:
    1. Delete a specific ISO image
    2. Delete all ISO images
    0. Return to iso management menu
EOF
)"

read -p "Enter a number to select an ISO image (Enter '0' or leave blank to cancel): " option

if ! [ "$option" = 0 ] || [ -z "$option" ]; then
	case $option in
		1)	iso_search
		echo ""
			read -p "Enter the filename of the ISO image to delete: " delete
			[ -z "$delete" ] && echo -e "Invalid entry: Operation Cancelled!\n" && exit 1
		    read -p "Are you sure? [y/N]: " confirm
		    if [ "$confirm" =~ ^[yY]$ ]; then
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
					0)	echo -e "${b}All ISO images successfully deleted!${w}\n"
					;;
					1)	echo -e "${b}Failed to delete local ISO images!${w}\n"
					;;
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

if [ "$1" = "-gi" ]; then
	iso_search
	exit 0
fi

while true; do
	iso_menu
	read -p "Enter a number between 0-5: " option
	[ -z "$option" ] && echo -e "${b}Error: Invalid entry! Operation Cancelled.${w}\n" && exit 1

	case $option in
		1)	echo -e "${b}Listing ISO images..."
			iso_search
		;;
		
		2)	echo -e "${b}Available ISO images to download:${w}"
	        echo -e "Debian 12\nArchLinux\nKali Linux\nUbuntu Noble\nUbuntu (Server)\nRaspiOS\nManjaro\nParrotOS\nOther..." | nl -s ". "
	        echo -e "${b}Note: Downloads can be cancelled by pressing '${w}CTRL+C${b}' once!${w}"
	        read -p "Enter a number to select an ISO image (Enter '0' or leave blank to cancel): " iso_img
			if [ "$iso_img" = "0" ]; then
				break
			fi
			[ -z "$iso_img" ] && echo -e "Error: Invalid entry! Operation Cancelled.\n" && exit 1
			while true; do
				case $iso_img in
					1)	# Pull-ISO-Debian-12-Image
						if ! iso_search | grep "debian-12.iso" &>/dev/null; then
							url=$(elinks --dump https://debian.org/download | grep https | grep -E "netinst.iso" | awk -F"https" "{print \"https\" \$2}")
				            read -p "Are you sure? [y/N]: " confirm
							if [ "$confirm" =~ ^[yY]$ ]; then
							    echo -e "${b}Downloading the Debian 12 ISO image...${w}\n"
							    if sudo wget --no-cookies "$url" -O "$HOME/QVM/config_files/ISO_Images/debian-12.iso"; then
							        echo -e "${b}The Debian 12 ISO image downloaded successfully!${w}\n"
							    else
							        echo -e "\n${b}Operation Error: Download failed!${w}\n"
							        sudo rm -f "$HOME/QVM/config_files/ISO_Images/debian-12.iso"
							    fi
							    break
							fi

						else
							echo -e "${b}A Debian ISO image has already been downloaded!\n${w}"
							break
						fi
					;;
						
					2)	# Pull-ISO-ArchLinux-Image
						if ! iso_search | grep "archlinux.iso" &>/dev/null; then
				            read -p "Are you sure? [y/N]: " confirm
				            if [ "$confirm" =~ ^[yY]$ ]; then
								echo -e "${b}Downloading the Arch Linux ISO image...\n${w}"
								url=$(elinks -dump https://archlinux.mailtunnel.eu/iso/latest/ | awk -F ". " '{print $3}' | \
									grep -v -E "sig|torrent|2024" | grep -i "x86_64.*\.iso"); 
								if sudo wget --no-cookies "$url" -O "$HOME/QVM/config_files/ISO_Images/archlinux.iso"; then
							        echo -e "${b}The ArchLinux ISO image downloaded successfully!${w}\n"
							    else
							        echo -e "\n${b}Operation Error: Download failed!${w}\n"
							        sudo rm -f "$HOME/QVM/config_files/ISO_Images/archlinux.iso"
								fi
								break
							fi
						else
							echo -e "${b}A Arch Linux ISO image has already been downloaded!\n${w}"
							break
						fi
					;;
						
					3)	# Pull-ISO-Kali-Linux-Image
						if ! iso_search | grep "kali-linux.iso" &>/dev/null; then
				            read -p "Are you sure? [y/N]: " confirm
				            if [ "$confirm" =~ ^[yY]$ ]; then
								echo -e "${b}Downloading the Kali Linux ISO image...\n${w}"
								url="https://cdimage.kali.org/kali-2024.4/kali-linux-2024.4-installer-netinst-amd64.iso"
								if sudo wget --no-cookies "$url" -O $HOME/QVM/config_files/ISO_Images/kali-linux.iso; then
							        echo -e "${b}The Kali Linux ISO image downloaded successfully!${w}\n"
								
							    else
							        echo -e "\n${b}Operation Error: Download failed!${w}\n"
							        sudo rm -f "$HOME/QVM/config_files/ISO_Images/kali-linux.iso"
								fi
								break
							fi
						else
							echo -e "${b}A Kali Linux ISO image has already been downloaded!\n${w}"
							break
						fi
					;;
						
					4)	# Pull-ISO-Ubuntu-24-Noble-Image
						if ! iso_search | grep "ubuntu-noble.iso" &>/dev/null; then
				            read -p "Are you sure? [y/N]: " confirm
				            if [ "$confirm" =~ ^[yY]$ ]; then
								url=$(elinks --dump https://releases.ubuntu.com/noble | grep "https" | grep ".iso" | \
									grep -v -E "png|torrent|zsync" | awk -F". " "{print \$3}" | sort | uniq | grep desktop)
								echo -e "${b}Downloading the Ubuntu 24.04 ISO image...\n${w}"
								if sudo wget --no-cookies "$url" -O "$HOME/QVM/config_files/ISO_Images/ubuntu-noble.iso"; then
									echo -e "${b}The${w} Ubuntu 20.24 ${b}image downloaded successfully!${w}\n"
								
							    else
							        echo -e "\n${b}Operation Error: Download failed!${w}\n"
							        sudo rm -f "$HOME/QVM/config_files/ISO_Images/ubuntu-noble.iso"
								fi
								break
							fi
						else
							echo -e "${b}A Ubuntu Noble ISO image has already been downloaded!\n${w}"
							break
						fi	
					;;
				
					5)	# Pull-Ubuntu-Server-Image
						url="https://releases.ubuntu.com/24.04.1/ubuntu-24.04.1-live-server-amd64.iso"
						iso_name=$()
						if ! iso_search | grep "ubuntu-server" &>/dev/null; then
				            read -p "Are you sure? [y/N]: " confirm
				            if [ "$confirm" =~ ^[yY]$ ]; then
								echo -e "${b}Downloading the $iso_name ISO image...\n${w}"
								if sudo wget --no-cookies "$url" -O $HOME/QVM/config_files/ISO_Images/ubuntu-server.iso; then
									echo -e "${b}The${w} Ubuntu Server ${b}image downloaded successfully!${w}\n"
								
							    else
							        echo -e "\n${b}Operation Error: Download failed!${w}\n"
							        sudo rm -f "$HOME/QVM/config_files/ISO_Images/ubuntu-server.iso"
								fi
								break
							fi
						else
							echo -e "${b}A Ubuntu Server ISO image has already been downloaded!\n${w}"
							break
						fi
					;;
					6)	# Pull-Raspi-OS-Image
						if ! iso_search | grep "raspios.iso" &>/dev/null; then
				            read -p "Are you sure? [y/N]: " confirm
				            if [ "$confirm" =~ ^[yY]$ ]; then
								echo -e "${b}Downloading the Kali Linux ISO image...\n${w}"
								url="https://downloads.raspberrypi.com/rpd_x86/images/rpd_x86-2022-07-04/2022-07-01-raspios-bullseye-i386.iso"
								if sudo wget --no-cookies "$url" -O $HOME/QVM/config_files/ISO_Images/raspios.iso; then
									echo -e "${b}The${w} Ubuntu 20.24 ${b}image downloaded successfully!${w}\n"
								
							    else
							        echo -e "\n${b}Operation Error: Download failed!${w}\n"
							        sudo rm -f "$HOME/QVM/config_files/ISO_Images/raspios.iso"
								fi
								break
							fi
						else
							echo -e "${b}A Raspi OS ISO image has already been downloaded!\n${w}"
							break
						fi
					;;
					
					7)	# Pull-Manjaro-Image
						while true; do
							echo -e "${b}Available Manjaro OS images;${w}"
		        			echo -e "Manjaro KDE Plasma\nManjaro Xfce\nManjaro GNOME" | nl
							read -p "Enter a number between 1-3 (Enter '0' to cancel): " manj_type
							case $manj_type in
								1)	manj_type="kde"
									url="https://download.manjaro.org/kde/24.2.1/manjaro-kde-24.2.1-241216-linux612.iso"
									break
								;;
								2)	manj_type="xfce"
									url="https://download.manjaro.org/xfce/24.2.1/manjaro-xfce-24.2.1-241216-linux612.iso"
									break
								;;
								3)	manj_type="gnome"
									url="https://download.manjaro.org/gnome/24.2.1/manjaro-gnome-24.2.1-241216-linux612.iso"
									break
								;;
								0)	exit 1
								;;
								*)	echo -e "${b}Error: Invalid entry! Enter a number between 1-3.${w}"
								;;
							esac
						done
						if ! iso_search | grep "manjaro" | grep "$manj_type" &>/dev/null; then
				            read -p "Are you sure? [y/N]: " confirm
				            if [ "$confirm" =~ ^[yY]$ ]; then
								iso_name=$(echo $url | awk -F "/" '{print $NF}' | cut -d. -f1)
								echo -e "${b}Downloading the $iso_name ISO image...\n${w}"
								if sudo wget --no-cookies "$url" -O $HOME/QVM/config_files/ISO_Images/${iso_name}.iso; then 
									echo -e "${b}The${w} Ubuntu 20.24 ${b}image downloaded successfully!${w}\n"
								
							    else
							        echo -e "\n${b}Operation Error: Download failed!${w}\n"
							        sudo rm -f "$HOME/QVM/config_files/ISO_Images/${iso_name}.iso"
								fi
								break
							fi
						else
							echo -e "${b}Operation failed: A '${w}manjaro-$manj_type${b}' image has already been downloaded!\n${w}"
							break
						fi
					;;
					8) # Pull-Parrot-OS-Image
						url="https://deb.parrot.sh/parrot/iso/6.2/Parrot-security-6.2_amd64.iso"
						iso_name=$(echo $url | awk -F "/" '{print $NF}' | cut -d. -f1)
						if ! iso_search | grep "$iso_name" &>/dev/null; then
				            read -p "Are you sure? [y/N]: " confirm
				            if [ "$confirm" =~ ^[yY]$ ]; then
								echo -e "${b}Downloading the $iso_name ISO image...\n${w}"
								if sudo wget --no-cookies "$url" -O $HOME/QVM/config_files/ISO_Images/${iso_name}.iso; then
									echo -e "${b}The${w} Ubuntu 20.24 ${b}image downloaded successfully!${w}\n"
								
							    else
							        echo -e "\n${b}Operation Error: Download failed!${w}\n"
							        sudo rm -f "$HOME/QVM/config_files/ISO_Images/${iso_name}.iso"
								fi
								break
							fi
						else
							echo -e "${b}A $iso_name image has already been downloaded!\n${w}"
							break
						fi
					;;
					9)	# Pull-Other-Images
						read -p "Enter the full download URL for your desired ISO image (Enter '0' to cancel): " other_iso
						if ! [ "$other_iso" = "0" ] || [ -z "$other_iso" ]; then
							url="$other_iso"
							other_iso_name=$(echo $url | awk -F "/" '{print $NF}' | cut -d. -f1)
				            read -p "Are you sure? [y/N]: " confirm
				            if [ "$confirm" =~ ^[yY]$ ]; then
								echo -e "${b}Downloading the${w} $other_iso_name ${b}ISO image...${w}\n"
								if ! [ $(iso_search | grep "$other_iso_name") ]; then
									if sudo wget --no-cookies "$url" -O $HOME/QVM/config_files/ISO_Images/${other_iso_name}.iso; then
										echo -e "${b}The${w} Ubuntu 20.24 ${b}image downloaded successfully!${w}\n"
								    else
								        echo -e "\n${b}Operation Error: Download failed!${w}n\n"
								        sudo rm -f "$HOME/QVM/config_files/ISO_Images/${other_iso_name}.iso"
									fi
									break
								else
									echo -e "${b}Error: That OS disk image has already been downloaded & is ready to use!${w}"
									break
								fi
							fi
						fi
						break
					;;
					
					*)
					;;
				esac
			done
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
			            0)
			                echo -e "${b}Image '$file' successfully imported as '$new_name'!${w}"
			                ;;
			            1)
			                echo -e "${b}ISO import failed for '$file'!${w}"
			                ;;
			        esac
			        echo -e ""
			    done || echo -e "${b}ISO import failed!${w}"
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
					if ! [ "$si" =~ ^[0-9]+$ ]; then
						echo -e "${b}Error: Invalid entry!${w}"
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
						echo -e "${b}Operation Failed: An unexpected error has ocurred!"
						break
					elif [ "$eject" = "N" ] || [ "$eject" = "n" ] || [ "$eject" = "no" ]; then
						break
					else
						echo "Error: Invalid input!"
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
		*)	echo -e "${b}Invalid option. Please try again.${w}"
		;;
	esac
done
