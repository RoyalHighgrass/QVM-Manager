#!/bin/bash

b="\033[34m"
w="\033[0m"

trap 'echo -e ""' SIGINT

# VM Search Function
vm_search() {
    echo -e "VM Images Found: $(find ~/QVM/config_files/VM_Images -type f -name '*.img' | wc -l)"
    
    # Find VM image files and extract names
	vms=$(find ~/QVM/config_files/VM_Images -type f -name "*.img" | cut -d"/" -f7 | cut -d"." -f1)
	     
    # Get list of running VMs
	running_vms=$(ps aux | grep qemu-system | awk -F '/' '{print $NF}' | awk -F ".img" '{print $1}')
		    
	echo -e "VM Name:	     Status:"
		    
    # Loop through each VM and check its status
	echo "$vms" | while read -r vm; do
        if [[ "$(find ~/QVM/config_files/VM_Images -type f -name '*.img' | wc -l)" == "0" ]]; then
	        status=""
		else
			if echo "$running_vms" | grep -q "$vm"; then
	            status="Running"
	        else
	            status="Powered off"
	        fi
		fi
		printf "%-25s %s\n" "$vm"  "$status"
	done
}

# Show VM info
if [[ "$1" == "-vv" ]]; then
    echo -e "${b}Searching for VMs...\n${w}"
	vm_search
	./Scripts/view-delete-vm-gui.sh "$(vm_search)"
	exit 0
fi

echo -e "${b}Preparing to 'Create' or 'Start' a QEMU virtual machine...${w}"

vms=$(vm_search)
img_nme=$(yad --on-top --entry \
    --buttons-layout=center \
	--title "QVM-1.0.3 - Create/Start VM" \
	--text "<b>$vms</b> \n\nEnter a VM vHD Image name:") 

if [[ "$?" -ne 0 ]]; then
	exit 1
fi

trap 'killall yad zenity &>/dev/null' SIGINT
trap 'kill $img_nme &>/dev/null' SIGINT

qlog="$HOME/QVM/config_files/vm_log_files/qemu.log"

# Verify user input
if [[ -z "$img_nme" ]]; then
	if ps -e | grep qvm-manager &>/dev/null; then
		echo -e "${b}Error: Invalid entry! Operation Cancelled.${w}"
		exit 1
	else
		exit 1
	fi
fi

# Check if the VM is already running
vmrun=$(ps aux | grep qemu-system | grep ${img_nme}.img)
if ! [[ -z "$vmrun" ]]; then
	echo -e "\n${b}qvm-manager: Operation failed: That VM is already running!${w}"
	yad --width=400 --height=300 --title="QVM-v1.0.3 - Operation Failed" \
		--text="Operation failed: That VM is already running!" \
		--buttons-layout=center --on-top --button=OK:0
	exit 1
fi

# Check if the VM image file doesn't exists
if ! vm_search | grep $img_nme; then

	echo -e "${b}That virtual machine does not exists. Creating a new VM...${w}"

	# Get ISO file path
	iso_=$(yad --on-top --form --width=500 --height=100 \
		--title="Choose OS Installation Media" --buttons-layout=center \
		--text="Select the ISO image to use to create the new VM:" \
		--image="$HOME/QVM/config_files/logo_images/qemu2-2.png" \
		--field="Select Files:FL" ~/QVM/config_files/ISO_Images/cdrom)
	iso_=$(echo $iso_ | cut -d"|" -f1)
	

	if [ -z "$iso_" ] || ! [[ "$iso_" =~ \.iso$ ]]; then
	    echo "Invalid ISO file selection!"
	    exit 1
	fi

	# Get VM specifications
	host_free_space=$(df -h | grep "kvm" | cut -d"G" -f3 | sed 's/   //g')
	host_cpu=$(nproc)
	host_free_memory=$(free -h | awk '/^Mem:/ {print $4}' | sed 's/[^0-9.]//g')
	suggested_vm_memory=$(echo "scale=2; (88/100) * $host_free_memory" | bc)
	suggested_vm_memory=$(echo "$suggested_vm_memory (recommended)")

	user_settings=$(cat ~/QVM/config_files/settings/check_settings)
	msc=""
	if [[ "$user_settings" != "edited" ]]; then
	    user_settings=$(cat ~/QVM/config_files/settings/default_settings | sed 's/" "/ /g' | sed 's/"//g')
		msc+="$img_nme"
		msc+=" 2!1..${host_free_memory}!1!0" 
		msc+=" 20!1..${host_free_space}!1!0"
		msc+=" 2!1..${host_cpu}!1!0"
		msc+=" $user_settings"
		title=""
	else
		user_settings=$(cat ~/QVM/config_files/settings/user_configured_settings | sed 's/" "/ /g' | sed 's/"//g')
		msc+="$img_nme"
		msc+=" $user_settings"
		title="\nNote: These settings need to be reset before they can be properly reconfigured. To do so, go to settings and click reset."
	fi
	
	vm_specs=$(yad --on-top --width=800 --height=600 \
	    --title="QVM-1.0.3 - Create a VM" \
		--buttons-layout=center \
		--columns=2 \
		--text="New VM Specifications.$title" \
	    --image="$HOME/QVM/config_files/logo_images/qemu2-2.png" \
	    --form --separator='" "' \
		--field="VM Name: ":RO \
	    --field="Memory Allocation ($host_free_memory GB available)":NUM \
	    --field="Storage Configuration ($host_free_space GB available)":NUM \
	    --field="CPUs ($host_cpu CPUs available)":NUM \
	    --field="    Guest CPU Model":CB \
		--field="Storage Format":CB \
	    --field="Network Settings:":CB \
	    --field="    MAC Address:": \
	    --field="Hardware Virtualization":CB \
	    --field="    Virtual Hardware":CB \
	    --field="Audio Device":CB \
	    --field="    Audio Model":CB \
	    --field="Resource Limits (% of host)":NUM \
	    --field="Display":CB \
	    --field="Enable OpenGL":CB \
	    --field="Enable VGA":CB \
	    --field="    VGA Drivers":CB \
	    --field="Graphics Memory (MB)":CB \
	    --field="Enable KVM":CB \
	    --field="Enable Asynchronous Page Faults":CB \
	    --field="Enable KSM (Kernel Same-page Merging)":CB \
	    --field="Enable IOMMU (Only supported by q35)":CB \
		--field="Boot Options":CB \
		--field="Enable Host/Guest Clipboard Sharing":CB \
		$msc \
	    --button=Cancel:1 --button=Create:0)

	vm_specs=$(echo $vm_specs | sed 's/" "/ /g')
	
	# Verify user input
	[ -z "$vm_specs" ] && echo -e "${b}Error: Invalid entry! Operation Cancelled.${w}" && exit 1

	# Create QEMU virtual hard drive image with a specified format and size
	format=$(echo $vm_specs | cut -d" " -f6)	
    echo -e "Creating a $format virtual hard drive image..."
	HD=$(echo $vm_specs | cut -d" " -f3)
	qemu-img create -f "${format}" "$HOME/QVM/config_files/VM_Images/$img_nme.img" "${HD}G"

	
	# Start Command
	new_vm_command="qemu-system-x86_64"
	
	# Debug Mode
	new_vm_command+=" -d cpu_reset -d guest_errors"
	
	# Log VM with QEMU
	new_vm_command+=" -D $HOME/QVM/config_files/vm_log_files/qemu.log"

	# Enable KVM
	enable_kvm=$(echo $vm_specs | cut -d" " -f19)
	if [[ "$enable_kvm" == "Yes" ]]; then
		kvm_=",kvm=on"
		new_vm_command+=" -enable-kvm"
		kvm_e="Yes"
	else
		kvm_=""
		new_vm_command+=""
		kvm_e="No"
	fi
	vmr="$new_vm_command"

	# OS Image
	if echo $iso_ | grep cdrom; then
		echo "That ISO disk is already in the QVM cdrom & ready to use... "
	else
		echo "Placing the selected ISO disk in the QVM cdrom..."
		sudo mv "$iso_" "$HOME/QVM/config_files/ISO_Images/cdrom/"
		iso_=$(echo $iso_ | sed 's/ISO_Images/ISO_Images\/cdrom/g')
	fi
	new_vm_command+=" -cdrom ${iso_}"
	os_basename=$(basename $iso_)
	
	# Boot Options
	boot_options=$(echo $vm_specs | cut -d" " -f23)
	if [[ "$boot_options" != "Menu" ]]; then
		if [[ "$boot_options" == "Disk" ]]; then
			new_vm_command+=" -boot once=d"
			vmr+=" -boot once=d"
		else
			new_vm_command+=" -boot order=nc"
			vmr+=" -boot order=nc"
		fi
	else
		new_vm_command+=" -boot menu=on"
		vmr+=" -boot menu=on"
	fi
	
	# Storage 
	drive_id=$(( RANDOM % 1000 + 1 ))
	drive_id="drive${drive_id}"
	new_vm_command+=" -drive file=\"$HOME/QVM/config_files/VM_Images/$img_nme.img\",cache=writeback,id=$drive_id,format=${format}"
	vmr+=" -drive file=\"$HOME/QVM/config_files/VM_Images/$img_nme.img\",cache=writeback,id=$drive_id,format=${format}"
	

	# Memory
	vm_mem=$(echo $vm_specs | cut -d" " -f2)
	new_vm_command+=" -m ${vm_mem}G"
	vmr+=" -m ${vm_mem}G"

	# CPU
	vm_cpu=$(echo $vm_specs | cut -d" " -f4)
	new_vm_command+=" -smp ${vm_cpu},sockets="$vm_cpu",cores=1,threads=1 " 
	vmr+=" -smp ${vm_cpu},sockets="$vm_cpu",cores=1,threads=1 " 
	new_vm_command+=" -object iothread,id=iothread0" 
	vmr+=" -object iothread,id=iothread0" 
	
	# Hardware Virtualization
	hvirt=$(echo $vm_specs | cut -d" " -f9)
	apf=$(echo $vm_specs | cut -d" " -f20)
	new_vm_command+=" -cpu ${hvirt}${kvm_}"
	vmr+=" -cpu ${hvirt}${kvm_}"
	if [[ "$apf" == "No" ]]; then
		new_vm_command+=""
		vmr+=""
	else
		new_vm_command+=",+kvm-asyncpf-int"
		vmr+=",+kvm-asyncpf-int"
	fi

	# Display
	vm_display=$(echo $vm_specs | cut -d" " -f14)
	gl=$(echo $vm_specs | cut -d" " -f15)
	gmem=$(echo $vm_specs | cut -d" " -f18)
	if [[ "$vm_display" != "none" ]]; then
		if [[ "$gl" == "Yes" ]]; then
			gl="on"
		else
			gl="off"
		fi
		new_vm_command+=" -display ${vm_display},gl=${gl}"
		vmr+=" -display ${vm_display},gl=${gl}"
		vga="No"
		gmem="None"
	else
		# VGA
		vga=$(echo $vm_specs | cut -d" " -f16)
		if [[ "$vga" == "Yes" ]]; then
			vgad=$(echo $vm_specs | cut -d" " -f17)
			new_vm_command+=" -vga ${vgad}"
			vmr+=" -vga ${vgad}"
			vga="Yes, (Using $vgad)"
		else
			new_vm_command+=""
			vmr+=""
		fi
		new_vm_command+=" -device VGA,vgamem_mb=${gmem}"
		vmr+=" -device VGA,vgamem_mb=${gmem}"
	fi
	
	# Network
	ns=$(echo $vm_specs | cut -d" " -f7)
	mac=$(echo $vm_specs | cut -d" " -f8)
	new_vm_command+=" -netdev user,id=n1,ipv6=off"
	vmr+=" -netdev user,id=n1,ipv6=off"
	new_vm_command+=" -device ${ns},netdev=n1,mac=${mac}"
	vmr+=" -device ${ns},netdev=n1,mac=${mac}"

	# Virtual Hardware
	vhard=$(echo $vm_specs | cut -d" " -f10)
	ksm_=$(echo $vm_specs | cut -d" " -f21)
	if [[ "$ksm_" == "No" ]]; then
		ksm_=""
		irqc=""
	else
		ksm_=",mem-merge=on"
#		if [[ "" == "" ]]; then
#			irqc=",kernel-irqchip=off"
#		fi
	fi
	new_vm_command+=" -machine ${vhard}${ksm_}${irqc}"
	vmr+=" -machine ${vhard}${ksm_}${irqc}"

	# Enable Clipboard Sharing
	clipb=$(echo $vm_specs | cut -d" " -f24)
	if [[ "$clipb" == "No" ]]; then
		new_vm_command+=""
		vmr+=""
	else
		new_vm_command+=" -chardev qemu-vdagent,id=vdagent,name=vdagent,clipboard=on"
		vmr+=" -chardev qemu-vdagent,id=vdagent,name=vdagent,clipboard=on"
		new_vm_command+=" -device virtio-serial,max_ports=2"
		vmr+=" -device virtio-serial,max_ports=2"
		new_vm_command+=" -device virtserialport,chardev=vdagent,name=com.redhat.spice.0"
		vmr+=" -device virtserialport,chardev=vdagent,name=com.redhat.spice.0"
	fi

	# IOMMU 
	clipb=$(echo $vm_specs | cut -d" " -f22)
	if [[ "$clipb" == "No" ]]; then
		new_vm_command+=""
		vmr+=""
	else
		new_vm_command+=" -device intel-iommu,intremap=on,device-iotlb=on"
		vmr+=" -device intel-iommu,intremap=on,device-iotlb=on"
	fi

	# CPU resource limiting processes
	qemu_limit="qvm_${img_nme}_limit_group"
	
#	sudo cgcreate -g cpu:/sys/fs/cgroup/cpu/qvm_machine/$qemu_limit
	
	microseconds=100000
	total_microseconds=$(($microseconds * $host_cpu))
	vm_res_lim=$(echo $vm_specs | cut -d" " -f13)
	vm_res_lim=$(($total_microseconds * $vm_res_lim / 100))

#	sudo cgset -r cpu.cfs_period_us=$microseconds /sys/fs/cgroup/cpu/$qemu_limit
#	sudo cgset -r cpu.cfs_quota_us=$vm_res_lim /sys/fs/cgroup/cpu/$qemu_limit
	
#	vm_command+="sudo cgexec -g cpu:/sys/fs/cgroup/cpu/$qemu_limit"
	vm_command+=" ${new_vm_command}"
	
	dt=$(date)
	
	vm_specs="${vm_cpu}\""
	vm_specs+=" \"${vm_mem}\""
	vm_specs+=" \"${os_basename}\""
	vm_specs+=" \"${HD}\""
	vm_specs+=" \"${format}\""
	vm_specs+=" \"${kvm_e}\""
	vm_specs+=" \"${ns}\""
	vm_specs+=" \"${vm_display}\""
	vm_specs+=" \"${vga}\""
	vm_specs+=" \"${gmem}\""
	vm_specs+=" \"${dt}\""
	
	echo -e "${b}Saving ${w}$img_nme${b} VM restart command...${w}"
	echo $vmr > $HOME/QVM/config_files/vm_log_files/${img_nme}_vm_restart
	echo -e "${b}Saving ${w}$img_nme${b} VM specs...${w}"
	echo $vm_specs > $HOME/QVM/config_files/vm_log_files/${img_nme}_vm_specs
	echo $vm_specs
	
	# Start the newly created virtual machine
	echo -e "Starting the $img_nme VM..."
	echo -e "Saving your VM configuration...."
	echo -e "Opening the VM interface..."

	eval "$vm_command" & 
	pid="$!"
	echo "VM: $img_nme    Created: $(date)    Status: running    PID: $pid" >> $HOME/QVM/config_files/vm_log_files/qlog
#	echo $! | tee -a $qlog

	echo -e "$img_nme VM interface closed..."
	echo -e "The $img_nme virtual machine has been shut down and is no longer running!\n"
else
	if vm_search | grep $img_nme | grep off; then
		echo -e "Retrieving $img_nme VM configuration data..."
		vm_specs=$(cat $HOME/QVM/config_files/vm_log_files/${img_nme}_vm_restart)
	    echo "The $img_nme virtual machine will now start! Running mounted VM image..."
		echo -e "Launching the VM interface..."
	
		eval "$vm_specs"
	
		echo -e "$img_nme VM interface closed..."
		echo -e "The $img_nme virtual machine has been shut down and is no longer running!\n"
	else
		echo -e "The $img_nme VM is already running..."
	fi
fi
