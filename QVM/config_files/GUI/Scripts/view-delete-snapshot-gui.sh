#!/bin/bash

if ps aux | grep qemu-system | grep .img &>/dev/null; then
	echo -e "\nOperation not permitted: There are currently running VM's! \
		\n\nTo facilitate effecient host storage management, QVM does not allow snapshots \
to be taken of running machines. Viewing existing snapshots is also not permitted while \
VM's are running to prevent data corruption. Please try again once all VM's has been \
shutdown."
	yad --width=400 --height=200 --title="QVM-v1.0.3 - Operation not permitted" \
		--text="\n\nOperation not permitted: There are currently running VM's! \
		\n\n\nTo facilitate effecient host storage management, QVM does not allow snapshots \
to be taken of running machines. Viewing existing snapshots is also not permitted while \
VM's are running to prevent data corruption. Please try again once all VM's has been \
shutdown." \
		--button=OK:0
	exit 1

fi

path="$HOME/QVM/config_files/VM_Images/"
vvm=$(ls "$path" | sed 's/.img//g')

if [ $(echo "$vvm" | wc -w) -le 1 ]; then
	vvme="$vvm"
else
	vvme=$(echo "$vvm" | tr '\n' '!')
fi

if [ -z "$vvm" ]; then
	yad --width=200 --text="<b>You haven't created any virtual mechines yet!</b>" --button="OK":0
	exit 1
fi

if ! [ -z $1 ]; then
	if [ "$1" = "-sss" ]; then
		vss=$(echo $vvm | yad --on-top --form --width=480 \
    		--image="$HOME/QVM/config_files/logo_images/qemu2-2.png" \
			--title="QVM-1.0.3 - Save Snapshot" \
	    	--on-top --separator='" "' \
			--buttons-layout=center \
		    --text="$(echo $1 | awk -F 'VM' '{print $2}')" \
			--field="Select VM: ":CB "$vvme" \
			--field="New Snapshot Name/Tag": "" \
			--button="Cancel":1 --button="Create":0)

		case $? in
			0)	ssn=$(echo $vss | awk -F "\" \"" '{print $2}' | tr ' ' '_')
				vmn=$(echo $vss | awk -F "\" \"" '{print $1}')
			
				if qemu-img snapshot -c "_${ssn}_" "./../VM_Images/$vmn.img" &>/dev/null; then
				    if qemu-img snapshot -l "./../VM_Images/$vmn.img" | grep -q "_${ssn}_"; then
				        echo -e "Snapshot of $vmn saved successfully!\n"
				        yad --text="Snapshot of $vmn saved successfully!" \
							--buttons-layout=center --button="OK":0
				    else
				        echo -e "Snapshot creation reported success, but snapshot not found!\n"
				        yad --error --text="Snapshot creation reported success, but snapshot not found!" \
							--buttons-layout=center --button="OK":0
				        exit 1 
				    fi
				else
				    echo -e "Snapshot creation failed!\n"
				    yad --error --text="Snapshot creation failed!" \
						--buttons-layout=center --button="OK":0
				    exit 1
				fi
			;;
			1)	exit 1
			;;
			*)	echo "Error: Somethimg unexpected occured!"
			;;
		esac
	fi

	if [ "$1" = "-vs" ]; then
		ss=$(yad --form --text="<b>Select a VM to view any snapshots you have taken.</b>" \
    		--image="$HOME/QVM/config_files/logo_images/qemu2-2.png" \
			--title="QVM-1.0.3 - View Snapshots" \
	    	--on-top --separator='" "' \
			--field="Select VM: ":CB "$vvme" \
			--buttons-layout=center \
			--button="Cancel":1 --button="View Snapshots":0)
		case $? in
			0)	vmn=$(echo $ss | awk -F "\" \"" '{print $1}')
		        vss=$(qemu-img snapshot -l "./../VM_Images/$vmn.img")
				gso=$(awk '{print $2}' <<< "$vss" | grep -v -E "TAG|:")
				so=$(echo $gso | tr '\n' ' ' | sed 's/_ _/!/g; s/_//g')
				echo $so
				if [ -z "$gso" ]; then
					buttons="--button=Close:1"
					text="There are no snapshots saved of this VM."
				else
					buttons="--button=Delete:0 --button=Close:1"
					text=$(echo "$vss" | sed 's/_//g')
				fi
				sstd=$(yad --form --text="<b>${text}</b>" \
					--buttons-layout=center \
		    		--image="$HOME/QVM/config_files/logo_images/qemu2-2.png" \
					--title="QVM-1.0.3 - Viewing '$vmn' Snapshots" \
					--on-top --field="Select Snapshot":CB "$so" \
					$buttons)
		
				if [ "$?" = 0 ]; then
					count=$(echo "$gso" | wc -l)
					if [ "$count" = 1 ]; then
						sstd=$(echo "$sstd" | awk -F" " '{print $1}')
					fi
					yad --title="QVM-v1.0.3 - Delete Snapshot" \
						--buttons-layout=center \
			            --width=300 \
			            --height=200 \
				        --text="Are you sure that you want delete this snapshot?" \
				        --pulsate \
				        --auto-close \
						--button="Cancel":1 --button="OK":0
					if [ "$?" = 0 ]; then
						sstd=$(echo $sstd | awk -F "\|" '{print $1}' 2> /dev/null)
						if qemu-img snapshot -d "_${sstd}_" "./../VM_Images/$vmn.img" &>/dev/null; then
							echo "$vmn snapshot deleted successfully!"
							yad --text="$vmn snapshot deleted successfully!!" \
								--buttons-layout=center \
								--button="OK":0
							exit 0
						else
							echo "Failed to delete the $vmn snapshot!"
							yad --text="Failed to delete the $vmn snapshot!" \
								--buttons-layout=center \
								--button="OK":0
							exit 1
						fi
					elif [ "$?" = 1 ]; then
						echo "qvm-manager: Operation cancelled!"
						exit 1
					else
						echo "qvm-manager: Error: Something unexpected occured!"
						exit 1
					fi
				elif [ "$?" = 1 ]; then
					exit 1
				else
					echo "Error: Somethimg unexpected occured!"
					exit 1
				fi	
			;;
			1)	exit 1
			;;
		esac
	fi
fi









