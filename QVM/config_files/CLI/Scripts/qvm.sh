#!/bin/bash

# Function to handle cleanup when script is interrupted
#cleanup() (
#  echo "Process interrupted. Returning to the main menu..."
#  ./qvm-manager.sh
#  exit 0
#)

b="\033[34m"
w="\033[0m"

validate_input() {
    local arg=$1
	if [ -z "$arg" ] || [ "$arg" = 0 ]; then
		echo -e "${b}Exit signal received... The VM creation process will be cancelled!${w}"
		read -p "Are you sure you want to cancel? [Y/n]: " ep
		if [ "$ep" = [Yy] ] || [ "$ep" = ^[Yy]es$ ]; then
			echo -e "${b}Operation cancelled!${w}"
			exit 1
		fi
	fi
}

# Set trap
#trap cleanup SIGINT

# Get VM name
echo ""
read -p "HD Image name (Leave blank to cancel): " img_nme
[ -z "$img_nme" ] && echo -e "${b}Error: Invalid entry! Operation Cancelled.${w}\n" && exit 1

# Check if the image file exists
vm_exists=$(find $HOME -type f -name '*.img' | grep $img_nme)
if [ -z "$vm_exists" ]; then
    echo -e "${b}That virtual machine does not exist. Creating a new VM..."

	# Check atart Command
 	sys_arch=$(uname -m)
  	case "$sys_arch" in
		x86_64)
  			new_vm_command="qemu-system-x86_64"
	 		need_efi=false
  		;;
		aarch64)
  			new_vm_command="qemu-system-aarch64"
	 		need_efi=true
  		;;
		*)
  			echo "Detected an unknown architecture!"
	 		exit 1
  		;;
	esac
	
	# Get new VM specifications #

	# Storage
	host_storage=$(df -h | grep -E "Avail|kvm|qemu|dev|mmcblk0" | head -n 3)
 	echo "$host_storage"
	available_host_storage=$(echo "$host_storage" | awk '{print $4}' | cut -dG -f1)
	echo -e -n "${w}"
    while true; do
		read -p "Specify HD disk size (must be an 'int', minimum of '20-30' is recommended): " HD
		validate_input $HD
		if [[ "$HD" =~ ^[0-9]+$ ]]; then
	        if [ "$HD" -ge 12 ] || [ "$HD" -lt "$available_host_storage" ]; then
				break
	        else
	            if [ "$HD" -le 6 ]; then 
					echo -e "${b}Error: Host storage is almost completely full. It is recommendeded that you backup important data immediately!${w}"
				else
					echo -e "${b}Error: Size must be at least 15 & not more than${w} ${available_host_storage}${b}!${w}"
				fi
	        fi
		else
	        echo -e "${b}Error: Invalid input! Please enter an integer.${w}"
		fi
	done
	
	# Storage format
	echo -e "${b}Available storage formats;${w}"
	echo -e "qcow2\nraw\nvdi\nvmdk\nvhd" | nl
    while true; do 
		read -p "Specify HD disk format ('qcow2' recommended): " format
		validate_input $format
		if [ "$format" = "1" ]; then
			format="qcow2"
			break
		elif [ "$format" = "2" ]; then
			format="raw"
			break
		elif [ "$format" = "3" ]; then
			format="vdi"
			break
		elif [ "$format" = "4" ]; then
			format="vmdk"
			break
		elif [ "$format" = "5" ]; then
			format="vhd"
			break
		else
			echo -e "${b}Error: Invailid option!${w}"
		fi
	done
	drive_id=$(( RANDOM % 1000 + 1 ))
	drive_id="drive${drive_id}"
	new_vm_command+=" -drive file=\"$HOME/QVM/config_files/VM_Images/$img_nme.img\",cache=writeback,id=$drive_id,format=${format}"
	vmr+=" -drive file=\"$HOME/QVM/config_files/VM_Images/$img_nme.img\",cache=writeback,id=$drive_id,format=${format}"
	
	# CPU
	echo -e "${b}Your system has '${w}$(nproc)${b}' CPU's available${w}"
	while true; do
		read -p "How many host CPU's should be used?: " CPU
		validate_input $CPU
		if [[ "$CPU" =~ ^[0-9]+$ ]]; then
	        if [ "$CPU" -ge 1 ] || [ "$CPU" -lt $(nproc) ]; then
				break
			else
				echo -e "${b}Invalid Entry: You're selection must be between${w} 1 ${b}&${w} $(nproc)${b}!${w}"
			fi
		else
			echo -e "${w}Error: Invalid input! Please enter an interger.${w}"
		fi
	done
	new_vm_command+=" -smp ${CPU},sockets="$CPU",cores=1,threads=1 " 
	vmr+=" -smp ${CPU},sockets="$CPU",cores=1,threads=1 " 
	new_vm_command+=" -object iothread,id=iothread0" 
	vmr+=" -object iothread,id=iothread0" 
	
	# Memory
	host_free_memory=$(free -h | awk '/^Mem:/ {print $4}' | sed 's/[^0-9.]//g')
	recommd=$(echo $host_free_memory | bc | cut -d. -f1)
	echo -e "${b}There is '${w}${host_free_memory}${b}' GB of available host memory, minimum of '${w}2-4${b}' GB (recommended)${w}"
	while true; do
		read -p "How much of the hosts memory should be used? (Must be an 'int'): " MEM
		validate_input $MEM
		if [[ "$MEM" =~ ^[0-9]+$ ]]; then
	        if [ "$MEM" -ge 2 ] || [ "$MEM" -lt $recommd ]; then
				break
			else
				echo -e "${b}Invalid Entry: You're entry must be between${w} 2 ${b}&${w} $recommd${b}!${w}"
			fi
		else
			if [ "$MEM" -lt 1 ]; then
				echo -e "${b}You have not allocated enough memory to create an efficient virtual machine. Please allocate more memory!${w}"
			else
				echo -e "${b}Error: Invalid entry!${w}"
			fi
		fi
	done
	
	# Audio Drivers
	echo -e "${b}Available audio drivers;${w}"
	echo -e "none\nPulseAudio\nALSA\nOSS\nsdl\nCoreAudio\nPipeWire\nSpice" | nl
	while true; do
		read -p "Enter a number between 1-8 to select an Audio driver: " AUD
		validate_input $AUD
		if [ $AUD -ge 0 ] && [ $AUD -lt 8 ]; then
			if [ "$AUD" = "1" ]; then
				AUD="none"
				break
			elif [ "$AUD" = "2" ]; then
				AUD="pa"
				break
			elif [ "$AUD" = "3" ]; then
				AUD="alsa"
				break
			elif [ "$AUD" = "4" ]; then
				AUD="oss"
				break
			elif [ "$AUD" = "5" ]; then
				AUD="sdl"
				break
			elif [ "$AUD" = "6" ]; then
				AUD="coreaudio"
				break
			elif [ "$AUD" = "7" ]; then
				AUD="pipewire"
				break
			elif [ "$AUD" = "8" ]; then
				AUD="spice"
				break
			fi
		else
			echo -e "${b}invalid!${w}"
		fi
	done
	
	if [[ "$AUD" = "none" ]]; then
		new_vm_command+=""
	else
		# Audio Driver Models
		echo -e "${b}Available audio drivers models;${w}"
		echo -e "none\nac97\nadlib\ncs43221a\nes1370\nhda\nsb16\nintel-hda" | nl
		while true; do
			read -p "Enter a number between 1-7 to select an Audio driver: " AUDM
			validate_input $AUDM
			if [ $AUDM -ge 0 ] && [ $AUDM -lt 7 ]; then
				if [ "$AUDM" = "1" ]; then
					AUDM="none"
					break
				elif [ "$AUDM" = "2" ]; then
					AUDM="ac97"
					break
				elif [ "$AUDM" = "3" ]; then
					AUDM="adlib"
					break
				elif [ "$AUDM" = "4" ]; then
					AUDM="cs43221a"
					break
				elif [ "$AUDM" = "5" ]; then
					AUDM="nes1370"
					break
				elif [ "$AUDM" = "6" ]; then
					AUDM="hda"
					break
				elif [ "$AUDM" = "7" ]; then
					AUDM="sb16"
					break
				fi
			else
				echo -e "${b}invalid!${w}"
			fi
		done
		
		snd_id=$(( RANDOM % 1000 + 1 ))
		snd_id="${AUD}${snd_id}"
		new_vm_command+=" -audio ${AUD},model=${AUDM}"
	fi
	
	# Enable Debug Mode
	new_vm_command+=" -d cpu_reset -d guest_errors"
	
	# Log VM with QEMU
	new_vm_command+=" -D $HOME/QVM/config_files/vm_log_files/qemu.log"

	# Enable KVM
	vt_support=$(lscpu | grep -E "Virt|Hyp" | grep -E "KVM|full|VT-x|AMD-V")
	if ! [[ "$vt_support" =~ "KVM" ]]; then
		echo -e "${b}It looks like your system doesn't support hardware virtualization so KVM cannot be enabled!${w}"
		vt_support="0"
		if [[ "$sys_arch" == "aarch64" ]]; then
			model_name=$(cat /proc/cpuinfo | grep -i model | sort | uniq)
   			if [[ "$model_name" =~ "Raspberry Pi" ]]; then
   				new_vm_command+=" -machine raspi3b"
	   			vmr+=" -machine raspi3b"
	  		else
	  			new_vm_command+=" -machine virt"
				vmr+=" -machine virt"
			fi
  		fi
	else
		echo -e "${b}Your system supports full KVM virtualization...${w}"
		while true; do
			read -p "Enable KVM? [Y/n]: " enable_kvm
			validate_input $enable_kvm
			case "$enable_kvm" in
				[Yy]* | yes)
					kvm_=",kvm=on"
					new_vm_command+=" -enable-kvm"
					kvm_e="Yes"
	 				break
				;;
				[Nn]* | no)
					kvm_=""
					new_vm_command+=""
					kvm_e="No"
	 				break
				;;
				*)
					echo -e "${b}Error: Invalid entry!${w}"
				;;
			esac
		done
		vt_support="1"
	fi
	vmr="$new_vm_command"

	# OS Image
	echo -e "${b}Available ISO Images;${w}"
	find $HOME/QVM/ -type f -name "*.iso" -print0 | xargs -0 basename -s .iso -a | nl -s ". "
	while true; do 
		read -p "Enter the coresponding number to select an ISO image: " p_iso
		validate_input $p_iso
		if [[ "$p_iso" =~ ^[0-9]+$ ]]; then
			iso_=$(find $HOME -type f -name "*.iso" | nl -s ". " | sed -n "${p_iso}p" | awk '{print $2}')
			break
		else
			echo -e "${b}Error: Invalid selection!${w}"
		fi
	done
	if echo $iso_ | grep cdrom; then
		echo -e "${b}That ISO disk is already in the QVM cdrom & ready to use... ${w}"
	else
		echo -e "${b}Placing the selected ISO disk in the QVM cdrom...${w}"
		sudo mv "$iso_" "$HOME/QVM/config_files/ISO_Images/cdrom/"
		iso_=$(echo $iso_ | sed 's/ISO_Images/ISO_Images\/cdrom/g')
	fi
	new_vm_command+=" -cdrom ${iso_}"
	os_basename=$(echo $iso_ | xargs -0 basename -s .iso -a)
	
	# Boot Options
	if ! [[ "$sys_arch" == "aarch64" ]]; then
	 	echo -e "${b}Available boot options;${w}"
		echo -e "once=d\nmenu=on\norder=nc" | nl
		while true; do
			read -p "Enter a number between 1-3 to select a boot option: " boot_options
			validate_input $boot_options
			if [ "$boot_options" = 1 ] || [ "$boot_options" = 3 ]; then
				if [ "$boot_options" = 1 ]; then
					new_vm_command+=" -boot once=d"
					vmr+=" -boot once=d"
					break
				else
					new_vm_command+=" -boot order=nc"
					vmr+=" -boot order=nc"
					break
				fi
			else
				if [ "$boot_options" = 2 ]; then
					new_vm_command+=" -boot menu=on"
					vmr+=" -boot menu=on"
					break
				else
					echo -e "${b}Error: Invalid entry!${w}"
				fi
			fi
		done
		echo $boot_options
	fi

	# Memory
	new_vm_command+=" -m ${MEM}G"
	vmr+=" -m ${MEM}G"

	# Hardware Virtualization & Virtual Hardware
	if [ "$vt_support" = "1" ]; then
		echo -e "${b}Available hardware virtualisation options;${w}"
		echo -e "host\nOpteron_G5\nEPYC" | nl
		while true; do
			while true; do
				read -p "Enter a number between 1-3 to select your hardware virtualisation solution: " hvirt
				validate_input $hvirt
				if [ "$hvirt" -ge 1 ] || [ "$hvirt" -lt 3 ]; then
					if [ "$hvirt" = 1 ]; then
						hvirt="host"
						break
					elif [ "$hvirt" = 2 ]; then
						hvirt="Opteron_G5"
						break
					elif [ "$hvirt" = 3 ]; then
						hvirt="EPYC"
						break
					fi
				else
					echo -e "${b}Error: Invalid selection!${w}"
				fi
			done
			break
		done
		new_vm_command+=" -cpu ${hvirt}${kvm_}"
		vmr+=" -cpu ${hvirt}${kvm_}"
	
		echo -e "${b}Available virtual hardware;${w}"
		echo -e "q35,accel=kvm\npc-i440fx-2.12" | nl
		while true; do
			read -p "Enter the coresponding number to select which virtual hardware to use: " vhard
			validate_input $vhard
			if [ "$vhard" = 1 ] || [ "$vhard" = 2 ]; then
				if [ "$vhard" = 1 ]; then
					vhard="q35,accel=kvm"
					break
				elif [ "$vhard" = 2 ]; then
					vhard="pc-i440fx-2.12"
					break
				fi
			else
				echo -e "${b}Error: Invalid selection!${w}"
			fi
		done
		while true; do
			if [ "$kvm_e" = "Yes" ]; then
				read -p "Enable KVM's KSM (Kernel Same-Page Merging) feature? [Y/n]: " ksm_
				validate_input $ksm_
				if [[ "$ksm_" = [Nn] ]] || [[ "$ksm_" = ^[Nn]o$ ]]; then
					ksm_=""
					break
				elif [[ "$ksm_" = [Yy] ]] || [[ "$ksm_" = ^[Ys]es$ ]]; then
					ksm_=",mem-merge=on"
					break
				else
					echo -e "${b}Error: Invalid selection!${w}"
				fi
			fi
		done
		new_vm_command+=" -machine ${vhard}${ksm_}"
		vmr+=" -machine ${vhard}${ksm_}"
 	fi

	# Load EFI file if necessary 
	if [[ "$need_efi" == "true" ]]; then
		new_vm_command+=" -drive if=pflash,format=raw,readonly,file=$HOME/QVM/config_files/settings/QEMU_EFI_CODE.fd"
		new_vm_command+=" -drive if=pflash,format=raw,file=$HOME/QVM/config_files/settings/edk2-arm-vars.fd"
  		vmr+=" -drive if=pflash,format=raw,readonly,file=$HOME/QVM/config_files/settings/QEMU_EFI_CODE.fd"
		vmr+=" -drive if=pflash,format=raw,file=$HOME/QVM/config_files/settings/edk2-arm-vars.fd"
  	fi
 
 	# Display
	while true; do
	    echo -e "${b}Available QEMU display options:${w}"
	    echo -e "QEMU defaults\nVGA" | nl
	    read -p "Select display method (1 or 2): " display
		validate_input $display
	
	    case $display in
	        1)
	            echo -e "${b}Available display options:${w}"
	            echo -e "gtk\ncurses\ndbus\nspice\nsdl\negl-headless\ncocoa" | nl
				while true; do
		            read -p "Select display: " vm_display
					validate_input $vm_display
					if [ "$vm_display" = "1" ]; then
						vm_display="gtk"
						break
					elif [ "$vm_display" = "2" ]; then
						vm_display="curses"
						break
					elif [ "$vm_display" = "3" ]; then
						vm_display="dbus"
						break
					elif [ "$vm_display" = "4" ]; then
						vm_display="spice"
						break
					elif [ "$vm_display" = "5" ]; then
						vm_display="sdl"
						break
					elif [ "$vm_display" = "6" ]; then
						vm_display="egl-headless"
						break
					elif [ "$vm_display" = "7" ]; then
						vm_display="cocoa"
						break
					else
						echo -e "${b}Error: Invalid input!"
					fi
				done
				while true; do
					echo -e "${b}Would you like to enable OpenGL features?${w}"
		            read -p "Enable OpenGL? [Y/n]: " gl
					validate_input $gl
		            if [[ "$gl" =~ ^[YyYes]$ ]]; then
		                gl="on"
						break
		            elif [[ "$gl" =~ ^[NnNo]$ ]]; then
		                gl="off"
						break
					else
						echo ""
		            fi
				done
	
	            new_vm_command+=" -display ${vm_display},gl=${gl}"
	            vmr+=" -display ${vm_display},gl=${gl}"
				e_vga="No"
				vga="None"
				
	            break
	            ;;
	        2)
	            echo -e "${b}Available VGA drivers:${w}"
	            echo -e "virtio\ncirrus\nstd\nvmware\nqxl\ntcx\ncg3" | nl
				while true; do
	            	read -p "Select VGA driver: " vga
					validate_input $vga
					if [ "$vga" = "1" ]; then
						vga="virtio"
						break
					elif [ "$vga" = "2" ]; then
						vga="cirrus"
						break
					elif [ "$vga" = "3" ]; then
						vga="std"
						break
					elif [ "$vga" = "4" ]; then
						vga="vmware"
						break
					elif [ "$vga" = "5" ]; then
						vga="qxl"
						break
					elif [ "$vga" = "6" ]; then
						vga="tcx"
						break
					elif [ "$vga" = "7" ]; then
						vga="cg3"
						break
					else
						echo -e "${b}Error: Invalid input!${w}"
					fi
				done
		                
				new_vm_command+=" -vga ${vga}"
		        vmr+=" -vga ${vga}"
				e_vga="Yes, (Using the $vga interface)"
				
	
	            echo -e "${b}Available display options:${w}"
	            echo -e "none\ngtk\ncurses\ndbus\nspice\nsdl\negl-headless\ncocoa\nvnc" | nl
	            while true; do
					read -p "Enter graphics memory (in MB): " graph_mem
					validate_input $graph_mem
					if [[ "$graph_mem" =~ ^[0-9]+$ ]]; then
						if [ "$graph_mem" -ge 32 ] || [ "$graph_mem" -lt 512 ]; then
							break
						else
							echo -e "${b}Your graphical memory allocation is out of bounds! Must be between '${w}32-512${b}' MB.${w}"
						fi
					fi
				done
	
	            new_vm_command+=" -device VGA,vgamem_mb=${graph_mem}"
	            vmr+=" -device VGA,vgamem_mb=${graph_mem}"
	            break
	            ;;
	        *)
	            echo -e "${b}Error: Invalid entry! Please enter an interger.${w}"
	            ;;
	    esac
	done
	
	# Network
	echo -e "${b}Available network devices;${w}"
	echo -e "e1000\nvirtio-net-pci\nrtl8139\ni82559c\npcnet\ne1000-82545em" | nl
	while true; do 
		read -p "Select a network device: " ns
		validate_input $ns
		if [ "$ns" = 1 ]; then
			ns="e1000"
			break
		elif [ "$ns" = 2 ]; then
			ns="virtio-net-pci"
			break
		elif [ "$ns" = 3 ]; then
			ns="rtl8139"
			break
		elif [ "$ns" = 4 ]; then
			ns="i82559c"
			break
		elif [ "$ns" = 5 ]; then
			ns="pcnet"
			break
		elif [ "$ns" = 6 ]; then
			ns="ne1000-82545em"
			break
		else
			echo -e "${b}Error: Invalid input!${w}"
		fi
	done
	mac="50:54:00:00:54:02"
	new_vm_command+=" -netdev user,id=n1,ipv6=off"
	vmr+=" -netdev user,id=n1,ipv6=off"
	new_vm_command+=" -device ${ns},netdev=n1,mac=${mac}"
	vmr+=" -device ${ns},netdev=n1,mac=${mac}"

	# Enable Clipboard Sharing
	echo -e "${b}Would you like to enable host clipboard sharing?${w}"
	while true; do
		read -p "Enable host clipboard sharing? [Y/n]: " clipb
		validate_input $clipb
		if [ "$clipb" = "N" ] || [ "$clipb" = "n" ] || [[ "$clipb" =~ "no" ]]; then
			new_vm_command+=""
			vmr+=""
			break
		elif [ "$clipb" = "Y" ] || [ "$clipb" = "y" ] || [[ "$clipb" =~ "yes" ]]; then
			new_vm_command+=" -chardev qemu-vdagent,id=vdagent,name=vdagent,clipboard=on"
			vmr+=" -chardev qemu-vdagent,id=vdagent,name=vdagent,clipboard=on"
			new_vm_command+=" -device virtio-serial,max_ports=2"
			vmr+=" -device virtio-serial,max_ports=2"
			new_vm_command+=" -device virtserialport,chardev=vdagent,name=com.redhat.spice.0"
			vmr+=" -device virtserialport,chardev=vdagent,name=com.redhat.spice.0"
			break
		else
			echo -e "Error: Invalid input!"
		fi
	done

	while true; do
		echo -e "\n${b}Virtual machine configuration complete!${w}"
		read -p "Proceed with VM creation? [Y/n]: " ready
		if [ "$ready" = "Y" ] || [ "$ready" = "y" ] || [[ "$ready" =~ "yes" ]]; then
			break
		elif [ "$ready" = "N" ] || [ "$ready" = "n" ] || [[ "$ready" =~ "no" ]]; then
			echo -e "${b}Operation canceled!${w}"
			exit 1
		else
			echo -e "Error: Invalid input!"
		fi
	done

	# CPU resource limiting processes
#	qemu_limit="qvm_${img_nme}_limit_group"
#	sudo cgcreate -g cpu:/sys/fs/cgroup/cpu/qvm_machine/$qemu_limit
#	microseconds=100000
#	total_microseconds=$(($microseconds * $host_cpu))
#	vm_res_lim=$(echo $vm_specs | cut -d" " -f13)
#	vm_res_lim=$(($total_microseconds * $vm_res_lim / 100))
#	sudo cgset -r cpu.cfs_period_us=$microseconds /sys/fs/cgroup/cpu/$qemu_limit
#	sudo cgset -r cpu.cfs_quota_us=$vm_res_lim /sys/fs/cgroup/cpu/$qemu_limit

#	vm_command+="sudo cgexec -g cpu:/sys/fs/cgroup/cpu/$qemu_limit"
	vm_command+=" ${new_vm_command}"
	
	dt=$(date)
	vm_specs="${CPU}\""
	vm_specs+=" \"${MEM}\""
	vm_specs+=" \"${os_basename}\""
	vm_specs+=" \"${HD}\""
	vm_specs+=" \"${format}\""
	vm_specs+=" \"${kvm_e}\""
	vm_specs+=" \"${ns}\""
	vm_specs+=" \"${vm_display}\""
	vm_specs+=" \"${e_vga}\""
	vm_specs+=" \"${graph_mem}\""
	vm_specs+=" \"${dt}\""
	
	echo -e "${b}Saving ${w}$img_nme${b} VM restart command...${w}"
	echo $vmr > $HOME/QVM/config_files/vm_log_files/${img_nme}_vm_restart
	echo $vm_specs > $HOME/QVM/config_files/vm_log_files/${img_nme}_vm_specs
	echo $vm_specs
	
	# Create QEMU virtual hard drive image with qcow2 format and specified size
	echo -e -n "${b}Creating the ${w}$img_nme${b} hard drive storage ... $(qemu-img create -f $format "./../VM_Images/$img_nme.img" "${HD}G")"
	echo -e " ... done!${w}"

	# Start the newly created virtual machine
	echo -e "${b}Starting the ${w}$img_nme${b} VM..."
	echo -e "Saving your VM configuration...."
	echo -e "Opening the VM interface..."
	eval "$vm_command"
	echo -e "The ${w}$img_nme${b} VM interface closed..."
	echo -e "The ${w}$img_nme${b} virtual machine has been shut down and is no longer running!${w}\n"
else
    echo -e "${b}Starting the ${w}$img_nme${b} virtual machine. Running the mounted VM image..."
	sleep 1
	start_command=$(cat $HOME/QVM/config_files/vm_log_files/${img_nme}_vm_restart)
	echo -e "Opening the VM interface..."
	eval "$start_command"
	echo -e "The ${w}$img_nme ${b}VM interface closed..."
	echo -e "The ${w}$img_nme${b} virtual machine has been shut down and is no longer running!${w}\n"
fi
