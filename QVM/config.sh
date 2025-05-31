#!/bin/bash

echo -e "\nQEMU Virtual Machine Manager v1.0.3 © QVM 2024\n\nRunning the 'qvm-manager' config script...."

# Move to the 'tmp' folder and clone the QVM files
echo "[+] qvm-manager: Cloning the necessary QVM config files..."
cd /tmp/
git clone https://github.com/RoyalHighgrass/QVM-Manager.git
cd QVM-Manager

echo -e "[+] qvm-manager: Installing basic required for QVM to work properly..."

# Define QVM config paths
config_f="$HOME/QVM/config_files"
cli="$HOME/QVM/config_files/CLI"
gui="$HOME/QVM/config_files/GUI"
settings="$HOME/QVM/config_files/settings"

# Install dependencies
if ! [[ "$@" =~ "-set-" ]]; then
 	sudo chmod +x QVM/deps.sh
	./QVM/deps.sh || echo "[!] An unexpected error while tring to install the necessary dependencies." && exit 1
fi

### Upcoming resource management feature scheduled for the official `QVM-v1.0.4` release 
## Ensure necessary folders exist for CPU resource limiting processes
#sudo mkdir -p /sys/fs/cgroup/cpu/qvm_machine
#sudo mkdir -p /sys/fs/cgroup/cpuset/qvm_machine
#sudo mkdir -p /sys/fs/cgroup/memory/qvm_machine
#sudo mkdir -p $HOME/QVM/config_files/vm_log_files


## Setup the QVM filesystem & copy or create in the necessary QVM files
echo -e "[+] qvm-manager: Setting up the QVM-v1.0.3 file system..."
# Create the QVM directory
mkdir $HOME/QVM

# Get the users username
_USER=$(whoami)

# Define icon path & the users application menu icons
ICON_PATH="$config_f/logo_images/qvm-2.png"

# Create the 'Start QVM' .desktop icon file
echo "[Desktop Entry]
Name=Start QVM
Version=v1.0.3
StartupWMClass=qvm-manager
GenericName=QVM;qvm-manager;QVM Manager;
Comment=Type 2 QEMU hypervisor
Exec=/usr/bin/qvm-manager --gui
Terminal=false
Icon=$ICON_PATH
Type=Application
Categories=Other;Administration;System;Linux apps;
Keywords=QVM;QEMU;Quick Emulator;Virtuialization;VM;Virtual Machine Manager;Type 2;Hypervisor;Linux;Open-source;
" > $HOME/start-qvm.desktop

# Create the 'Stop QVM' .desktop icon file
echo "[Desktop Entry]
Name=Stop QVM
Version=v1.0.3
StartupWMClass=qvm-manager
GenericName=QVM;qvm-manager;QVM Manager;
Comment=Type 2 QEMU hypervisor
Exec=/$settings/stop-qvm.sh
Terminal=false
Icon=$ICON_PATH
Type=Application
Categories=Other;Administration;System;Linux apps;
Keywords=QVM;QEMU;Quick Emulator;Virtuialization;VM;Virtual Machine Manager;Type 2;Hypervisor;Linux;Open-source;
" > $HOME/stop-qvm.desktop

sudo cp $HOME/start-qvm.desktop /usr/share/applications/start-qvm.desktop
sudo cp $HOME/stop-qvm.desktop /usr/share/applications/stop-qvm.desktop
sudo cp README.md $HOME/QVM/
sudo cp -r QVM/* $HOME/QVM/
sudo mkdir -p $config_f/ISO_Images/cdrom
sudo mkdir -p $config_f/VM_Images
sudo mkdir -p $config_f/vm_log_files

# Create the /usr/bin/ instance & initialise the 'qvm-manager' startup command
echo -e -n "[+] qvm-manager: Creating the 'qvm-manager' command configuration file for launching or creating QVM sessions & instances ... "

sudo tee -a /usr/bin/qvm-manager > /dev/null << 'EOF'

# Environment variables
export GTK_IM_MODULE=none
export XDG_RUNTIME_DIR=none
export WAYLAND_DISPLAY=wayland-0
export GDK_BACKEND=x11
export MESA_LOADER_DRIVER_OVERRIDE=i965
export LIBGL_ALWAYS_SOFTWARE=1
export XDG_CONFIG_HOME="$HOME/.config"

# User manual (Man Page)
user_manual="$HOME/QVM/User_Manual_-_QVM_Documentation.txt"

# Working directories
QVMcli="$HOME/QVM/config_files/CLI/"
QVMgui="$HOME/QVM/config_files/GUI/"
VM="$HOME/QVM/config_files/VM_Images/"
ISO="$HOME/QVM/config_files/ISO_Images/"

# Software version
version="QEMU Virtual Machine Manager v1.0.3 © QVM 2024"

# Text colours
b="\033[34m"
w="\033[0m"

# QVM initializer script
if [ -z "$1" ]; then
	cd "$QVMcli"
	bash qvm-manager.sh
else
	case "$1" in
		--gui)
			# Launch the QVM graphical user interface.
			cd "$QVMgui" || exit
			bash qvm-manager-gui.sh
		;;
		--delete-iso)
			# Delete a specified ISO image or all ISO images.
			if [ -z "$2" ]; then
				echo -e "${b}qvm-manager: Error: Invalid input: No ISO image specified!${w}"
				exit 1
			else
				cd "$QVMcli"
		if [ "$2" != "all" ]; then
			iso="$2"
			term="the $iso ISO image"

				# Check if ISO exists
			if ! bash Scripts/iso.sh -gi | sed 's/.iso//g' | grep "$2" &>/dev/null; then
				echo -e "${b}qvm-manager: Error: Invalid input: The ${w}$2${b} ISO image was not found!${w}"
				exit 1
			fi
		else
			iso="*"
			term="all ISO images"
		fi
		fi
			echo -e "${b}$version${w}\n"
		# Confirm delete request
			read -p "Are you sure you want to delete $term? [y/N]: " confirm
		if [[ "$confirm" =~ ^[Yy]$ ]] || [[ "$confirm" =~ ^[Yy]es$ ]]; then
		# Delete ISO
		cd "$ISO"
		eval sudo rm "${iso}.iso"
		# Operation status
		case $? in
					0)	echo -e "${b}You have successfully deleted ${term}!${w}"
					;;
					1)	echo -e "${b}qvm-manager: Error: Failed to delete ${term}!${w}"
					;;
				esac
		else
		# Cancel operation
		echo -e "${b}qvm-manager: Operation cancelled!${w}"
		fi
			echo -e "\n${b}$version${w}"
		;;
		--delete-snap)
			# Delete a specified snapshot.
			if [ "$#" -ne 4 ]; then
				if [ -z "$2" ]; then
			echo -e "${b}qvm-manager: Error: Invalid input: No VM name provided!${w}${w}"
		fi
			echo -e "${b}qvm-manager: Usage: $(basename $0) --delete-snap <vm_name> --tag <snapshot_tag>${w}"
				exit 1
		else	
		# Check if the VM exists
		VM_FILE="${VM}/${2}.img"
		if [ ! -f "$VM_FILE" ]; then
					echo -e "${b}qvm-manager: Error: The ${w}$2${b} virtual machine does not exist!${w}"
		fi
			fi

		# Assign OPTION/TAG variables
			OPTION="$3"
			TAG="_$4_"

		# Check if any snapshots have been taken of the VM
			ckss=$(qemu-img snapshot -l "$VM_FILE")
			if [ -z "$ckss" ]; then
				echo -e "${b}qvm-manager: Error: No snapshots have been saved of the '$2' virtual machine!${w}"
			fi

		# Usage validation
			if [ "$OPTION" != "--tag" ]; then
				echo -e "${b}qvm-manager: Error: Invalid option '$OPTION'. Only '--tag' is supported.${w}"
				exit 1
			fi

		# Delete snapshot
			echo -e "${b}$version${w}"
			qemu-img snapshot -d "$TAG" "$VM_FILE"

		# Operation status
			EXIT_CODE=$?
			if [ $EXIT_CODE -eq 0 ]; then
				echo -e "${b}The snapshot '${w}$(echo $TAG | sed 's/_//g')${b}' of VM '${b}${2}${b}' has been successfully deleted!${w}"
			else
				echo -e "${b}qvm-manager: Operation failed: Failed to delete snapshot '$SNAPSHOT_TAG'. Check qemu-img output for details.${w}"
			fi
			exit $EXIT_CODE
			echo -e "${b}$version${w}"
		;;
		--delete-vm)
			# Delete a specified VM.
			if [ -z "$2" ]; then
				echo -e "${b}qvm-manager: Error: Invalid input: No VM name provided!${w}"
			else
				# Check if the VM exists
				vm_name="$2"
				echo -e "${b}$version${w}"
				vm_to_delete=$(find "$VM" -type f -name "*.img" | grep "$vm_name")
				if ! [ -z "$vm_to_delete" ]; then
					# Confirm delete request
					read -p "Are you sure you want to delete this VM? [Y/n]: " confirm
					if [ "$confirm" = [Yy] ] || [ "" = ^[Yy]es$ ]; then
					# Delete VM 
					echo -e "${b}Deleting the ${w}$vm_name${b} virtual machine...${w}"
					sudo rm "$vm_to_delete"
					# Operation status
					case $? in
						0)	echo -e "${b}The ${w}$vm_name${b} VM was successfully deleted!'${w}"
						;;
						1)	echo -e "${b}qvm-manager: Operation failed: Failed to delete the VM!${w}"
						;;
					esac
					else
					# Cancel operation
					echo -e "${b}Operation cancelled!${w}"
					fi
				else
					echo "qvm-manager: Error: That VM does not exist!"
				fi
			fi
		;;
		--help|-h)
			# Display this help message or list all CLI options.
		if [ -z "$2" ]; then
		# Display help message/user manual 
		echo -e "$(cat "$user_manual")"
		else
		# List all CLI options
		if [ "$2" != "options" ]; then
			echo "qvm-manager: Invalid input!: $2"
			exit 1
		fi
		echo -e "${b}$version${w}\n"
		cat $user_manual | grep -E "\-\-|#|OPTION|EXAMPLE"
				echo -e "\n${b}$version${w}"
		fi
		;;
		--import-iso)
		# Import manually downloaded ISO images.
			# Store the list of found ISO files in a variable
			list=$(find "$HOME" -type f -name "*.iso" | grep -v "ISO_Images")
			if [ -z "$list" ]; then
				echo "qvm-manager: QVM did not find any ISO files to import!"
				exit 1
			fi
			echo -e "${b}$version${w}"
			echo -e "\n${b}Moving the following ISO images to the QVM ISO image folder...${w}"		
		echo "$list"
		
			# Iterate over each file found
			for file in $list; do
				# Construct new file path
				new_name="$HOME/QVM/config_files/ISO_Images/${file##*/}"  # Use ##*/ to get only the filename
				new_name=$(echo $new_name | cut -d. -f1)
				new_name="${new_name%.*}.iso"  # Ensure it has .iso extension
		
				# Move the file and check if it was successful
				sudo mv "$file" "$new_name"
				case $? in
					0)  echo -e "${b}Image '$(basename $file)' successfully imported as '$new_name'!${w}"
					;;
					1)  echo -e "${b}ISO import failed for '$(basename $file)'!${w}"
					;;
				esac
				echo -e ""
			done || echo -e "${b}ISO import failed!${w}"
			echo -e "${b}$version${w}"
		;;
		--list-iso)
			# List all local ISO images.
			echo -e "${b}$version${w}\n"
		cd "$QVMcli"
		bash Scripts/iso.sh -gi | sed 's/.iso//g'
			echo -e "\n${b}$version${w}"
		;;
		--list-vm)
			# List all existing VMs.
			echo -e "${b}$version${w}\n"
			cd "$QVMcli"
			bash qvm-manager.sh -gv
			echo -e "\n${b}$version${w}"
		;;
		--pull-iso)
			# Download an specified ISO image or list available images.
			cd "$QVMgui"
		if [ "$2" = "list" ]; then
		echo -e "${b}$version${w}"
		bash Scripts/download-iso-images-gui.sh -li | grep -v -E "None|Select" | cut -d. -f2
		echo -e "\n${b}$version${w}"
		exit 0
		fi
			echo -e "${b}$version${w}"
		bash Scripts/download-iso-images-gui.sh
			echo -e "\n${b}$version${w}"
		;;
		--revert)
			# Define tag
		TAG="_$4_"
	 
		# Use a snapshot to revert the VM back to a previous state.
			if [ "$#" -ne 4 ]; then
				if [ -z "$2" ]; then
					echo -e "${b}qvm-manager: Error: Invalid input: No VM name provided!${w}"
					exit 1
				fi
				echo -e "${b}qvm-manager: Usage: $(basename $0) --revert <vm_name> --tag <snapshot_tag>${w}"
				exit 1
			else
				VM_FILE="${VM}/${2}.img"
				if [ ! -f "$VM_FILE" ]; then
					echo -e "${b}qvm-manager: Error: That virtual machine does not exist!${w}"
			exit 1
		fi
				if [ "$3" != "--tag" ]; then
					echo -e "${b}qvm-manager: Usage: $(basename $0) --revert <vm_name> --tag <snapshot_tag>${w}"
					exit 1
				fi
			fi
			echo -e "${b}$version${w}\n"
		echo -e "${b}You are about to roll back a virtual machine to a previous state which may result in the loss of data. Once the roll back is complete, the process cannot be undone!${w}"
		read -p "Are you sure that you want to revert this VM back to a previous state? [Y/n]: " confirm
		if [ "$confirm" = [Yy] ] || [ "$confirm" = ^[Yy]es$ ]; then 
		echo -e "${b}Proceeding with VM roll back...${w}"
		else
		echo -e "${b}qvm-manager: Operation cancelled!${w}"
				echo -e "\n${b}$version${w}"
		exit 1
		fi
		echo -e "Reverting the $2 virtual machine back to a previous state using the $4 snapshot!"
		qemu-img snapshot -a "$4" "$VM_FILE"
			EXIT_CODE=$?
			if [ $EXIT_CODE -eq 0 ]; then
			  echo -e ${b}"The ${w}${2}${b} VM has been successfully rolled back to the point of the ${w}${4}${b} snapshot!${w}"
			else
			  echo -e "${b}qvm-manager: Error: Failed to revert the $2 VM back to a previous state using the ${w}${4}${b} snapshot${w}'"
			fi
			echo -e "\n${b}$version${w}"
			exit $EXIT_CODE
		;;
	--show-snap)
		# List all snapshots for a specified VM.
			if [ "$#" -ne 2 ]; then
			  echo -e "${b}qvm-manager: Usage: $(basename $0) --show-snap <vm_name>${w}"
			  exit 1
			else
		VM_FILE="${VM}/${2}.img"
		if [ ! -f "$VM_FILE" ]; then
			echo -e "${b}qvm-manager: Error: That virtual machine does not exist!${w}"
			exit 1
		else
			echo -e "${b}$version${w}\n"
			echo -e -n "'$2' "
			qemu-img snapshot -l "${VM}/${2}.img" | sed 's/Snapshot/snapshot/g' | sed 's/list:/list:\n/g' | sed 's/_//g'
				echo -e "\n${b}$version${w}"
		fi
			fi
	;;
		--show-vm)
			# Show a VM's Specs.
			cd "$QVMcli"
		if [ -z "$2" ]; then
				echo "${b}qvm-manager: Usage: $(basename $0) --show-vm <vm_name>${w}"
		exit 1
		fi
		vms="$2"
		if ! bash qvm-manager.sh -gv | grep $vms &>/dev/null; then
		echo -e "${b}qvm-manager: Error: You have not created any virtual machines yet!${w}"
		else
		vmss=$(cat $HOME/QVM/config_files/vm_log_files/${vms}_vm_specs)
		echo "CPU's: $(echo $vmss | awk -F '" "' '{print $1}')"
		echo "Created: $(echo $vmss | awk -F '" "' '{print $11}' | cut -d'"' -f1)"
		echo "Display: $(echo $vmss | awk -F '" "' '{print $8}')"
		echo "Graphical Memory: $(echo $vmss | awk -F '" "' '{print $10}' | cut -d"\"" -f1)"
			echo "Hard Disk Storage Size: $(echo $vmss | awk -F '" "' '{print $4}')GB"
		echo "KVM Enabled: $(echo $vmss | awk -F '" "' '{print $6}')"
		echo "Memory (RAM): $(echo $vmss | awk -F '" "' '{print $2}')"
		echo "Network Interface: $(echo $vmss | awk -F '" "' '{print $7}')"
		echo "OS: $(echo $vmss | awk -F '" "' '{print $3}' | cut -d. -f1)"
		echo "Storage Format: $(echo $vmss | awk -F '" "' '{print $5}')"
		echo "VGA Enabled: $(echo $vmss | awk -F '" "' '{print $9}')"
		echo "VM Name: $vms"
		fi
		;;
	--snap)
			# Save a snapshot of an existing VM.
			if [ "$#" -ne 4 ]; then
				if [ -z "$2" ]; then
					echo -e "${b}qvm-manager: Error: Invalid input: No VM name provided!${w}"
					exit 1
				fi
				echo -e "${b}qvm-manager: Usage: $(basename $0) --snap <vm_name> --tag <snapshot_tag>${w}"
			fi

			VM_NAME="$2"
			OPTION="$3"
			TAG="_${4}_"

			VM_FILE="${VM}/${2}.img"
			if [ ! -f "$VM_FILE" ]; then
			  echo -e "${b}qvm-manager: Error: The '${w}${2}${b}' virtual machine does not exist!${b}"
			  exit 1
			fi

		running=$(ps aux | grep qemu-system | grep ${2}.img)
		if ! [ -z "$running" ]; then
		echo -e "${b}qvm-manager: Operation not permitted: The ${w}$2${b} VM is currently running!\n\nTo facilitate effecient host storage management, QVM does not allow snapshots to be taken of running machines. Please try again once the ${w}$2${b} VM has been shutdown.${w}"
		exit 1
		fi

			if [ "$OPTION" != "--tag" ]; then
			  echo -e "${b}qvm-manager: Error: Invalid option '$OPTION'. Only '--tag' is supported.${w}"
			  exit 1
			fi

			echo -e "${b}$version${w}\n"
			qemu-img snapshot -c "$TAG" "$VM_FILE"
			EXIT_CODE=$?
			if [ $EXIT_CODE -eq 0 ]; then
			  echo -e ${b}"The snapshot '${w}$(echo $TAG | sed 's/_//g')${b}' of VM '${w}${2}${b}' has been successfully created.${w}"
			else
			  echo -e "${b}qvm-manager: Error: Failed to create snapshot '${w}$TAG${b}'. Check qemu-img output for details.${w}"
			fi
			echo -e "\n${b}$version${w}"
			exit $EXIT_CODE
		;;
		--start)
			# Start an existing VM.
			if [ -z "$2" ]; then
				echo "qvm-manager: Error: Invalid input: No VM name provided!"
			else
				if ! find $HOME/QVM/ -type f -name "*.img" | grep "$2" &>/dev/null; then
					echo "qvm-manager: Error: That VM does not exist!"
				else
					if ps aux | grep -q "[q]emu-system.*$2" &>/dev/null; then
					echo -e "${b}qvm-manager: Operation failed: The ${w}$2${b} VM is already running!${w}"
					else
					echo -e "${b}Starting the${w} $2 ${b}virtual machine. Running mounted VM image..."
					sleep 1
					start_command=$(cat $HOME/QVM/config_files/vm_log_files/${2}_vm_restart)
					echo -e "${b}Opening the ${w}$2${b} VM interface...${w}"
					eval "$start_command"
					echo -e "${w}$2 ${b}VM interface closed..."
					echo -e "The ${w}$2${b} virtual machine has been shut down and is no longer running!${w}\n"
					fi
				fi
			fi
		;;
  		--uninstall)
			# Make sure that QVM is not running
			cd "$QVMgui"
   			bash ./../settings/stop-qvm.sh
			# Remove all QVM files
			echo -e "qvm-manager: Removing QVM from the system... "
			# Confirm choice
			read -p "qvm-manager: Are you sure you want to purge all QVM files? [Y/n]: " uninstall
			# Validate input
			case $uninstall in
				[Yy])	# Remove files
						sudo rm -r ~/QVM ~/*qvm.desktop /usr/bin/qvm-manager /usr/share/applications/*qvm.desktop
			   			sudo update-desktop-database
				  		sudo gtk-update-icon-cache
				 		echo -e "done!"
				;;
				*)	# Exit
					exit 1
				;;
			esac
		;;
		--version|-v)
			# Display version information of QVM installation.
			echo -e "${b}$version${w}" 
		;;
		*)
			echo -e "${b}qvm-manager: Invalid option: '$1'${w}"
		;;
	esac
fi

EOF
echo "done!"

# Give all QVM files executable permissions & non-root ownership
echo -e -n "[+] qvm-manager: Configuring newly created files ... "
sudo chmod +x /usr/bin/qvm-manager
sudo chmod +x $cli/qvm-manager.sh
sudo chmod +x $cli/Scripts/*.sh
sudo chmod +x $gui/qvm-manager-gui.sh
sudo chmod +x $gui/Scripts/*.sh
sudo chmod +x $settings/*.sh
sudo chmod -R 755 $HOME/QVM/*.sh
sudo chown -R $(whoami) $HOME/QVM
sudo chmod +x $HOME/start-qvm.desktop
sudo chmod -R 755 $HOME/start-qvm.desktop
sudo chmod +x $HOME/stop-qvm.desktop
sudo chmod -R 755 $HOME/stop-qvm.desktop
sudo chmod +x /usr/share/applications/start-qvm.desktop
sudo chmod -R 755 /usr/share/applications/start-qvm.desktop
sudo chmod +x /usr/share/applications/stop-qvm.desktop
sudo chmod -R 755 /usr/share/applications/stop-qvm.desktop
sudo chmod -R 755 ~/.config/dconf
echo -e "done!"

# Verify host OS & install YAD manually if necessary
if ! [ "$pm" = "pacman" ]; then
	echo -e -n "[+] qvm-manager: Checking for YAD ... "
	if ! which yad; then
		echo -e "not found!"
		# Clone YAD repository & configure, make, and install YAD		
		echo -e "[+] qvm-manager: Installing YAD ..."
		cd /tmp/
		git clone https://github.com/v1cont/yad.git
		cd yad/
		# Configure with standalone option and custom defines
		autoreconf -ivf && intltoolize --force
		./configure
		make
		sudo make install && CFLAGS="-DBORDERS=10 -DREMAIN -DCOMBO_EDIT" ./configure --enable-standalone && \
  		echo -e "[+] qvm-manager: YAD installation complete!" || \
		echo -e "[+] qvm-manager: YAD is already installed ... skipping installation!"
	fi
fi

# Install additional functionality
if [[ "$pm" != "pacman" ]]; then
	sudo apt install -y libgtksourceview-3.0-dev
elif [[ "$is_rpi" != "raspberry" ]]; then
	sudo apt install -y libwebkit2gtk-4.0-dev
fi
sudo apt install libgspell-1-dev
sudo apt install grub-pc-bin

# Update system database & icon cache
echo -n "Updating the system database & icon cache.... (this may take some time) ... "
sudo updatedb
sudo gtk-update-icon-cache
sudo update-desktop-database
echo "done!"

echo -e "[+] qvm-manager: QVM installation complete!\n\nUse the 'qvm-manager' or 'qvm-manager --gui' command to get started with your QVM virtualization experience.\nFor speedy usage both commands can be executed by pressing 'qvm' then the 'tab' key to autocomlete the command then press 'enter' with or without ' --gui' appended to it. Happy virtualization! ~ P.H."
echo -e "\nQEMU Virtual Machine Manager v1.0.3 © QVM 2024"
cd $HOME
