#!/bin/bash


echo -e "\n\033[34mSelect an ISO image to download...\033[0m"

# Show the list of available ISO images using YAD
echo -e "\033[34mAvailable ISO images;\033[0m"
iso_img=$(echo -e "Debian 12\nArchLinux\nKali Linux\nUbuntu Noble Desktop\nUbuntu (Server)\nRaspiOS\nManjaro\nParrotOS\nFedora\nLinux Mint\nTail OS\nNone of the above (Choose Alternative)" | nl -s ".  ")
echo "$iso_img"
	
iso_img=$(echo "$iso_img" | yad --list --title="Available ISO Images" \
	--separator="" --column="Available ISO Images" --height=300 --width=400 \
	--button="Cancel":1 --button="Download":0)

case $? in
	0)	selected_iso_img_num=$(echo $iso_img | cut -d. -f1)
		if [[ "$iso_img" == "Alternative" ]]; then
        	other_iso=$(yad --entry --title="Enter custom ISO URL" --text="Enter the full download URL for your desired ISO image:")
            if [[ ! -z "$other_iso" ]]; then
                other_iso_name=$(basename "$other_iso" .iso)
                confirm=$(yad --question --text="Are you sure you want to download this $other_iso_name ISO image?" --button="Yes:0" --button="No:1")
                if [ $? -eq 0 ]; then
                    echo -e "Downloading the $other_iso_name ISO image..."
                    if ! iso_search | grep "$other_iso_name" &>/dev/null; then
                		if wget -c "$other_iso" 2>&1 | sed -u 's/^/# /' | zenity --progress \
							--title="QVM-v1.0.3 - Downloading: $other_iso_name" \
							--text="Downloading the '$other_iso_name' image." \
							--percentage=0 \
							--auto-close; then
							zenity --info --text="Download completed successfully." && \
							sudo mv $iso_img_nme $HOME/QVM/config_files/ISO_Images/debian-12.iso
							exit 0
						else
							zenity --error --text="Download failed." && sudo rm $iso_img_nme
							exit 1
						fi
                    else
                        yad --info --text="The $other_iso_name ISO image is already downloaded."
						exit 1
                    fi
                fi
            fi
		fi
		case $selected_iso_img_num in
	    	1)	# Pull-ISO-Debian-12-Image 
		        if ! find $HOME/QVM/ -type f -name "*.iso" | grep "debian-12.iso" &>/dev/null; then
	                url="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.8.0-amd64-netinst.iso"
					iso_img_nme=$(echo $url | awk -F"/" '{print $NF}')
					
	                confirm=$(yad --question --text="Are you sure you want to download the Debian 12 ISO image?" --button="Yes:0" --button="No:1")
		            if [ $? -eq 0 ]; then
                		if wget -c "$url" 2>&1 | sed -u 's/^/# /' | zenity --progress \
							--title="QVM-v1.0.3 - Downloading ISO: Debian 12 ISO" \
							--text="Downloading the 'debian-12.iso' image." \
							--percentage=0 \
							--auto-close; then
							zenity --info --text="Download completed successfully." && \
							sudo mv $iso_img_nme $HOME/QVM/config_files/ISO_Images/debian-12.iso
						else
							zenity --error --text="Download failed." && sudo rm $iso_img_nme
						fi
		            fi
		        else
		            yad --info --text="A Debian ISO image has already been downloaded!"
	            fi
			;;
	    	2)	# Pull-ISO-Arch-Linux-Image 
		        if ! find $HOME/QVM/ -type f -name "*.iso" | grep "archlinux.iso" &>/dev/null; then
	                url="https://archlinux.mailtunnel.eu/iso/latest/archlinux-x86_64.iso"
					iso_img_nme=$(echo $url | awk -F"/" '{print $NF}')
	                confirm=$(yad --question --text="Are you sure you want to download the Arch Linux ISO image?" --button="Yes:0" --button="No:1")
		            if [ $? -eq 0 ]; then
						if wget -c "$url" 2>&1 | sed -u 's/^/# /' | zenity --progress \
							--title="QVM-v1.0.3 - Downloading ISO: Arch Linux" \
						  	--text="Downloading the 'archlinux.iso' image." \
						  	--percentage=0 \
						  	--auto-close; then
							zenity --info --text="Download completed successfully." && \
							sudo mv $iso_img_nme $HOME/QVM/config_files/ISO_Images/archlinux.iso
						else
							zenity --error --text="Download failed." && sudo rm $iso_img_nme
		            	fi
					fi
		        else
		            yad --info --text="A Arch Linux image has already been downloaded!"
	            fi
			;;
	    	3)	# Pull-ISO-Kali-Linux-Image 
		        if ! find $HOME/QVM/ -type f -name "*.iso" | grep "kali-linux.iso" &>/dev/null; then
	                url="https://cdimage.kali.org/kali-2024.4/kali-linux-2024.4-installer-netins\t-amd64.iso"
					iso_img_nme=$(echo $url | awk -F"/" '{print $NF}')
	                confirm=$(yad --question --text="Are you sure you want to download the Kali Linux ISO image?" --button="Yes:0" --button="No:1")
		            if [ $? -eq 0 ]; then
						if wget -c "$url" 2>&1 | sed -u 's/^/# /' | zenity --progress \
							--title="QVM-v1.0.3 - Downloading ISO: Kali Linux" \
						  	--text="Downloading the 'kali-linux.iso' image." \
						  	--percentage=0 \
						  	--auto-close; then
							zenity --info --text="Download completed successfully." && \
							sudo mv $iso_img_nme $HOME/QVM/config_files/ISO_Images/kali-linux.iso 
						else
							zenity --error --text="Download failed." && sudo rm $iso_img_nme
			            fi
					fi
				else
		            yad --info --text="A Kali Linux image has already been downloaded!"
	            fi
			;;
	    	4)	# Pull-ISO-Ubuntu-Noble-Image 
		        if ! find $HOME/QVM/ -type f -name "*.iso" | grep "ubuntu-noble.iso" &>/dev/null; then
	                url="https://releases.ubuntu.com/noble/ubuntu-24.04.1-desktop-amd64.iso"
					iso_img_nme=$(echo $url | awk -F"/" '{print $NF}')
	                confirm=$(yad --question --text="Are you sure you want to download the Ubuntu Noble ISO image?" --button="Yes:0" --button="No:1")
		            if [ $? -eq 0 ]; then
						if wget -c "$url" 2>&1 | sed -u 's/^/# /' | zenity --progress \
							--title="QVM-v1.0.3 - Downloading: Ubuntu Noble" \
						  	--text="Downloading the 'ubuntu-noble.iso' image." \
						  	--percentage=0 \
						  	--auto-close; then
							zenity --info --text="Download completed successfully." && \
							sudo mv $iso_img_nme $HOME/QVM/config_files/ISO_Images/ubuntu-noble.iso
						else
							zenity --error --text="Download failed." && sudo rm $iso_img_nme
			            fi
					fi
		        else
		            yad --info --text="A Ubuntu Noble image has already been downloaded!"
	            fi
			;;
	    	5)	# Pull-ISO-Ubuntu-Server-Image 
		        if ! find $HOME/QVM/ -type f -name "*.iso" | grep "ubuntu-server.iso" &>/dev/null; then
	                url="https://releases.ubuntu.com/24.04.1/ubuntu-24.04.1-live-server-amd64.iso"
					iso_img_nme=$(echo $url | awk -F"/" '{print $NF}')
	                confirm=$(yad --question --text="Are you sure you want to download the Ubuntu Server ISO image?" --button="Yes:0" --button="No:1")
		            if [ $? -eq 0 ]; then
						if wget -c "$url" 2>&1 | sed -u 's/^/# /' | zenity --progress \
							--title="QVM-v1.0.3 - Downloading ISO: Ubuntu Server" \
						  	--text="Downloading the 'ubuntu-server.iso' image." \
						  	--percentage=0 \
						  	--auto-close; then
							zenity --info --text="Download completed successfully." && \
							sudo mv $iso_img_nme $HOME/QVM/config_files/ISO_Images/ubuntu-server.iso
						else
							zenity --error --text="Download failed." && sudo rm $iso_img_nme
			            fi
					fi
		        else
		            yad --info --text="A Ubuntu Server image has already been downloaded!"
	            fi
			;;
	    	6)	# Pull-ISO-Raspi-OS-Image 
		        if ! find $HOME/QVM/ -type f -name "*.iso" | grep "raspios.iso" &>/dev/null; then
	                url="https://downloads.raspberrypi.com/rpd_x86/images/rpd_x86-2022-07-04/2022-07-01-raspios-bullseye-i386.iso"
					iso_img_nme=$(echo $url | awk -F"/" '{print $NF}')
	                confirm=$(yad --question --text="Are you sure you want to download the RaspiOS ISO image?" --button="Yes:0" --button="No:1")
		            if [ $? -eq 0 ]; then
						if wget -c "$url" 2>&1 | sed -u 's/^/# /' | zenity --progress \
							--title="QVM-v1.0.3 - Downloading ISO: RaspiOS" \
						  	--text="Downloading the 'raspios.iso' image." \
						  	--percentage=0 \
						  	--auto-close; then
							zenity --info --text="Download completed successfully." && \
							sudo mv $iso_img_nme $HOME/QVM/config_files/ISO_Images/raspios.iso
						else
							zenity --error --text="Download failed." && sudo rm $iso_img_nme
			            fi
					fi
		        else
		            yad --info --text="A RaspiOS image has already been downloaded!"
	            fi
			;;
	    	7)	# Pull-ISO-Manjaro-Image 
				echo -e "\033[34mAvailable versions of Manjaro OS;\033[0m"
				manj_type=$(echo -e "Manjaro KDE Plasma Desktop\nManjaro Xfce Desktop\nManjaro GNOME Desktop" | nl -s ".  ")
				echo $manj_type
				manj_type=$(echo "$manj_type" | yad --list --title="Available Manjaro OS images" \
					--column="Available versions of Manjaro OS" --height=200 --width=300)
				
		        if [[ -z "$manj_type" ]]; then
					echo -e "Error: Operation cancelled!"
					exit 1
				fi

				if echo $manj_type | grep "KDE" &>/dev/null; then
					manj_type="KDE"
					version="kde"
				elif echo $manj_type | grep "Xfce" &>/dev/null; then
					manj_type="Xfce"
					version="xfce"
				elif echo $manj_type | grep "GNOME" &>/dev/null; then
					manj_type="GNOME"
					version="gnome"
				fi
				if ! find $HOME/QVM/ -type f -name "*.iso" | grep "manjaro-${version}.iso" &>/dev/null; then
		            case $manj_type in
		                "KDE")
		                    url="https://download.manjaro.org/kde/24.2.1/manjaro-kde-24.2.1-241216-linux612.iso"
		                ;;
		                "Xfce")
		                    url="https://download.manjaro.org/xfce/24.2.1/manjaro-xfce-24.2.1-241216-linux612.iso"
		                ;;
		                "GNOME")
		                    url="https://download.manjaro.org/gnome/24.2.1/manjaro-gnome-24.2.1-241216-linux612.iso"
		                ;;
		            esac
	                iso_img_nme=$(echo $url | awk -F"/" '{print $NF}')
	                confirm=$(yad --question --text="Are you sure you want to download the Manjaro $manj_type ISO image?" --button="Yes:0" --button="No:1")
		            if [ $? -eq 0 ]; then
						if wget -c "$url" 2>&1 | sed -u 's/^/# /' | zenity --progress \
							--title="QVM-v1.0.3 - Downloading: Manjaro $manj_type" \
						  	--text="Downloading the manjaro-${version}.iso" \
						  	--percentage=0 \
						  	--auto-close; then
							zenity --info --text="Download completed successfully." && \
							sudo mv $iso_img_nme $HOME/QVM/config_files/ISO_Images/manjaro-${version}.iso 
						else
							zenity --error --text="Download failed." && sudo rm $iso_img_nme
			            fi
					fi
		        else
		            yad --info --text="A Manjaro $manj_type Desktop image has already been downloaded!"
	            fi
			;;
	    	8)	# Pull-ISO-Parrot-OS-Image 
		        if ! find $HOME/QVM/ -type f -name "*.iso" | grep "parrot-os.iso" &>/dev/null; then
	                url="https://deb.parrot.sh/parrot/iso/6.2/Parrot-security-6.2_amd64.iso"
					iso_img_nme=$(echo $url | awk -F"/" '{print $NF}')
	                confirm=$(yad --question --text="Are you sure you want to download the Parrot OS ISO image?" --button="Yes:0" --button="No:1")
		            if [ $? -eq 0 ]; then
						if wget -c "$url" 2>&1 | sed -u 's/^/# /' | zenity --progress \
							--title="QVM-v1.0.3 - Downloading: Parrot OS" \
						  	--text="Downloading the 'parrot-os.iso' image." \
						  	--percentage=0 \
						  	--auto-close; then
							zenity --info --text="Download completed successfully." && \
							sudo mv $iso_img_nme $HOME/QVM/config_files/ISO_Images/parrot-os.iso 
						else
							zenity --error --text="Download failed." && sudo rm $iso_img_nme
			            fi
					fi
		        else
		            yad --info --text="A Parrot OS image has already been downloaded!"
	            fi
			;;
	    	9)	# Pull-ISO-Fedora-Image 
		        if ! find $HOME/QVM/ -type f -name "*.iso" | grep "fedora.iso" &>/dev/null; then
	                url="https://download.fedoraproject.org/pub/fedora/linux/releases/41/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-41-1.4.iso"
					iso_img_nme=$(echo $url | awk -F"/" '{print $NF}')
	                confirm=$(yad --question --text="Are you sure you want to download the Fedora ISO image?" --button="Yes:0" --button="No:1")
		            if [ $? -eq 0 ]; then
						if wget -c "$url" 2>&1 | sed -u 's/^/# /' | zenity --progress \
							--title="QVM-v1.0.3 - Downloading: Fedora" \
						  	--text="Downloading the 'fedora.iso' image." \
						  	--percentage=0 \
						  	--auto-close; then
							zenity --info --text="Download completed successfully." && \
							sudo mv $iso_img_nme $HOME/QVM/config_files/ISO_Images/fedora.iso
						else
							zenity --error --text="Download failed." && sudo rm $iso_img_nme
			            fi
					fi
		        else
		            yad --info --text="A Fedora image has already been downloaded!"
	            fi
			;;
	    	10)	# Pull-ISO-Linux-Mint-Image 
		        if ! find $HOME/QVM/ -type f -name "*.iso" | grep "debian-mint.iso" &>/dev/null; then
	                url=""
					iso_img_nme=$(echo $url | awk -F"/" '{print $NF}')
	                confirm=$(yad --question --text="Are you sure you want to download the Linux Mint ISO image?" --button="Yes:0" --button="No:1")
		            if [ $? -eq 0 ]; then
						if wget -c "$url" 2>&1 | sed -u 's/^/# /' | zenity --progress \
							--title="QVM-v1.0.3 - Downloading: Linux Mint" \
						  	--text="Downloading the linux-mint.iso image." \
						  	--percentage=0 \
						  	--auto-close; then
							zenity --info --text="Download completed successfully." && \
							sudo mv $iso_img_nme $HOME/QVM/config_files/ISO_Images/linux-mint.iso 
						else
							zenity --error --text="Download failed." && sudo rm $iso_img_nme
			            fi
					fi
		        else
		            yad --info --text="A Linux Mint image has already been downloaded!"
	            fi
			;;
	    	11)	# Pull-ISO-Tails-OS-Image 
		        if ! find $HOME/QVM/ -type f -name "*.iso" | grep "tails-os.img.iso" &>/dev/null; then
	                url="https://download.tails.net/tails/stable/tails-amd64-6.10/tails-amd64-6.10.img"
					iso_img_nme=$(echo $url | awk -F"/" '{print $NF}')
	                confirm=$(yad --question --text="Are you sure you want to download the Tails OS ISO image?" --button="Yes:0" --button="No:1")
		            if [ $? -eq 0 ]; then
						if wget -c "$url" 2>&1 | sed -u 's/^/# /' | zenity --progress \
							--title="QVM-v1.0.3 - Downloading: Tails OS" \
						  	--text="Downloading the 'tails-os.img.iso' image." \
						  	--percentage=0 \
						  	--auto-close; then
							zenity --info --text="Download completed successfully." && \
							sudo mv $iso_img_nme $HOME/QVM/config_files/ISO_Images/tails-os.img.iso 
						else
							zenity --error --text="Download failed." && sudo rm $iso_img_nme
			            fi
					fi
		        else
		            yad --info --text="A Tails OS image has already been downloaded!"
	            fi
			;;
		esac
	;;
	1)	echo -e "Operation cancelled.\n"
		exit 1
	;;
esac

exit 0
