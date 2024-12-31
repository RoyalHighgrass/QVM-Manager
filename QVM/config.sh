#!/bin/bash

echo "Installing basic required for QVM setup..."

if [[ "$(whoami)" != "root" ]]; then
	zenity --info --title="QVM v1.0.3" \
	--text="QEMU Virtual Machine Manager v1.0.3\n\nYou are trying to run the QVM configuration script as a non-privilaged user.\nThis script must be run as root! Run 'sudo ./config.sh' or './config.sh' after running the 'sudo su' command" \
	--width=600 --height=400 --timeout=8
else
	sudo apt install 
 	exit 1
	
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

user_help="$HOME/QVM/help-info.txt"
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
            echo -e "$(cat "$user_help")"
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
