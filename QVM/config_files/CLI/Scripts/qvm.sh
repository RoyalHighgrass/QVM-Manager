
#!/bin/bash

# Function to handle cleanup when script is interrupted
cleanup() (
  echo "Process interrupted. Returning to the main menu..."
  ./qvm-manager.sh
  exit 0
)

# Set trap
#trap cleanup SIGINT

# Get VM name
read -p "HD Image name (Leave blank to cancel): " img_nme
[ -z "$img_nme" ] && echo -e "\033[34mError: Invalid entry! Operation Cancelled.\033[0m\n" && exit 1

# Check if the image file exists
if ! find $HOME/QVM/config_files/VM_Images -type f -name "*$img_nme.img" | cut -d"/" -f6 | cut -d"." -f1 &>/dev/null; then
    echo -e "\033[34mThat virtual machine does not exist. Creating a new VM..."

	# Get VM specifications
	df -h | grep -E "Avail|kvm"
    read -p "Specify HD disk size (must be an 'int', minimum of '40' is recommended): " HD
	[ -z "$HD" ] && echo -e "Error: Invalid entry! Operation Cancelled.\n" && exit 1

	echo -e "ISO Images Found: $(find . "*.iso" | grep -c '.iso')"
	find . -type f -name "*.iso" | cut -d"/" -f3 | nl -s'. ' -w3
    read -p "OS installation disk name (provide full path if not in working dir): " os_img
	[ -z "$os_img" ] && echo -e "Error: Invalid entry! Operation Cancelled.\n" && exit 1

    # Create QEMU virtual hard drive image with qcow2 format and specified size
    qemu-img create -f qcow2 "./VM_Images/$img_nme.img" "${HD}G"

	# Start the newly created virtual machine
	echo -e "Starting the $img_nme VM..."
	echo -e "Opening the VM interface..."
	
    # Performance optimizations: Use Virtio for disk and network, enable I/O threads, and allocate CPU and memory efficiently
    qemu-system-x86_64 -enable-kvm -cdrom "./ISO_Images/$os_img" -boot menu=on \
    -drive file="$HOME/QVM/config_files/VM_Images/$img_nme.img",cache=writeback,id=drive1,format=qcow2 \
	-object iothread,id=iothread0 \
    -m 6G -cpu host,kvm=on -smp 4,sockets=4,cores=1,threads=1 \
    -vga virtio -display sdl,gl=on \
    -netdev user,id=net0 -device virtio-net-pci,netdev=net0 
else
    echo "Starting the $img_nme virtual machine. Running mounted VM image..."
	sleep 1
	echo "$img_nme is running..."
    
    # Performance optimizations: Run the VM with Virtio for disk and network, enable I/O threads, and allocate CPU and memory efficiently
    qemu-system-x86_64 -enable-kvm -boot menu=on \
    -drive file="$HOME/QVM/config_filesVM_Images/$img_nme.img",cache=writeback,id=drive1,format=qcow2 \
	-object iothread,id=iothread0 \
    -m 6G -cpu host,kvm=on -smp 4,sockets=4,cores=1,threads=1 \
    -vga virtio -display sdl,gl=on \
    -netdev user,id=net0 -device virtio-net-pci,netdev=net0
fi
