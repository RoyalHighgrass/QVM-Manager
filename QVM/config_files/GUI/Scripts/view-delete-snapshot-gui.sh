#!/bin/bash


path="$HOME/QVM/config_files/VM_Images/"
vvm=$(ls "$path" | sed 's/.img//g')

if [ $(echo "$vvm" | wc -w) -le 1 ]; then
	vvme="$vvm"
else
	vvme=$(echo "$vvm" | tr '\n' '!')
fi

if ! [[ -z $1 ]]; then
	if [[ "$1" == "-sss" ]]; then
		vss=$(echo $vvm | yad --on-top --form --width=480 \
    		--image="$HOME/QVM/config_files/logo_images/qemu2-2.png" \
			--title="QVM-1.0.3 - Save Snapshot" \
	    	--separator='" "' \
		    --text="$(echo $1 | awk -F 'VM' '{print $2}')" \
			--field="Select VM: ":CB "$vvme" \
			--field="New Snapshot Name/Tag": "" \
			--button="Cancel":1 --button="Create":0)

		case $? in
			0)	ssn=$(echo $vss | awk -F "\" \"" '{print $2}' | tr ' ' '_')
				vmn=$(echo $vss | awk -F "\" \"" '{print $1}')
			
				if qemu-img snapshot -c "#${ssn}#" "./../VM_Images/$vmn.img" &>/dev/null; then
				    if qemu-img snapshot -l "./../VM_Images/$vmn.img" | grep -q "#${ssn}#"; then
				        echo -e "Snapshot of $vmn saved successfully!\n"
				        yad --text="Snapshot of $vmn saved successfully!" --button="OK":0
				    else
				        echo -e "Snapshot creation reported success, but snapshot not found!\n"
				        yad --error --text="Snapshot creation reported success, but snapshot not found!" \
						--button="OK":0
				        exit 1 
				    fi
				else
				    echo -e "Snapshot creation failed!\n"
				    yad --error --text="Snapshot creation failed!" --button="OK":0
				    exit 1
				fi
			;;
			1)	exit 1
			;;
			*)	echo "Error: Somethimg unexpected occured!"
			;;
		esac
	fi

	if [[ "$1" == "-vs" ]]; then
		ss=$(yad --form --text="Select a VM to view any snapshots you have taken." \
    		--image="$HOME/QVM/config_files/logo_images/qemu2-2.png" \
			--title="QVM-1.0.3 - View Snapshots" \
	    	--separator='" "' \
			--field="Select VM: ":CB "$vvme" \
			--button="Cancel":1 --button="View Snapshots":0)
		case $? in
			0)	vmn=$(echo $ss | awk -F "\" \"" '{print $1}')
		        vss=$(qemu-img snapshot -l "./../VM_Images/$vmn.img")
				so=$(echo $vss | grep -o '#[a-zA-Z0-9]*#' | paste -s -d' ' | sed 's/# #/\!/g')
				so=$(echo $so | sed 's/#//g')
				sstd=$(yad --form --text="$vss" \
		    		--image="$HOME/QVM/config_files/logo_images/qemu2-2.png" \
					--title="QVM-1.0.3 - Viewing '$vmn' Snapshots" \
					--field="Select Snapshot":CB "$so" \
					--button="Delete Snapshot":0 --button="Close":1)
		
				if [[ "$?" == 0 ]]; then
					yad --bar \
				        --title="Delete Snapshot - $2" \
			            --width=300 \
			            --height=200 \
				        --text="Are you sure that you want delete this snapshot?" \
				        --pulsate \
				        --auto-close \
						--button="Cancel":1 --button="OK":0
					if [[ "$?" == 0 ]]; then
						sstd=$(echo $sstd | awk -F "\|" '{print $1}' 2> /dev/null)
						if qemu-img snapshot -d "#${sstd}#" "./../VM_Images/$vmn.img" &>/dev/null; then
							echo "$vmn snapshot deleted successfully!"
							yad --text="$vmn snapshot deleted successfully!!" \
								--button="OK":0
							exit 0
						else
							echo "Failed to delete the $vmn snapshot!"
							yad --text="Failed to delete the $vmn snapshot!" \
								--button="OK":0
							exit 1
						fi
					elif [[ "$?" == 1 ]]; then
						echo cancelled
						exit 1
					else
						echo "Error: Somethimg unexpected occured!"
						exit 1
					fi
				elif [[ "$?" == 1 ]]; then
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










