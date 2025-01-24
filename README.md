# QVM-Manager (QEMU Virtual Machine Manager)

![Description](QVM/config_files/logo_images/qvm-4.png)

# QVM Manager - v1.0.3 © 2024 P.H.

## Table of Contents

1. [Project Overview](#overview)
2. [Features](#features)
3. [Installation Guide](#installation)
4. [Requirements](#requirements)
5. [Usage](#usage)
6. [Configuration](#configuration)
7. [Contributing](#contributing)
9. [License](#license)

## Overview

This project implements a Type 2 hypervisor for Linux-based `x86_64` systems using `QEMU (Quick Emulator)` written in `Bash`. `QVM` is designed to facilitate the effecient use of QEMU which is a generic and open-source machine emulator and virtualizer that allows guest operating systems to run as an application on top of an existing operating system. This implementation focuses on providing a user-friendly, efficient, and flexible virtualization solution for various guest operating systems.

## Features

- **Multiple OS Support**: Run various Linux-based guest operating systems, including Debian, ArchLinux, Kali Linux, Ubuntu, RaspiOS, and other specialized systems.
- **Lightweight & Effecient**: `QVM` is a sleek & efficient `Type 2 hypervisor` that leaves minimal footprint while maximising performance with seamless integration across platforms.
- **Hardware Emulation**: Emulate a wide range of hardware devices, including CPUs, network cards, and storage devices.
- **Disk Image Management**: Utilizes the `qcow2` format for efficient disk space usage and snapshot capabilities. `raw`, `vdi`, `vmdk` & `vhd` formats can also be used.
- **VM Templating**: Create and manage VM templates for quick and efficient replication of virtual machines.
- **Memory Management**: Configure and optimize VM memory usage with various backend options.
- **NUMA Support**: Enable `Non-Uniform Memory Access (NUMA)` for improved performance in multi-processor systems.
- **KVM & VGA Support**: Enable `Kernel-based Virtual Machine` support and use KVM virtualization features to further enhance performance. `VGA` graphics display drivers can be used instead of default QEMU graphics drivers for specialised use-cases.

## Installation

**Note**: `QVM (QEMU Virtual Machine Manager) - v1.0.3` is currently in a testing phase, with confirmed functionality on `Kali Linux` systems. While the tool itself operates stably once properly configured, users should be aware that the installation process can be sensitive to different environments. The primary challenge lies in `the interpretation of bash scripts by various shell environments`. As a result, `QVM` may not function correctly outside of a `bash shell environment`. Users attempting to install or run QVM on other systems or in other shell environments may encounter unexpected issues or failures. 

Therefore, I recommend using a `bash shell` when running `QVM` for the best experience. I am actively working to improve compatibility across different platforms and shells and hope for this to be resolved in the official `v1.0.3` release. For more information see the [QVM Issues](https://github.com/RoyalHighgrass/QVM-Manager/issues) page. If you experience any issues while running QVM inside a bash environment, please do raise an issue about it as it will allow me to make the code more robust.

This application is primarily developed and tested on a Kali Linux system.

See [here](https://github.com/RoyalHighgrass/QVM-Manager/issues/11#issuecomment-2606083067) for more information about which systems QVM has been tested on.

#### Installation Guide
First, make sure that your system is up-to-date & that `git` is installed & also up-to-date:

Using `apt`:
```
sudo apt update && sudo apt upgrade -y
sudo apt install git -y
```
Using `pacman`:
```
sudo pacman -Syu --noconfirm
sudo pacman -S git --noconfirm
```
To install `QVM-Manager`, follow these steps:
```
cd /tmp/
git clone https://github.com/RoyalHighgrass/QVM-Manager.git
cd QVM-Manager
sudo chmod +x QVM/config.sh
./QVM/config.sh
```
Not using `apt` or `pacman`:
```
If you are not using `apt` or `pacman` as your package manager, you will have to install all required packages
mannually before running the `./QVM/config.sh` command which will ask you if you have done so and are ready to
proceed. Proceeding without installing the necessary packages will cause the installation to fail.
```

## Requirements

All packages listed below are essential minimum requirements for QVM to function properly and (except for YAD) are all available through the Debian, Ubuntu and Kali Linux repositories via `apt`. Arch Linux users can install `YAD` using `pacman`. If you're using a distribution other than Kali, Debian, or Ubuntu, you'll need to manually install all the required packages and may have to find alternative versions if the exact package isn't available. Additional packages can be added as needed for enhanced functionality. 

If you use one of these systems and any package listed below is not available via your systems repository, you may want to consider installing it manually from source before running the `./QVM/config.sh` command.
```
wget
tree
cut
original-awk 
mawk 
gawk 
find
locate
zenity
wmctrl
make
cpu-checker
intltool 
autoconf 
gtk-layer-shell-doc 
gtk4-layer-shell-doc 
libgtk-3-common 
libgtk-4-common 
libgtk-3-0t64 
libgtk-3-dev 
yad (github)
acpi
bc
tr
xrandr
cgroup-tools
libvirt-clients 
libvirt-daemon-system 
bridge-utils 
virtinst 
libvirt-daemon
libvirt-clients-qemu
qemu-kvm 
qemu-system-common
qemu-system-arm
qemu-system-x86
qemu-efi-aarch64
qemu-system-modules-opengl
qemu-utils
grub-firmware-qemu
mgba-sdl
libsdl2-2.0-0
libsdl2-net-2.0-0
mednafen
```

## Usage

Start QVM's CLI interface:
```
qvm-manager
```
Launch GUI interface:
```
qvm-manager --gui
```
Get version info:
```
qvm-manager --version
```
Show help message:
```
qvm-manager --help
```
Save a VM snapshot:
```
qvm-manager --snap <vm_name> --tag <snapshot_name>
```
Roll back a VM to a previous state:
```
qvm-manager --revert <vm_name> --tag <snapshot_name>
```

For more advanced usage and configuration options, please refer to the [User Manual](QVM/User_Manual_-_QVM_Documentation.txt) documentation.

## Configuration

The hypervisor VM specifications can easily be configured using command-line application interface, and templating can be implemented via the graphical user interface. Some key configuration areas include:

- Memory allocation
- CPU cores used
- Network interfaces
- Display drivers
- Audio interfaces
- KVM & VGA intergration
- Virtual hardware
- Storage devices
- Shared memory
- Host keyboard sharing

## Contributing

Contributions to the project are welcome! Please read the [CONTRIBUTING.md](QVM/CONTRIBUTING.md) file for guidelines on how to submit pull requests, report issues, and suggest improvements.

## License

This project is licensed under the GNU General Public License v3.0. See the [LICENSE](QVM/LICENSE) file for more details.


