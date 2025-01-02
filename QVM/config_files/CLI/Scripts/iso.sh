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

read -p "Enter a number to select an ISO image (Enter '0' or leave blank to cancel): " option

if ! [[ "$option" == "0" || -z "$option" ]]; then
	case $option in
		1)	iso_search
		echo ""
			read -p "Enter the filename of the ISO image to delete: " delete
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
fi
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
	        echo -e "Debian 12\nArchLinux\nKali Linux\nUbuntu Noble\nUbuntu (Server)\nRaspiOS\nManjaro\nParrotOS\nOther..." | nl -s ". "
	        read -p "Enter a number to select an ISO image (Enter '0' or leave blank to cancel): " iso_img
			if [[ "$iso_img" == "0" ]]; then
				break
			fi
			[ -z "$iso_img" ] && echo -e "Error: Invalid entry! Operation Cancelled.\n" && exit 1
			while true; do
#				iso_menu
				case $iso_img in
					1)	# Pull-ISO-Debian-12-Image
						if ! iso_search | grep "debian-12.iso" &>/dev/null; then
							url=$(elinks --dump https://debian.org/download | grep https | grep -E "netinst.iso" | awk -F"https" "{print \"https\" \$2}")
				            read -p "Are you sure? [y/N]: " confirm
							if [[ "$confirm" =~ ^[yY]$ ]]; then
							    echo -e "\033[34mDownloading the Debian 12 ISO image...\033[0m\n"
							    if sudo wget --no-cookies "$url" -O "$HOME/QVM/config_files/ISO_Images/debian-12.iso"; then
							        echo -e "\033[34mThe Debian 12 ISO image downloaded successfully!\033[0m\n"
							    else
							        echo -e "\n\033[34mOperation Error: Download failed!\033[0m\n"
							        sudo rm -f "$HOME/QVM/config_files/ISO_Images/debian-12.iso"
							    fi
							    break
							fi

						else
							echo -e "\033[34mA Debian ISO image has already been downloaded!\n\033[0m"
							break
						fi
					;;
						
					2)	# Pull-ISO-ArchLinux-Image
						if ! iso_search | grep "archlinux.iso" &>/dev/null; then
				            read -p "Are you sure? [y/N]: " confirm
				            if [[ "$confirm" =~ ^[yY]$ ]]; then
								echo -e "\033[34mDownloading the Arch Linux ISO image...\n\033[0m"
								url=$(elinks -dump https://archlinux.mailtunnel.eu/iso/latest/ | awk -F ". " '{print $3}' | \
									grep -v -E "sig|torrent|2024" | grep -i "x86_64.*\.iso"); 
								if sudo wget --no-cookies "$url" -O "$HOME/QVM/config_files/ISO_Images/archlinux.iso"; then
							        echo -e "\033[34mThe ArchLinux ISO image downloaded successfully!\033[0m\n"
							    else
							        echo -e "\n\033[34mOperation Error: Download failed!\033[0m\n"
							        sudo rm -f "$HOME/QVM/config_files/ISO_Images/archlinux.iso"
								fi
								break
							fi
						else
							echo -e "\033[34mA Arch Linux ISO image has already been downloaded!\n\033[0m"
							break
						fi
					;;
						
					3)	# Pull-ISO-Kali-Linux-Image
						if ! iso_search | grep "kali-linux.iso" &>/dev/null; then
				            read -p "Are you sure? [y/N]: " confirm
				            if [[ "$confirm" =~ ^[yY]$ ]]; then
								echo -e "\033[34mDownloading the Kali Linux ISO image...\n\033[0m"
								url="https://cdimage.kali.org/kali-2024.4/kali-linux-2024.4-installer-netins\t-amd64.iso"
								if sudo wget --no-cookies "$url" -O $HOME/QVM/config_files/ISO_Images/kali-linux.iso; then
							        echo -e "\033[34mThe Kali Linux ISO image downloaded successfully!\033[0m\n"
								
							    else
							        echo -e "\n\033[34mOperation Error: Download failed!\033[0m\n"
							        sudo rm -f "$HOME/QVM/config_files/ISO_Images/kali-linux.iso"
								fi
								break
							fi
						else
							echo -e "\033[34mA Kali Linux ISO image has already been downloaded!\n\033[0m"
							break
						fi
					;;
						
					4)	# Pull-ISO-Ubuntu-24-Noble-Image
						if ! iso_search | grep "ubuntu-noble.iso" &>/dev/null; then
				            read -p "Are you sure? [y/N]: " confirm
				            if [[ "$confirm" =~ ^[yY]$ ]]; then
								url=$(elinks --dump https://releases.ubuntu.com/noble | grep "https" | grep ".iso" | \
									grep -v -E "png|torrent|zsync" | awk -F". " "{print \$3}" | sort | uniq | grep desktop)
								echo -e "\033[34mDownloading the Ubuntu 24.04 ISO image...\n\033[0m"
								if sudo wget --no-cookies "$url" -O "$HOME/QVM/config_files/ISO_Images/ubuntu-noble.iso"; then
									echo -e "\033[34mThe\033[0m Ubuntu 20.24 \033[34mimage downloaded successfully!\033[0m\n"
								
							    else
							        echo -e "\n\033[34mOperation Error: Download failed!\033[0m\n"
							        sudo rm -f "$HOME/QVM/config_files/ISO_Images/ubuntu-noble.iso"
								fi
								break
							fi
						else
							echo -e "\033[34mA Ubuntu Noble ISO image has already been downloaded!\n\033[0m"
							break
						fi	
					;;
				
					5)	# Pull-Ubuntu-Server-Image
						url="https://releases.ubuntu.com/24.04.1/ubuntu-24.04.1-live-server-amd64.iso"
						iso_name=$()
						if ! iso_search | grep "ubuntu-server" &>/dev/null; then
				            read -p "Are you sure? [y/N]: " confirm
				            if [[ "$confirm" =~ ^[yY]$ ]]; then
								echo -e "\033[34mDownloading the $iso_name ISO image...\n\033[0m"
								if sudo wget --no-cookies "$url" -O $HOME/QVM/config_files/ISO_Images/ubuntu-server.iso; then
									echo -e "\033[34mThe\033[0m Ubuntu Server \033[34mimage downloaded successfully!\033[0m\n"
								
							    else
							        echo -e "\n\033[34mOperation Error: Download failed!\033[0m\n"
							        sudo rm -f "$HOME/QVM/config_files/ISO_Images/ubuntu-server.iso"
								fi
								break
							fi
						else
							echo -e "\033[34mA Ubuntu Server ISO image has already been downloaded!\n\033[0m"
							break
						fi
					;;
					6)	# Pull-Raspi-OS-Image
						if ! iso_search | grep "raspios.iso" &>/dev/null; then
				            read -p "Are you sure? [y/N]: " confirm
				            if [[ "$confirm" =~ ^[yY]$ ]]; then
								echo -e "\033[34mDownloading the Kali Linux ISO image...\n\033[0m"
								url="https://downloads.raspberrypi.com/rpd_x86/images/rpd_x86-2022-07-04/2022-07-01-raspios-bullseye-i386.iso"
								if sudo wget --no-cookies "$url" -O $HOME/QVM/config_files/ISO_Images/raspios.iso; then
									echo -e "\033[34mThe\033[0m Ubuntu 20.24 \033[34mimage downloaded successfully!\033[0m\n"
								
							    else
							        echo -e "\n\033[34mOperation Error: Download failed!\033[0m\n"
							        sudo rm -f "$HOME/QVM/config_files/ISO_Images/raspios.iso"
								fi
								break
							fi
						else
							echo -e "\033[34mA Raspi OS ISO image has already been downloaded!\n\033[0m"
							break
						fi
					;;
					
					7)	# Pull-Manjaro-Image
						while true; do
							echo -e "\033[34mAvailable Manjaro OS images;\033[0m"
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
								*)	echo -e "\033[34mError: Invalid entry! Enter a number between 1-3.\033[0m"
								;;
							esac
						done
						if ! iso_search | grep "manjaro-${manj_type}" &>/dev/null; then
				            read -p "Are you sure? [y/N]: " confirm
				            if [[ "$confirm" =~ ^[yY]$ ]]; then
								iso_name=$(echo $url | awk -F "/" '{print $NF}' | cut -d. -f1)
								echo -e "\033[34mDownloading the $iso_name ISO image...\n\033[0m"
								if sudo wget --no-cookies "$url" -O $HOME/QVM/config_files/ISO_Images/${iso_name}.iso; then 
									echo -e "\033[34mThe\033[0m Ubuntu 20.24 \033[34mimage downloaded successfully!\033[0m\n"
								
							    else
							        echo -e "\n\033[34mOperation Error: Download failed!\033[0m\n"
							        sudo rm -f "$HOME/QVM/config_files/ISO_Images/${iso_name}.iso"
								fi
								break
							fi
						else
							echo -e "\033[34mA $iso_name image has already been downloaded!\n\033[0m"
							break
						fi
					;;
					8) # Pull-Parrot-OS-Image
						url="https://deb.parrot.sh/parrot/iso/6.2/Parrot-security-6.2_amd64.iso"
						iso_name=$(echo $url | awk -F "/" '{print $NF}' | cut -d. -f1)
						if ! iso_search | grep "$iso_name" &>/dev/null; then
				            read -p "Are you sure? [y/N]: " confirm
				            if [[ "$confirm" =~ ^[yY]$ ]]; then
								echo -e "\033[34mDownloading the $iso_name ISO image...\n\033[0m"
								if sudo wget --no-cookies "$url" -O $HOME/QVM/config_files/ISO_Images/${iso_name}.iso; then
									echo -e "\033[34mThe\033[0m Ubuntu 20.24 \033[34mimage downloaded successfully!\033[0m\n"
								
							    else
							        echo -e "\n\033[34mOperation Error: Download failed!\033[0m\n"
							        sudo rm -f "$HOME/QVM/config_files/ISO_Images/${iso_name}.iso"
								fi
								break
							fi
						else
							echo -e "\033[34mA $iso_name image has already been downloaded!\n\033[0m"
							break
						fi
					;;
					9)	# Pull-Other-Images
						read -p "Enter the full download URL for your desired ISO image (Enter '0' to cancel): " other_iso
						if ! [[ "$other_iso" == "0" || -z "$other_iso" ]]; then
							url="$other_iso"
							other_iso_name=$(echo $url | awk -F "/" '{print $NF}' | cut -d. -f1)
				            read -p "Are you sure? [y/N]: " confirm
				            if [[ "$confirm" =~ ^[yY]$ ]]; then
								echo -e "\033[34mDownloading the\033[0m $other_iso_name \033[34mISO image...\033[0m\n"
								if ! [[ $(iso_search | grep "$other_iso_name") ]]; then
									if sudo wget --no-cookies "$url" -O $HOME/QVM/config_files/ISO_Images/${other_iso_name}.iso; then
										echo -e "\033[34mThe\033[0m Ubuntu 20.24 \033[34mimage downloaded successfully!\033[0m\n"
								    else
								        echo -e "\n\033[34mOperation Error: Download failed!\033[0mn\n"
								        sudo rm -f "$HOME/QVM/config_files/ISO_Images/${other_iso_name}.iso"
									fi
									break
								else
									echo -e "\033[34mError: That OS disk image has already been downloaded & is ready to use!\033[0m"
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
		3)	echo -e "\033[34mSearching for ISO images...\033[0m"
			if ! find $HOME -type f -name "*.iso" | grep -v "ISO_Images"; then
				echo -e "\033[34mThe ISO search did not find any images to import!\n"
			else
				echo -e ""
				echo -e "\033[34mMoving the following ISO images to the QVM ISO image folder...\033[0m"
				find $HOME -type f -name "*.iso" | grep -v "ISO_Images"
				sudo mv $(find ~/ -type f -name "*.iso" | grep -v "ISO_Images") "./../ISO_Images"/ && \
					echo -e "\033[34mImage(s) successfully imported!\033[0m\n" || echo -e "\033[34mISO import failed!\033[0m\n"
			fi
		;;
		4)	echo -e "\033[34mChecking the QVM cdrom for ISO disk images...\033[0m"
			echo -e "\033[34mImages found...\033[0m"
			ckcdrom=$(find $HOME/QVM/ -type f -name '*.iso' | grep cdrom | awk -F '/' '{print $NF}' | nl -s ". ")
			if ! [[ -z "$ckcdrom" ]]; then
				while true; do
					find $HOME/QVM/ -type f -name '*.iso' | grep cdrom | awk -F '/' '{print $NF}' | nl -s ". "
					read -p "Which disk image should be ejected? (Enter '0' to cancel): " si
					[ -z $si ] && echo -e "\033[34mError: Invalid input!\033[0m" && exit 1
					if [[ "$si" == 0 ]]; then
						break
					fi
					if ! [[ "$si" =~ ^[0-9]+$ ]]; then
						echo -e "\033[34mError: Invalid entry!\033[0m"
					fi
				done
				iso=$(find $HOME/QVM/config_files/ISO_Images/cdrom/ -type f -name '*.iso' | tr -d '\0' | sed -n "${si}p")
				while true; do
					read -p "Eject the '$(echo $iso | xargs -0 basename -a)' disk image? [Y/n]: " eject
					if [[ "$eject" == "Y" || "$eject" == "y" || "$eject" == "yes" ]]; then
						sudo mv "$iso" "../ISO_Images/" && \
						echo -e "\033[34mThe '\033[0m$(echo $iso | xargs -0 basename -a)\033[34m' ISO disk image has been ejected!\033[0m" || \
						echo -e "\033[34mOperation Failed: An unexpected error has ocurred!"
						break
					elif [[ "$eject" == "N" || "$eject" == "n" || "$eject" == "no" ]]; then
						break
					else
						echo "Error: Invalid input!"
					fi
				done
			else
				echo -e "\n\033[34mThe QVM cdrom is empty!\033[0m"
			fi
		;;
		5)	echo -e "\033[34mListing ISO images..."
			delete-iso
		;;
		0)	exit 0
        ;;
		*)	echo -e "\033[34mInvalid option. Please try again.\033[0m"
		;;
	esac
done
