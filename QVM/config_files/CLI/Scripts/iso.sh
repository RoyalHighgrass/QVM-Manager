
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
    4. Delete an ISO image
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
			sudo rm "./../ISO_Images/$delete" && \
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
    find ~/QVM/config_files/ISO_Images -type f -name "*.iso" | cut -d"/" -f7 | nl -s'. ' -w5
}

while true; do
	iso_menu
	read -p "Enter a number between 0-4: " option
	[ -z "$option" ] && echo -e "Error: Invalid entry! Operation Cancelled.\n" && exit 1

	case $option in
		1)	echo -e "\033[34mListing ISO images..."
			iso_search
		;;
		
		2)	echo -e "\033[34mAvailable ISO images to download:\033[0m"
	        echo -e "Debian 12 - D"
	        echo -e "ArchLinux - A"
	        echo -e "Kali Linux - K"
	        echo -e "Ubuntu 24.04 - U"
			echo -e -n "\nEnter the letter associated with your \ndesired image (Leave blank to cancel): "
	        read iso_img
			[ -z "$iso_img" ] && echo -e "Error: Invalid entry! Operation Cancelled.\n" && exit 1
			while true; do
#				iso_menu
				iso_search
				case $iso_img in
					D)	# Pull-ISO-Debian-12-Image
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
						
					A)	# Pull-ISO-ArchLinux-Image
						echo -e "Downloading the Arch Linux ISO image...\n"
						urls=$(elinks -dump https://archlinux.mailtunnel.eu/iso/2024.07.01/ | grep -i "x86_64.*\.iso" | nl); 
							echo "$urls"; 
							read -p "Enter the number of the ISO you want to download: " choice; 
							selected_url=$(echo "$urls" | awk -v num=$choice "$1 == num {print $NF}"); 
							sudo wget --no-cookies "$selected_url -O /home/kill-google/QVM/config_files/ISO_Images/archlinux.iso"
						break
					;;
						
					K)	# Pull-ISO-KaliLinux-Image
						echo -e "Downloading the Kali Linux ISO image...\n"
						sudo wget --no-cookies "$url" -O /home/kill-google/QVM/config_files/ISO_Images/kali-linux.iso
						break
					;;
						
					U)	# Pull-ISO-Ubuntu-24-Image
						urls=$(elinks --dump https://releases.ubuntu.com/noble | grep "https" | grep ".iso" | \
							grep -v -E "png|torrent|zsync" | awk -F". " "{print \$3}" | sort | uniq)
						echo -e -n "Which version of Ubuntu would you like to download? Enter either 1 or 2: " version
						echo -e "Downloading the Ubuntu 24.04 ISO image...\n"
						case $version in
							1)	url=$(echo $urls | grep desktop)
							;;
							2)	url=$(echo $urls | grep server)
							;;
							*)	echo -e "Error: Invalid Entry!"
							;;
						esac
						sudo wget --no-cookies "$url" -O /home/kill-google/QVM/config_files/ISO_Images/ubuntu-24.iso
						echo -e "\033[34mThe\033[0m Ubuntu 20.24 \033[34mimage downloaded successfully!\033[0m\n"
						break
					;;
				
					*)
					;;
				esac
			done
		;;
		3)	echo -e "\033[34mSearching for ISO images...\033[0m"
			if ! find ~/ -type f -name "*.iso" | grep -v "ISO Images"; then
				echo -e "The ISO search did not find any images to import!\n"
			else
				echo -e ""
				echo -e "\033[34mMoving the following ISO images to the QVM ISO image folder...\033[0m"
				find ~/ -type f -name "*.iso" | grep -v "ISO Images"
				sudo mv $(find ~/ -type f -name "*.iso" | grep -v "ISO Images") "ISO Images"/ && \
					echo -e "\033[34mImage(s) successfully imported!\n" || echo -e "ISO import failed!\033[0m\n"
			fi
		;;
		4)	echo -e "\033[34mListing ISO images..."
			iso_search
			delete-iso
		;;
		0)	exit 0
        ;;
		*)	echo -e "\033[34mInvalid option. Please try again.\033[0m"
		;;
	esac
done
