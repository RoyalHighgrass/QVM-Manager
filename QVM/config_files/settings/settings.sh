mkdir $HOME/QVM
sudo cp README.md/ $HOME/QVM/
sudo cp QVM/* $HOME/QVM/
mkdir $HOME/QVM/config_files/ISO_Images/
mkdir $HOME/QVM/config_files/ISO_Images/cdrom
mkdir $HOME/QVM/config_files/VM_Images/
mkdir $HOME/QVM/config_files/vm_log_files/
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
