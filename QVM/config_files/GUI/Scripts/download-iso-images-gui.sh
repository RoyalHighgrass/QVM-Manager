#!/bin/bash

# Set variables
b="\033[34m"
w="\033[0m"
title="QVM-v1.0.3 -"



echo -e "\n${b}Select an ISO image to download...${w}"

# Show the list of available ISO images using YAD
echo -e "${b}Available ISO images;${w}"
iso_img=$(echo -e "Debian 12 (600MB)\nArchLinux (1.2GB)\nKali Linux (589MB)\nUbuntu Noble Desktop (5.8GB)\nUbuntu Server (2.6GB)\nRaspiOS (3.4GB)\nManjaro (3.6GB - 4.1GB)\nParrotOS (5.1GB)\nFedora (903MB)\nLinux Mint (2.8GB)\nNone of the above (Choose Alternative)" | nl -s ".  ")

if [ "$1" = "-li" ]; then
	echo "$iso_img"
	exit 0
fi

echo "$iso_img"
	
iso_img=$(echo "$iso_img" | yad --list --title="$title Available ISO Images" \
	--image="$HOME/QVM/config_files/logo_images/qvm-2.png" \
	--text="<b>Select an ISO image to download</b>" \
    --buttons-layout=center --on-top \
	--separator="" --column="Available ISO Images" --height=500 --width=400 \
	--button="Cancel":1 --button="Download":0)

case $? in
	0)	selected_iso_img_num=$(echo $iso_img | cut -d. -f1)
		if [ "$iso_img" = "Alternative" ]; then
        	other_iso=$(yad --entry --title="Enter custom ISO URL" --text="Enter the full download URL for your desired ISO image:")
            if [ ! -z "$other_iso" ]; then
                other_iso_name=$(basename "$other_iso" .iso)
                confirm=$(yad --question --buttons-layout=center --on-top \
					--text="Are you sure you want to download this $other_iso_name ISO image?" \
	 				--button="Yes:0" --button="No:1")
                if [ $? -eq 0 ]; then
                    echo -e "Downloading the $other_iso_name ISO image..."
                    if ! iso_search | grep "$other_iso_name" &>/dev/null; then
                		if wget -c "$other_iso" 2>&1 | sed -u 's/^/# /' | zenity --progress \
							--title="$title Downloading ISO: $other_iso_name" \
							--text="Downloading the '$other_iso_name' image." \
							--percentage=0 \
							--auto-close; then
							zenity --info --text="Download completed successfully." 2>/dev/null && \
							sudo mv $iso_img_nme $HOME/QVM/config_files/ISO_Images/debian-12.iso
							exit 0
						else
							zenity --error --text="Download failed." 2>/dev/null && sudo rm $iso_img_nme
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
					target="Debian 12"
					url=$(./../settings/recommended_iso_files.sh "debian-12")
					echo "$url"
					file_name="debian-12.iso"
		        else
				    yad --info --text="A Debian ISO image has already been downloaded!" \
					--buttons-layout=center --button="OK"
					exit 1
	            fi
			;;
	    	2)	# Pull-ISO-Arch-Linux-Image 
		        if ! find $HOME/QVM/ -type f -name "*.iso" | grep "archlinux.iso" &>/dev/null; then
					target="Arch Linux"
					url=$(./../settings/recommended_iso_files.sh "arch-linux")
					echo "$url"
					file_name="arch-linux.iso"
		        else
				    yad --info --text="A Arch Linux ISO image has already been downloaded!" \
					--buttons-layout=center --button="OK"
					exit 1
	            fi
			;;
	    	3)	# Pull-ISO-Kali-Linux-Image 
		        if ! find $HOME/QVM/ -type f -name "*.iso" | grep "kali-linux.iso" &>/dev/null; then
					target="Kali Linux"
					url=$(./../settings/recommended_iso_files.sh "kali-linux")
					echo "$url"
					file_name="kali-linux.iso"
		        else
				    yad --info --text="A Kali Linux ISO image has already been downloaded!" \
					--buttons-layout=center --button="OK"
					exit 1
	            fi
			;;
	    	4)	# Pull-ISO-Ubuntu-Noble-Image 
		        if ! find $HOME/QVM/ -type f -name "*.iso" | grep "ubuntu-noble.iso" &>/dev/null; then
					target="Ubuntu Noble"
					url=$(./../settings/recommended_iso_files.sh "ubuntu-noble")
					echo "$url"
					file_name="ubuntu-noble.iso"
		        else
				    yad --info --text="A Ubuntu Noble ISO image has already been downloaded!" \
					--buttons-layout=center --button="OK"
					exit 1
	            fi
			;;
	    	5)	# Pull-ISO-Ubuntu-Server-Image 
		        if ! find $HOME/QVM/ -type f -name "*.iso" | grep "ubuntu-server.iso" &>/dev/null; then
					target="Ubuntu Noble"
					url=$(./../settings/recommended_iso_files.sh "ubuntu-server")
					echo "$url"
					file_name="ubuntu-server.iso"
		        else
				    yad --info --text="A Ubuntu Server ISO image has already been downloaded!" \
					--buttons-layout=center --button="OK"
					exit 1
	            fi
			;;
	    	6)	# Pull-ISO-Raspi-OS-Image 
		        if ! find $HOME/QVM/ -type f -name "*.iso" | grep "raspios.iso" &>/dev/null; then
					target="Raspian"
					url=$(./../settings/recommended_iso_files.sh "raspi-os")
					echo "$url"
					file_name="raspi-os.iso"
		        else
				    yad --info --text="A Raspian ISO image has already been downloaded!" \
					--buttons-layout=center --button="OK"
					exit 1
	            fi
			;;
	    	7)	# Pull-ISO-Manjaro-Image 
				echo -e "${b}Available versions of Manjaro OS;${w}"
				manj_type=$(echo -e "Manjaro KDE Plasma Desktop (4.1GB)\nManjaro Xfce Desktop (3.6GB)\nManjaro GNOME Desktop (3.9GB)" | nl -s ".  ")
				echo "$manj_type"
				manj_type=$(echo "$manj_type" | yad --list --title="Available Manjaro OS images" \
					--column="Available versions of Manjaro OS" --height=200 --width=400)
				
		        if [ -z "$manj_type" ]; then
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
					target="Manjaro $manj_type"
					url=$(./../settings/recommended_iso_files.sh "manjaro-${version}")
					echo "$url"
					file_name="manjaro-${version}.iso"
		        else
				    yad --info --text="A Manjaro $manj_type ISO image has already been downloaded!" \
					--buttons-layout=center --button="OK"
					exit 1
	            fi
			;;
	    	8)	# Pull-ISO-Parrot-OS-Image 
		        if ! find $HOME/QVM/ -type f -name "*.iso" | grep "parrot-os.iso" &>/dev/null; then
					target="Parrot OS"
					url=$(./../settings/recommended_iso_files.sh "parrot-os")
					echo "$url"
					file_name="parrot-os.iso"
		        else
				    yad --info --text="A Parrot OS ISO image has already been downloaded!" \
					--buttons-layout=center --button="OK"
					exit 1
	            fi
			;;
	    	9)	# Pull-ISO-Fedora-Image 
		        if ! find $HOME/QVM/ -type f -name "*.iso" | grep "fedora.iso" &>/dev/null; then
					target="Fedora"
					url=$(./../settings/recommended_iso_files.sh "fedora")
					echo "$url"
					file_name="fedora.iso"
		        else
				    yad --info --text="A Fedora ISO image has already been downloaded!" \
					--height=250 --buttons-layout=center --button="OK"
					exit 1
	            fi
			;;
	    	10)	# Pull-ISO-Linux-Mint-Image 
		        if ! find $HOME/QVM/ -type f -name "*.iso" | grep "linux-mint.iso" &>/dev/null; then
					target="Linux Mint"
					echo -e "${b}Available versions of Linux Mint;${w}"
					d_type=$(echo -e "Linux Mint Mate Desktop (2.8GB)\nLinux Mint Xfce Desktop (2.7GB)\nLinux Mint Cinnamon Desktop (2.8GB)" | nl -s ".  ")
					echo "$d_type"
					d_type=$(echo "$d_type" | yad --list --title="Available Linux Mint images" \
						--column="Available versions of Linux Mint" --height=200 --width=400)
			        if [ -z "$d_type" ]; then
						echo -e "Error: Operation cancelled!"
						exit 1
					fi
					if echo $d_type | grep "Mate" &>/dev/null; then
						d_type="mate"
					elif echo $d_type | grep "Xfce" &>/dev/null; then
						d_type="xfce"
					elif echo $d_type | grep "Cinnamon" &>/dev/null; then
						d_type="cin"
					else
					 	echo "qvm-manager: An unexpected error has occured!"
						exit 1
					fi
					url=$(./../settings/recommended_iso_files.sh "linux-mint" "$d_type")
					file_name="linux-mint.iso"
		        else
				    yad --info --text="A Linux Mint ISO image has already been downloaded!" \
					--buttons-layout=center --button="OK"
					exit 1
	            fi
			;;
		esac
		if ! [ -z "$url" ]; then
			iso_img_nme=$(basename "$url")
	        yad --question --title="$title Confirm Download" --buttons-layout=center --on-top \
				--text="Are you sure you want to download the official ${target} ISO image?" \
				--button="Yes:0" --button="No:1"
		    if [ $? -eq 0 ]; then
                if wget -c "$url" 2>&1 | sed -u 's/^/# /' | zenity --progress \
					--title="$title Downloading ISO: ${target}" --width=300 --percentage=0 \
					--text="Downloading the '${target}.iso' image." --auto-close 2>/dev/null; then
					zenity --info --title="$title Download Completed" \
						--text="${target} download completed successfully."
					echo "Moving $iso_img_nme to $HOME/QVM/config_files/ISO_Images/$file_name"
					sudo mv $iso_img_nme "$HOME/QVM/config_files/ISO_Images/$file_name"
				else
					zenity --error --title="$title Download Failed" --text="${target} download failed."
					sudo rm $iso_img_nme
				fi
		    fi
		else
			echo "qvm-manager: Error: An unexpected error has occured! QVM is unable to retrieve the URL for the official $target ISO image!"
		fi
	;;
	1)	echo -e "Operation cancelled.\n"
		exit 1
	;;
esac
