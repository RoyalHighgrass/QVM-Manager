#!/bin/bash

echo "Installing basic required for QVM setup..."

if [[ "$(whoami)" != "root" ]]; then
	zenity --info --title="QVM v1.0.3" \
	--text="QEMU Virtual Machine Manager v1.0.3\n\nYou are trying to run the QVM configuration script as a non-privilaged user.\nThis script must be run as root! Run 'sudo ./config.sh' or './config.sh' after running the 'sudo su' command." \
	--width=600 --height=400 --timeout=8
else
	sudo apt install wget tree cut find locate zenity wmctrl make cpu-checker intltool autoconf \
 		gtk-layer-shell-doc gtk4-layer-shell-doc libgtk-3-common libgtk-4-common libgtk-3-0t64 \
   		libgtk-3-dev acpi bc tr xrandr cgroup-tools libvirt-clients libvirt-daemon-system bridge-utils \
     		virtinst libvirt-daemon qemu-kvm qemu-system-common qemu-system-x86 qemu-system-modules-opengl \
       		mgba-sdl libsdl2-2.0-0 libsdl2-net-2.0-0 mednafen -y
	original-awk 2024-06-23-1
	mawk 1.3.4.20240905-1
	gawk 1:5.2.1-2+b1
 	

 	# Ensure necessary folders exist for CPU resource limiting processes
	sudo mkdir -p /sys/fs/cgroup/cpu/qvm_machine
	sudo mkdir -p /sys/fs/cgroup/cpuset/qvm_machine
	sudo mkdir -p /sys/fs/cgroup/memory/qvm_machine
	sudo mkdir -p $HOME/QVM/config\ files/vm\ log\ files

	# Install YAD
	cd /tmp/
	git clone https://github.com/v1cont/yad.git
	cd yad/
	autoreconf -ivf && intltoolize --force
fi

# Setup the QVM filesystem & copy in the necessary QVM files
sudo mkdir $HOME/QVM
sudo cp README.md/ $HOME/QVM/
sudo cp QVM/* $HOME/QVM/
sudo mkdir $HOME/QVM/config_files/ISO_Images/
sudo mkdir $HOME/QVM/config_files/ISO_Images/cdrom
sudo mkdir $HOME/QVM/config_files/VM_Images/
sudo mkdir $HOME/QVM/config_files/vm_log_files/

# Create the /usr/bin/ instance & initialise the 'qvm-manager' startup command
sudo tee /usr/bin/qvm-manager > /dev/null << 'EOF'

user_manual="$HOME/QVM/help-info.txt"
QVMcli="$HOME/QVM/config_files/CLI/"
QVMgui="$HOME/QVM/config_files/GUI/"

if [[ -z "$1" ]]; then
    cd "$QVMcli"
    ./qvm-manager.sh
else
    case "$1" in
        --gui)
            cd "$QVMgui" || exit
            ./qvm-manager-gui.sh
            ;;
        --help|-h)
            echo -e "$(cat "$user_manual")"
            ;;
        --version|-v)
            echo -e "QEMU Virtual Machine Manager v1.0.3 © QVM 2024"
            ;;
        *)
            echo "Invalid option: $1"
            ;;
    esac
fi

EOF

sudo chmod +x /usr/bin/qvm-manager
