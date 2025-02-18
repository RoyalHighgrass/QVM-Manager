#!/bin/bash

# Function to get CPU threads
get_cpu_threads() {
    nproc
}

# Function to get memory usage
get_memory_usage() {
    free -h | awk '/^Mem:/ {print $3 " of " $2 " used"}'
}

# Function to get disk space
get_disk_space() {
    df -h --output=source,size,used,avail,pcent / | tail -n 1 | awk '{print $2 " total, " $4 " available (" $5 " used)"}'
}

# Function to check KVM support
check_kvm_support() {
	if kvm-ok | grep -q "/dev/kvm"; then
		kvm-ok | grep used
	elif kvm-ok | grep -q -E "VT|Virtualization|BIOS"; then
		echo -e "Your CPU supports KVM,\nbut it's disabled in the BIOS:\nINFO: Your CPU supports KVM extensions\nINFO: KVM (vmx) is disabled by your BIOS\nHINT: Enter your BIOS setup and enable Virtualization Technology (VT), and then hard poweroff/poweron your system\nKVM acceleration can NOT be used"
    else
		echo "KVM acceleration can NOT be used"
	fi
}

# Function to get network interfaces
get_network_interfaces() {
	ifconfig | grep BROA | cut -d: -f1 2>/dev/null || ip addr | grep BROA | awk -F": " '{print $2}'
}

check_qemu() {
	echo -e "Version: $(qemu-system-x86_64 --version | head -n 1 | awk -F" " '{print $6}' | sed 's/)//g')"
}

check_opengl() {
	echo -e "$(dpkg -s libopengl-dev | grep Vers)"
}

check_libvirt() {
	echo -e "Version: $(libvirtd --version | awk -F" " '{print $3}')"
}

check_vga() {
	basename $(locate .so | grep -E "vga|gl" | grep vga)
}

check_mgba() {
	mgba system.version
}

check_mednafen() {
	echo -e "$(dpkg -s mednafen | grep Vers)"
}

check_gtk() {
	echo ""
}

check_zenity() {
	echo -e "$(dpkg -s zenity | grep Vers)"
}

check_yad() {
	echo -e "$(yad --version)"
}

credit() { cat << 'EOF'
------------------------------------------------------------------------
===============> 01010001 01010110 01001101 10101001 <==================
------------------------------------------------------------------------
     __  __   __   _,      __  _,        
    / _ \\ \ / / \/ | ___ |  \/ | __ _  _ ___  __ _  __ _  __   _ _     
   ( (_) |\ \ / |\/ ||___|| |\/ || _` || `/\ || _` || _` || -_)| `_|    
    \__\_\ \_/|_| |_|     |_| |_|\__,_||_| |_|\__,_|\__, |\___||_|  ©   
                                                    |____/              
------------------------------------------------------------------------
==============> QEMU Virtual Machine Manager v1.0.2©2024 <==============
------------------------- --- GUI Interface ----------------------------

EOF
}

# Main YAD dialog
yad --width=500 \
	--title="System Information" \
    --text="<b>System Information</b>" \
    --form --on-top \
    --field="QEMU":RO "$(check_qemu)" \
    --field="OpenGL":RO "$(check_opengl)" \
    --field="CPU's":RO "$(get_cpu_threads) Available" \
    --field="Memory Usage":RO "$(get_memory_usage)" \
    --field="Disk Space":RO "$(get_disk_space)" \
    --field="KVM Support":RO "$(check_kvm_support)" \
    --field="Libvirt":RO "$(check_libvirt)" \
    --field="VGA":RO "$(check_vga)" \
    --field="Network Interfaces":RO "$(get_network_interfaces)" \
    --field="mednafen":RO "$(check_mednafen)" \
    --field="GTK":RO "$(check_gtk)" \
    --field="Zenity":RO "$(check_zenity)" \
    --field="YAD":RO "$(check_yad)" \
    --buttons-layout=center \
    --button="Clear Terminal":0 --button="Close":1

if [ "$?" = 0 ]; then
	clear
	credit
fi
exit 0


#    --field="mGBA":RO "$(check_mgba)" \

