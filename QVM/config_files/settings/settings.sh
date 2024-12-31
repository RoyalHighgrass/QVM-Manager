
sudo tee /usr/bin/qvm-manager > /dev/null << 'EOF'

user_help="$HOME/QVM/help-info.txt"
QVMv1="$HOME/QVM/config_files/CLI/"
QVMv2="$HOME/QVM/config_files/GUI/"

if [[ -z "$1" ]]; then
    cd "$QVMv1"
    pwd
    ./qvm-manager.sh
else
    case "$1" in
        --gui)
            cd "$QVMv2" || exit
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
