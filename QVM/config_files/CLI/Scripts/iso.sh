#!/bin/bash



iso_menu() {
echo -e "$(cat << 'EOF'
\033[34m
------------------------------------------------------------------------
=================> QEMU Virtual Machine Manager ©2024 <================= 
----------------------- \033[0mISO File Management Menu\033[34m ----------------------- 

Options:\033[0m
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
\033[34m
------------------------------------------------------------------------
=================> QEMU Virtual Machine Manager ©2024 <================= 
-------------- \033[0mISO File Management Menu: Delete ISO image\033[34m -------------- 

Options:\033[0m
    1. Delete a specific ISO image
    2. Delete all ISO images
    0. Return to iso management menu
EOF
)"

read -p "Choose! : " option
case $option in
	1)	read -p "Enter the filename of the ISO image to delete: " delete
		[ -z "$delete" ] && echo -e "Invalid entry: Operation Cancelled!\n" && exit 1
	    read -p "Are you sure? [y/N]: " confirm
	    if [[ "$confirm" =~ ^[yY]$ ]]; then
			sudo rm "./../ISO_Images/${delete}" && \
				echo -e "\033[34mISO image\033[0m $delete \033[34mdeleted successfully!\033[0m\n" || echo -e "\033[34mFailed to delete the\033[0m $delete \033[34mimage!\033[0m\n"
		fi
	;;
	
	2)	read -p "Are you sure that you want to permanently delete all ISO images in your local database? [y/N]: " confirm
		[ -z "$confirm" ] && echo -e "\033[34mError: Invalid entry! Operation Cancelled.\033[0m\n" && exit 1
		if [[ "$confirm" =~ ^[yY]$ ]]; then
			sudo rm ~/"QVM/config_files/ISO Images/$(find . -type f -name "*.iso" | cut -d"/" -f3)" && \
			echo -e "\033[34mAll ISO images successfully deleted!\033[0m\n" || echo -e "\033[34mFailed to delete local ISO images!\033[0m\n"
		else
			echo -e "\033[34mOperation Cancelled! ISO images not deleted!\033[0m"
		fi
	;;
	
	0)	exit 0
	;;
	
	*)	echo -e "Error!"
	;;
esac
}

iso_search() {
    echo -e "\033[34mSearching for ISO images...\n\033[0m"
	echo -e "\033[34mISO Images Found:\033[0m $(find ~/QVM/config_files/ISO_Images -type f -name '*.iso' | wc -l)"
    echo -e "\033[34mISO images inside the QVM cdrom;\033[0m"
    find ~/QVM/ -type f -name "*.iso" | cut -d"/" -f8 | grep iso | sed 's/.iso/.iso (cdrom)/g'
    echo -e "\n\033[34mISO images stored in the QVM database;\033[0m"
	find ~/QVM/ -type f -name "*.iso" | cut -d"/" -f7 | grep -v cdrom
}

while true; do
	iso_menu
	read -p "Enter a number between 0-5: " option
	[ -z "$option" ] && echo -e "\033[34mError: Invalid entry! Operation Cancelled.\033[0m\n" && exit 1

	case $option in
		1)	echo -e "\033[34mListing ISO images..."
			iso_search
		;;
		
		2)	echo -e "\033[34mAvailable ISO images to download:\033[0m"
	        echo -e "Debian-12\nArch-Linux\nKali-Linux\nUbuntu-Noble-24.04\nRaspiOS\nOther..." | nl
			echo -e -n "\033[34m\nNote: You will need to force stop the QVM application in order to cancel a download.\nYou will also need to deleted the incomplete ISO download before trying again.\033[0m\nEnter the number associated with your desired image (Leave blank to cancel): "
	        read iso_img
			[ -z "$iso_img" ] && echo -e "Error: Invalid entry! Operation Cancelled.\n" && exit 1
			iso_search
			while true; do
#				iso_menu
				case $iso_img in
					1)	# Pull-ISO-Debian-12-Image
						if ! iso_search | grep "debian-12.iso" &>/dev/null; then
							url=$(elinks --dump https://debian.org/download | grep https | grep -E "netinst.iso" | awk -F"https" "{print \"https\" \$2}")
							echo -e "Downloading the Debian 12 ISO image...\n"
							sudo wget --no-cookies "$url" -O /home/kill-google/QVM/config_files/ISO_Images/debian-12.iso
							echo -e "\033[34mThe Debian 12 ISO image downloade successfully!\033[0m\n"
						else
							echo -e "A Debian ISO image has already been downloaded!\n"
						fi
						break
					;;
						
					2)	# Pull-ISO-ArchLinux-Image
						if ! iso_search | grep "archlinux.iso" &>/dev/null; then
							echo -e "Downloading the Arch Linux ISO image...\n"
							url=$(elinks -dump https://archlinux.mailtunnel.eu/iso/latest/ | awk -F ". " '{print $3}' | grep -v -E "sig|torrent|2024" | grep -i "x86_64.*\.iso"); 
								sudo wget --no-cookies "$url" -O "/home/kill-google/QVM/config_files/ISO_Images/archlinux.iso" && \ echo success! || echo error!
						else
							echo -e "A Arch Linux ISO image has already been downloaded!\n"
						fi
						break
					;;
						
					3)	# Pull-ISO-Kali-Linux-Image
						if ! iso_search | grep "kali-linux.iso" &>/dev/null; then
							echo -e "Downloading the Kali Linux ISO image...\n"
							url="https://cdimage.kali.org/kali-2024.4/kali-linux-2024.4-installer-netins\t-amd64.iso"
							sudo wget --no-cookies "$url" -O $HOME/QVM/config_files/ISO_Images/kali-linux.iso
						else
							echo -e "A Kali Linux ISO image has already been downloaded!\n"
						fi
						break
					;;
						
					4)	# Pull-ISO-Ubuntu-24-Noble-Image
						if ! iso_search | grep "ubuntu-noble.iso" &>/dev/null; then
							url=$(elinks --dump https://releases.ubuntu.com/noble | grep "https" | grep ".iso" | \
								grep -v -E "png|torrent|zsync" | awk -F". " "{print \$3}" | sort | uniq | grep desktop)
							echo -e "Downloading the Ubuntu 24.04 ISO image...\n"
							sudo wget --no-cookies "$url" -O "$HOME/QVM/config_files/ISO_Images/ubuntu-noble.iso" && \
								echo -e "\033[34mThe\033[0m Ubuntu 20.24 \033[34mimage downloaded successfully!\033[0m\n"
						else
							echo -e "A Ubuntu Noble ISO image has already been downloaded!\n"
						fi	
						break
					;;
				
					5)	# Pull-Raspi-OS-Image
						if ! iso_search | grep "raspios.iso" &>/dev/null; then
							echo -e "Downloading the Kali Linux ISO image...\n"
							url="https://cdimage.kali.org/kali-2024.4/kali-linux-2024.4-installer-netinst-amd64.iso"
							sudo wget --no-cookies "$url" -O /home/kill-google/QVM/config_files/ISO_Images/kali-linux.iso
						else
							echo -e "A Raspi OS ISO image has already been downloaded!\n"
						fi
						break
					;;
					
					6)	echo "More to come!! ;)"
					break
					;;
					
					*)
					;;
				esac
			done
		;;
		3)	echo -e "\033[34mSearching for ISO images...\033[0m"
			if ! find $HOME -type f -name "*.iso" | grep -v "ISO_Images"; then
				echo -e "\033[34mThe ISO search did not find any images to import!\n"
			else
				echo -e ""
				echo -e "\033[34mMoving the following ISO images to the QVM ISO image folder...\033[0m"
				find $HOME -type f -name "*.iso" | grep -v "ISO_Images"
				sudo mv $(find ~/ -type f -name "*.iso" | grep -v "ISO_Images") "ISO_Images"/ && \
					echo -e "\033[34mImage(s) successfully imported!\033[0m\n" || echo -e "\033[34mISO import failed!\033[0m\n"
			fi
		;;
		4)	echo -e "\033[34mChecking the QVM cdrom for ISO disk images...\033[0m"
			find $HOME/QVM/ -type f -name '*.iso' -print0 | grep -z cdrom | xargs -0 basename -a | nl -s ". "
			read -p "Which disk image should be ejected? (Enter '0' to cancel): " si
			[ -z $si ] && echo -e "\033[34mError: Invalid input!\033[0m" && exit 1
			if [[ "$si" == 0 ]]; then
				break
			fi
			iso=$(find $HOME/QVM/config_files/ISO_Images/cdrom/ -type f -name '*.iso' | tr -d '\0' | sed -n "${si}p")
			while true; do
				read -p "Eject the '$(echo $iso | xargs -0 basename -a)' disk image? [Y/n]: " eject
				if [[ "$eject" == "Y" || "$eject" == "y" || "$eject" == "yes" ]]; then
					sudo mv "$iso" "../ISO_Images/" && \
					echo -e "\033[34mThe '\033[0m$(echo $iso | xargs -0 basename -a)\033[34m' has been ejected!\033[0m" || \
					echo -e "\033[34mOperation Failed: An unexpected error has ocurred!"
					break
				elif [[ "$eject" == "N" || "$eject" == "n" || "$eject" == "no" ]]; then
					break
				else
					echo "Error: Invalid input!"
				fi
			done
		;;
		5)	echo -e "\033[34mListing ISO images..."
			iso_search
			delete-iso
		;;
		0)	exit 0
        ;;
		*)	echo -e "\033[34mInvalid option. Please try again.\033[0m"
		;;
	esac
done
