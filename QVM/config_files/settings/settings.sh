#!/bin/bash

b="\033[34m"
w="\033[0m"
host_free_space=$(df -h | grep "kvm" | cut -d"G" -f3 | sed 's/   //g')
host_cpu=$(nproc)
host_free_memory=$(free -h | awk '/^Mem:/ {print $4}' | sed 's/[^0-9.]//g')
suggested_vm_memory=$(echo "scale=2; (88/100) * $host_free_memory" | bc)
suggested_vm_memory=$(echo "$suggested_vm_memory (recommended)")

user_settings=$(cat ~/QVM/config_files/settings/check_settings)
msc=""
if [ "$user_settings" != "edited" ]; then
    user_settings=$(cat ~/QVM/config_files/settings/default_settings | sed 's/" "/ /g' | sed 's/"//g')
	msc+="2!1..${host_free_memory}!1!0" 
	msc+=" 20!1..${host_free_space}!1!0"
	msc+=" 2!1..${host_cpu}!1!0"
	msc+=" $user_settings"
    default="--button=Cancel:1 --button=Save:0"
	title=""
else
	user_settings=$(cat ~/QVM/config_files/settings/user_configured_settings | sed 's/" "/ /g' | sed 's/"//g')
    default="--button=Cancel:1 --button=Save:0 --button=Reset:2"
	msc+="$user_settings"
	title="\nNote: These settings need to be reset before they can be reconfigured."
fi

vm_specs=$(yad --width=800 --height=600 \
	--on-top \
    --title="QVM-1.0.3 - Settings" \
	--columns=2 \
	--text="Changes made here will apply to all new VMs you create. Existing VMs will not be affected.$title" \
    --image="$HOME/QVM/config_files/logo_images/qvm-2.png" \
    --form --separator='" "' \
    --buttons-layout=center \
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
	$default)

case $? in
	0)	# Save VM template faster VM 
		echo -e "${b}Saving your virtual machine configuration...${w}"
		echo "${b}$vm_specs${w}" | tee ~/QVM/config_files/settings/user_configured_settings
		echo edited > ~/QVM/config_files/settings/check_settings
		echo -e "${b}done!${w}"
    ;;
    1)	exit 1
	;;
	2)	# Reset setting to default
		echo -e "${b}Restoring the default configuration...${w}"
		echo default > ~/QVM/config_files/settings/check_settings
		echo "" | tee ~/QVM/config_files/settings/user_configured_settings
		echo "${b}Your QVM settings have been reset to its default configuration!${w}"
	;;
    -1)	echo "${b}qvm-mqnqger: An unexpected error has occurred...${w}"
    ;;
esac

exit 0

