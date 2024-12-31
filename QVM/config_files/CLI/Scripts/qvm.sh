#!/bin/bash

# Function to handle cleanup when script is interrupted
#cleanup() (
#  echo "Process interrupted. Returning to the main menu..."
#  ./qvm-manager.sh
#  exit 0
#)

# Set trap
#trap cleanup SIGINT

# Get VM name
echo ""
read -p "HD Image name (Leave blank to cancel): " img_nme
[ -z "$img_nme" ] && echo -e "\033[34mError: Invalid entry! Operation Cancelled.\033[0m\n" && exit 1

# Check if the image file exists
vm_exists=$(find $HOME -type f -name '*.img' | grep $img_nme)
if [[ -z "$vm_exists" ]]; then
    echo -e "\033[34mThat virtual machine does not exist. Creating a new VM..."

	# Start Command
	new_vm_command="qemu-system-x86_64"
	
	# Get new VM specifications #

	# Storage
	df -h | grep -E "Avail|kvm"
	host_storage=$(df -h | grep "kvm")
	available_host_storage=$(echo $host_storage | awk '{print $4}' | cut -dG -f1)
	echo -e -n "\033[0m"
    while true; do
		read -p "Specify HD disk size (must be an 'int', minimum of '20-30' is recommended): " HD
		if [[ "$HD" =~ ^[0-9]+$ ]]; then
	        if [[ "$HD" -ge 15 || "$HD" -lt $available_host_storage ]]; then
				break
	        else
	            if [ "$HD" -le 6 ]; then 
					echo "Error: Host storage is almost completely full. It is recommendeded that you backup important data immediately!"
				else
					echo "Error: Size must be at least 15 & not more than ${available_host_storage}!"
				fi
	        fi
		else
	        echo "Error: Invalid input. Please enter an integer."
		fi
	done
	
	# Storage format
	echo -e "\033[34mAvailable storage formats;\033[0m"
	echo -e "qcow2\nraw\nvdi\nvmdk\nvhd" | nl
    while true; do 
		read -p "Specify HD disk format ('qcow2' recommended): " format
		if [[ "$format" == "1" ]]; then
			format="qcow2"
			break
		elif [[ "$format" == "2" ]]; then
			format="raw"
			break
		elif [[ "$format" == "3" ]]; then
			format="vdi"
			break
		elif [[ "$format" == "4" ]]; then
			format="vmdk"
			break
		elif [[ "$format" == "5" ]]; then
			format="vhd"
			break
		else
			echo -e "Error: Invailid option!"
		fi
	done
	new_vm_command+=" -drive file=\"$HOME/QVM/config_files/VM_Images/$img_nme.img\",cache=writeback,id=drive1,format=${format}"
	vmr+=" -drive file=\"$HOME/QVM/config_files/VM_Images/$img_nme.img\",cache=writeback,id=drive1,format=${format}"
	
	# CPU
	echo -e "\033[34mYour system has '\033[0m$(nproc)\033[34m' CPU's available\033[0m"
	while true; do
		read -p "How many host CPU's should be used?: " CPU
		if [[ "$CPU" =~ ^[0-9]+$ ]]; then
	        if [[ "$CPU" -ge 1 || "$CPU" -lt $(nproc) ]]; then
				break
			else
				echo "Invalid Entry: You're selection must be between 1 & $(nproc)!"
			fi
		else
			echo ""
		fi
	done
	new_vm_command+=" -smp ${CPU},sockets="$CPU",cores=1,threads=1 " 
	vmr+=" -smp ${CPU},sockets="$CPU",cores=1,threads=1 " 
	new_vm_command+=" -object iothread,id=iothread0" 
	vmr+=" -object iothread,id=iothread0" 
	vm_specs="${CPU}\""
	
	# Memory
	host_free_memory=$(free -h | awk '/^Mem:/ {print $4}' | sed 's/[^0-9.]//g')
	recommd=$(echo $host_free_memory | bc | cut -d. -f1)
	echo -e "\033[34mThere is '\033[0m${host_free_memory}\033[34m' GB of available host memory, minimum of '\033[0m2-4\033[34m' GB (recommended)\033[0m"
	while true; do
		read -p "How much of the hosts memory should be used? (Must be an 'int'): " MEM
		if [[ "$MEM" =~ ^[0-9]+$ ]]; then
	        if [[ "$MEM" -ge 2 || "$MEM" -lt $recommd ]]; then
				break
			else
				echo "Invalid Entry: You're entry must be between 2 & $recommd!"
			fi
		else
			if [[ "$MEM" -lt 1 ]]; then
				echo "You have not allocated enough memory to create an efficient virtual machine. Please allocate more memory!"
			else
				echo "Error: Invalid entry!"
			fi
		fi
	done
	vm_specs+=" \"${MEM}\""
	
	# Audio Drivers
	echo -e "\033[34mAvailable audio drivers;\033[0m"
	echo -e "none\nPulseAudio\nALSA\nOSS\nsdl\nCoreAudio\nPipeWire\nSpice" | nl
	while true; do
		read -p "Enter a number between 1-8 to select an Audio driver: " AUD
		if [[ $AUD -ge 0 || $AUD -lt 8 ]]; then
			if [[ "$AUD" == "1" ]]; then
				AUD="none"
				break
			elif [[ "$AUD" == "2" ]]; then
				AUD="pa"
				break
			elif [[ "$AUD" == "3" ]]; then
				AUD="alsa"
				break
			elif [[ "$AUD" == "4" ]]; then
				AUD="oss"
				break
			elif [[ "$AUD" == "5" ]]; then
				AUD="sdl"
				break
			elif [[ "$AUD" == "6" ]]; then
				AUD="coreaudio"
				break
			elif [[ "$AUD" == "7" ]]; then
				AUD="pipewire"
				break
			elif [[ "$AUD" == "8" ]]; then
				AUD="spice"
				break
			fi
		else
			echo invalid!
		fi
	done
	
	# Audio Driver Models
	echo -e "\033[34mAvailable audio drivers models;\033[0m"
	echo -e "none\nac97\nadlib\ncs43221a\nes1370\nhda\nsb16" | nl
	while true; do
		read -p "Enter a number between 1-7 to select an Audio driver: " AUDM
		if [[ $AUDM -ge 0 || $AUDM -lt 7 ]]; then
			if [[ "$AUDM" == "1" ]]; then
				AUDM="none"
				break
			elif [[ "$AUDM" == "2" ]]; then
				AUDM="ac97"
				break
			elif [[ "$AUDM" == "3" ]]; then
				AUDM="adlib"
				break
			elif [[ "$AUDM" == "4" ]]; then
				AUDM="cs43221a"
				break
			elif [[ "$AUDM" == "5" ]]; then
				AUDM="nes1370"
				break
			elif [[ "$AUDM" == "6" ]]; then
				AUDM="hda"
				break
			elif [[ "$AUDM" == "7" ]]; then
				AUDM="sb16"
				break
			fi
		else
			echo invalid!
		fi
	done
	
		# TODO
	new_vm_command+=""
	
	# Enable Debug Mode
	new_vm_command+=" -d cpu_reset -d guest_errors"
	
	# Log VM with QEMU
	new_vm_command+=" -D $HOME/QVM/config_files/vm_log_files/qemu.log"

	# Enable KVM
	vt_support=$(lscpu | grep -E "Virt|Hyp" | grep -E "KVM|full|VT-x|AMD-V")
	if ! [[ "$vt_support" =~ "KVM" ]]; then
		echo "It looks like your system doesn't support hardware virtualization so KVM cannot be enabled!"
		vt_support="0"
		break
	else
		while true; do
			read -p "Enable KVM? [Y/n]: " enable_kvm
			if [[ "$enable_kvm" == "Y" || "$enable_kvm" == "y" || "$enable_kvm" =~ "yes" ]]; then
				kvm_=",kvm=on"
				new_vm_command+=" -enable-kvm"
				kvm_e="Yes"
				break
			elif [[ "$enable_kvm" == "N" || "$enable_kvm" == "n" || "$enable_kvm" =~ "no" ]]; then
				kvm_=""
				new_vm_command+=""
				kvm_e="No"
				break
			else
				echo "Error: Invalid entry!"
			fi
		done
		vt_support="1"
	fi
	vmr="$new_vm_command"

	# OS Image
	echo -e "\033[34mAvailable ISO Images;\033[0m"
	find $HOME/QVM/ -type f -name "*.iso" -print0 | xargs -0 basename -s .iso -a | nl -s ". "
	while true; do 
		read -p "Enter the coresponding number to select an ISO image: " p_iso
		if [[ "$p_iso" =~ ^[0-9]+$ ]]; then
			iso_=$(find $HOME -type f -name "*.iso" | nl -s ". " | sed -n "${p_iso}p" | awk '{print $2}')
			break
		else
			echo "Error: Invalid selection!"
		fi
	done
	if echo $iso_ | grep cdrom; then
		echo "That ISO disk is already in the QVM cdrom & ready to use... "
	else
		echo "Placing the selected ISO disk in the QVM cdrom..."
		sudo mv "$iso_" "$HOME/QVM/config_files/ISO_Images/cdrom/"
		iso_=$(echo $iso_ | sed 's/ISO_Images/ISO_Images\/cdrom/g')
	fi
	new_vm_command+=" -cdrom ${iso_}"
	os_basename=$(echo $iso_ | xargs -0 basename -s .iso -a)
	vm_specs+=" \"${os_basename}\""
	vm_specs+=" \"${HD}\""
	vm_specs+=" \"${format}\""
	vm_specs+=" \"${kvm_e}\""
	
	# Boot Options
	echo -e "\033[34mAvailable boot options;\033[0m"
	echo -e "once=d\nmenu=on\norder=nc" | nl
	while true; do
		read -p "Enter a number between 1-3 to select a boot option: " boot_options
		if [[ "$boot_options" == 1 || "$boot_options" == 3 ]]; then
			if [[ "$boot_options" == 1 ]]; then
				new_vm_command+=" -boot once=d"
				vmr+=" -boot once=d"
				break
			else
				new_vm_command+=" -boot order=nc"
				vmr+=" -boot order=nc"
				break
			fi
		else
			if [[ "$boot_options" == 2 ]]; then
				new_vm_command+=" -boot menu=on"
				vmr+=" -boot menu=on"
				break
			else
				echo "Error: Invalid entry!"
			fi
		fi
	done
	echo $boot_options

	# Memory
	new_vm_command+=" -m ${MEM}G"
	vmr+=" -m ${MEM}G"

	# Hardware Virtualization & Virtual Hardware
	if [[ "$vt_support" == "1" ]]; then 
		echo -e "\033[34mAvailable hardware virtualisation options;\033[0m"
		echo -e "host\nOpteron_G5\nEPYC" | nl
		while true; do
			while true; do
				read -p "Enter a number between 1-3 to select your hardware virtualisation solution: " hvirt
				if [[ "$hvirt" -ge 1 || "$hvirt" -lt 3 ]]; then
					if [[ "$hvirt" == 1 ]]; then
						hvirt="host"
						break
					elif [[ "$hvirt" == 2 ]]; then
						hvirt="Opteron_G5"
						break
					elif [[ "$hvirt" == 3 ]]; then
						hvirt="EPYC"
						break
					fi
				else
					echo "Error: Invalid selection!"
				fi
			done
			break
		done
		new_vm_command+=" -cpu ${hvirt}${kvm_}"
		vmr+=" -cpu ${hvirt}${kvm_}"
	
		echo -e "\033[34mAvailable virtual hardware;\033[0m"
		echo -e "q35,accel=kvm\npc-i440fx-2.12" | nl
		while true; do
			read -p "Enter the coresponding number to select which virtual hardware to use: " vhard
			if [[ "$vhard" == 1 || "$vhard" == 2 ]]; then
				if [[ "$vhard" == 1 ]]; then
					vhard="q35,accel=kvm"
					break
				elif [[ "$vhard" == 2 ]]; then
					vhard="pc-i440fx-2.12"
					break
				fi
			else
				echo "Error: Invalid selection!"
			fi
		done
		while true; do
			read -p "Enable KVM's KSM (Kernel Same-Page Merging) feature? [Y/n]: " ksm_
			if [[ "$ksm_" == "N" || "$ksm_" == "n" || "$ksm_" =~ "no" ]]; then
				ksm_=""
				break
			elif [[ "$ksm_" == "Y" || "$ksm_" == "y" || "$ksm_" =~ "yes" ]]; then
				ksm_=",mem-merge=on"
				break
			else
				echo "Error: Invalid selection!"
			fi
		done
		new_vm_command+=" -machine ${vhard}${ksm_}"
		vmr+=" -machine ${vhard}${ksm_}"
	fi

	# Display
	while true; do
	    echo -e "\033[34mAvailable QEMU display options:\033[0m"
	    echo -e "QEMU defaults\nVGA" | nl
	    read -p "Select display method (1 or 2): " display
	
	    case $display in
	        1)
	            echo -e "\033[34mAvailable display options:\033[0m"
	            echo -e "gtk\ncurses\ndbus\nspice\nsdl\negl-headless\ncocoa" | nl
				while true; do
		            read -p "Select display: " vm_display
					if [[ "$vm_display" == "1" ]]; then
						vm_display="gtk"
						break
					elif [[ "$vm_display" == "2" ]]; then
						vm_display="curses"
						break
					elif [[ "$vm_display" == "3" ]]; then
						vm_display="dbus"
						break
					elif [[ "$vm_display" == "4" ]]; then
						vm_display="spice"
						break
					elif [[ "$vm_display" == "5" ]]; then
						vm_display="sdl"
						break
					elif [[ "$vm_display" == "6" ]]; then
						vm_display="egl-headless"
						break
					elif [[ "$vm_display" == "7" ]]; then
						vm_display="cocoa"
						break
					else
						echo invalid!
					fi
				done
				while true; do
					echo "Would you like to enable OpenGL features?"
		            read -p "Enable OpenGL? [Y/n]: " gl
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
	            break
	            ;;
	        2)
	            echo -e "\033[34mAvailable VGA drivers:\033[0m"
	            echo -e "virtio\ncirrus\nstd\nvmware\nqxl\ntcx\ncg3" | nl
				while true; do
	            	read -p "Select VGA driver: " vga
					if [[ "$vga" == "1" ]]; then
						vga="virtio"
						break
					elif [[ "$vga" == "2" ]]; then
						vga="cirrus"
						break
					elif [[ "$vga" == "3" ]]; then
						vga="std"
						break
					elif [[ "$vga" == "4" ]]; then
						vga="vmware"
						break
					elif [[ "$vga" == "5" ]]; then
						vga="qxl"
						break
					elif [[ "$vga" == "6" ]]; then
						vga="tcx"
						break
					elif [[ "$vga" == "7" ]]; then
						vga="cg3"
						break
					else
						echo invalid!
					fi
				done
		                
				new_vm_command+=" -vga ${vga}"
		        vmr+=" -vga ${vga}"
	
	            echo -e "\033[34mAvailable display options:\033[0m"
	            echo -e "none\ngtk\ncurses\ndbus\nspice\nsdl\negl-headless\ncocoa\nvnc" | nl
	            while true; do
					read -p "Enter graphics memory (in MB): " graph_mem
					if [[ "$graph_mem" =~ ^[0-9]+$ ]]; then
						if [[ "$graph_mem" -ge 32 || "$graph_mem" -lt 512 ]]; then
							break
						else
							echo "Your graphical memory allocation is out of bounds! Must be between '32-512' MB."
						fi
					fi
				done
	
	            new_vm_command+=" -device VGA,vgamem_mb=${graph_mem}"
	            vmr+=" -device VGA,vgamem_mb=${graph_mem}"
	            break
	            ;;
	        *)
	            echo "Error: Invalid entry! Please enter an interger."
	            ;;
	    esac
	done
	
	# Network
	echo -e "\033[34mAvailable network devices;\033[0m"
	echo -e "e1000\nvirtio-net-pci\nrtl8139\ni82559c\npcnet\ne1000-82545em" | nl
	while true; do 
		read -p "Select a network device: " ns
		if [[ "$ns" == 1 ]]; then
			ns="e1000"
			break
		elif [[ "$ns" == 2 ]]; then
			ns="virtio-net-pci"
			break
		elif [[ "$ns" == 3 ]]; then
			ns="rtl8139"
			break
		elif [[ "$ns" == 4 ]]; then
			ns="i82559c"
			break
		elif [[ "$ns" == 5 ]]; then
			ns="pcnet"
			break
		elif [[ "$ns" == 6 ]]; then
			ns="ne1000-82545em"
			break
		else
			echo invalid!
		fi
	done
	mac="50:54:00:00:54:02"
	new_vm_command+=" -netdev user,id=n1,ipv6=off"
	vmr+=" -netdev user,id=n1,ipv6=off"
	new_vm_command+=" -device ${ns},netdev=n1,mac=${mac}"
	vmr+=" -device ${ns},netdev=n1,mac=${mac}"
	vm_specs+=" \"${ns}"

	# Enable Clipboard Sharing
	echo "Would you like to enable host clipboard sharing?"
	while true; do
		read -p "Enable host clipboard sharing? [Y/n]: " clipb
		if [[ "$clipb" == "N" || "$clipb" == "n" || "$clipb" =~ "no" ]]; then
			new_vm_command+=""
			vmr+=""
			break
		elif [[ "$clipb" == "Y" || "$clipb" == "y" || "$clipb" =~ "yes" ]]; then
			new_vm_command+=" -chardev qemu-vdagent,id=vdagent,name=vdagent,clipboard=on"
			vmr+=" -chardev qemu-vdagent,id=vdagent,name=vdagent,clipboard=on"
			new_vm_command+=" -device virtio-serial,max_ports=2"
			vmr+=" -device virtio-serial,max_ports=2"
			new_vm_command+=" -device virtserialport,chardev=vdagent,name=com.redhat.spice.0"
			vmr+=" -device virtserialport,chardev=vdagent,name=com.redhat.spice.0"
			break
		else
			echo ""
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
	echo -e "\033[34mSaving \033[0m$img_nme\033[34m VM restart command...\033[0m"
	echo $vmr > $HOME/QVM/config_files/vm_log_files/${img_nme}_vm_restart
	echo $vm_specs > $HOME/QVM/config_files/vm_log_files/${img_nme}_vm_specs
	echo $vm_specs
	
	# Create QEMU virtual hard drive image with qcow2 format and specified size
	echo -e "\033[34mCreate the \033[0m$img_nme\033[34m hard drive..."
    qemu-img create -f $format "./../VM_Images/$img_nme.img" "${HD}G"

	# Start the newly created virtual machine
	echo -e "Starting the $img_nme VM..."
	echo -e "Saving your VM configuration...."
	echo -e "Opening the VM interface..."
	eval "$vm_command"
	echo -e "$img_nme VM interface closed..."
	echo -e "The $img_nme virtual machine has been shut down and is no longer running!\n"
else
    echo -e "\033[34mStarting the\033[0m $img_nme \033[34mvirtual machine. Running mounted VM image..."
	sleep 1
	start_command=$(cat $HOME/QVM/config_files/vm_log_files/${img_nme}_vm_specs)
	echo -e "Opening the VM interface..."
	eval "$start_command"
	echo -e "\033[0m$img_nme \033[34mVM interface closed..."
	echo -e "The \033[0m$img_nme\033[34m virtual machine has been shut down and is no longer running!\033[0m\n"
fi
