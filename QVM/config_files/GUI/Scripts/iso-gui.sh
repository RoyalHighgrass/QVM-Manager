#!/bin/bash

iso_search=$(echo -e "\033[34mSearching for ISO images...\n\033[0m" && \
	echo -e "\033[34mLocal ISO Images Found:\033[0m $(find ~/QVM/ -type f -name '*.iso' | wc -l)" && \
    find ~/QVM/ -type f -name "*.iso" | cut -d"/" -f7 | grep -v cdrom | sort
    find ~/QVM/ -type f -name "*.iso" | cut -d"/" -f8 | grep iso | sed 's/.iso/.iso (cdrom)/g' | sort
)

if [[ "$1" = "gip" ]]; then
	echo "$iso_search"
fi

iso_menu() { yad --title "QVM-1.0.3 - Manage ISO Images" \
    --form --columns=1 --width=250 --height=250 \
    --image="$HOME/QVM/config_files/logo_images/qvm-2.png" \
	--on-top --text="QVM ISO Manager" --buttons-layout=center \
    --field="<b>View Local ISO Images</b>":fbtn "./Scripts/iso-gui.sh -v" \
    --field="<b>Download ISO Images</b>":fbtn "./Scripts/download-iso-images-gui.sh" \
    --field="<b>Import ISO Images</b>":fbtn "./Scripts/iso-gui.sh -i" \
    --field="<b>Eject ISO Disk</b>":fbtn "./Scripts/iso-gui.sh -e" \
    --no-buttons --auto-close --close-on-unfocus
}

if [ -z "$1" ]; then
	iso_menu
else
	# View & delete ISO images
	if [ "$1" = "-v" ]; then
		echo -e "$iso_search"
		iso_files=$(find "$HOME/QVM/" -type f -name "*.iso" -printf "%f\n" | cut -d. -f1 | sort)
		if echo "$iso_files" | grep GUI &>/dev/null; then
			iso_files=$(echo "$iso_files" | grep GUI | sed 's/$/& (Currently downloading...\)/g')
		fi
		if [ -z "$iso_files" ]; then
			buttons="--button="Close":1"
		else
			buttons="--button=Delete:0 --button=Close:1"
		fi
		selected_iso=$(yad --title="QVM-v1.0.3 - Local ISO Image(s)" \
		    --width=400 --height=300 \
		    --image="$HOME/QVM/config_files/logo_images/qvm-2.png" \
		    --text="View and delete local ISO image(s)" \
			--separator="" \
			--buttons-layout=center \
		    --list --on-top \
		    --column="Local ISO File(s)" $(echo "$iso_files") \
		    $buttons)
		
		case $? in
			0)	#
				yad --bar \
			        --title="QVM-v1.0.3 - Delete ISO Image - $2" \
					--buttons-layout=center \
		            --width=300 \
		            --height=100 \
			        --text="Are you sure that you want delete this ISO image?" \
			        --pulsate \
			        --auto-close \
					--button="Cancel":1 --button="Yes":0

				case $? in
					0)	# Process the selected files for deletion
						selected_iso=$(./Scripts/iso-gui.sh "gip" | grep "$selected_iso")
						echo "$selected_iso" | while read -r file; do
							sudo rm "$HOME/QVM/config_files/ISO_Images/$selected_iso"
							if [ "$?" = 0 ]; then
							    echo "The $selected_iso ISO image has successfully been deleted!" && \
								yad --title="QVM-v1.0.3 - Operation successful!" \
									--buttons-layout=center \
									--text="The '$selected_iso' ISO image has successfully been deleted!" \
				        			--button="OK":0
							else
							    echo "The $selected_iso ISO image has not been deleted!" && \
								yad --title="QVM-v1.0.3 - Operation failed!" \
									--buttons-layout=center \
									--text="The $selected_iso ISO image has not been deleted!" \
				        			--button="OK":0
							fi
					    done
						exit 0
					;;
					1)	exit 1
					;;
				esac
			;;
			1)	exit 0
			;;
		esac
		exit 0
	fi
	
	if [ "$1" = "-i" ]; then
		# Import manually downloaded ISO files
		ISO_DEST="$HOME/QVM/config_files/ISO_Images/"
		LOGO_PATH="$HOME/QVM/config_files/logo_images/qvm-2.png"
		
		show_dialog() {
		    yad --title="$1" --on-top \
		        --image="$LOGO_PATH" \
				--buttons-layout=center \
		        --text="$2" \
		        --button="OK:0" \
		        --center \
		        --width=300
		}

	    response=$(yad --title="ISO Image Importer" \
	        --width=400 \
	        --height=200 --on-top \
	        --image="$LOGO_PATH" \
	        --center \
	        --text="Search for and import ISO images" \
	        --text-align=center \
	        --window-icon="drive-optical" \
			--buttons-layout=center \
	        --buttons-layout=center \
	        --button="Search and Import:0" \
	        --button="Cancel:1")
	
	    if [ $? -eq 0 ]; then
	        mapfile -d '' iso_files < <(find "$HOME" -type f -name "*.iso" -not -path "$HOME/QVM/*" -print0)
	
	        if [ ${#iso_files[@]} -eq 0 ]; then
	            show_dialog "No ISOs Found" "The ISO search did not find any images to import!"
	        else
	            if sudo mv "${iso_files[@]}" "$ISO_DEST"; then
	                show_dialog "Import Successful" "Image(s) successfully imported!"
	            else
	                if [ $? -eq 1 ]; then
	                    show_dialog "Permission Error" "Permission denied to move files.\n\nPlease ensure you have sufficient permissions."
	                else
	                    show_dialog "Import Failed" "ISO import failed!\n\nAn unexpected error has occurred."
	                fi
	            fi
	        fi
	    fi
	fi

	
	if [ "$1" = "-e" ]; then
	    cdrom=$(ls ../ISO_Images/cdrom/ | cut -d. -f1)
		cdromli=$(echo $cdrom | sed 's/ /\!/g')
	    if ! [ -z "$cdrom" ]; then
	        iso=$(echo $cdrom | yad --form \
    			--image="$HOME/QVM/config_files/logo_images/qvm-2.png" \
	            --title="QVM-v1.0.3 - Eject Disk Image" \
	            --text="The QVM cdrom can use multiple disks simultaneously.\nFor that reason it is always necessary to specify which disk to eject." \
				--field="Select Image: ":CB "$cdromli"\
				--buttons-layout=center \
		        --button="Cancel:1" --button="Eject:0")
	        
	        if [ -z "$iso" ]; then
	            exit 0
	        fi
			iso=$(echo $iso | cut -d "|" -f1)
	
	        if [ -f "../ISO_Images/cdrom/$iso.iso" ]; then
	            echo "Ejecting the ISO disk from the cdrom..."
	            sudo mv "../ISO_Images/cdrom/$iso.iso" "../ISO_Images/" | \
	            yad --bar \
	                --title="Ejecting ISO Disk" \
					--buttons-layout=center \
	                --width=300 \
	                --height=100 \
	                --text="Ejecting the ISO disk from the QVM cdrom..." \
	                --pulsate \
	                --auto-close 
				if ! $(ls ../ISO_Images/cdrom/ | cut -d. -f1 | grep "$iso"); then
	            	echo "'$iso'ISO disk ejected."
			        zenity --error --title="Eject ISO Disk" \
			            --text="The '$iso'ISO disk has been ejected!" --timeout=3 2>/dev/null
				else
					echo "qvm-manager: Unexpected error: Operation Cancelled!"
				fi
	        else
	            echo "Selected ISO does not exist in the QVM cdrom!"
	            zenity --error --title="Eject ISO Disk" \
	                --text="Selected ISO does not exist in cdrom!" --timeout=2 2>/dev/null
	        fi
	    else
	        echo "There are no ISO disks in the cdrom!"
	        zenity --error --title="Eject ISO Disk" \
	            --text="There are no ISO disks in the QVM cdrom!" --timeout=3 2>/dev/null
	    fi
	    exit 0
	fi
fi
