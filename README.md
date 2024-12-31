# QVM-Manager (QEMU Virtual Machine Manager)

![Description](QVM/config_files/logo_images/qvm-3.png)

# QVM Manager-1.0.3 © 2024 P.H.

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

This project implements a Type 2 hypervisor for Linux-based `x86_64` systems using `QEMU (Quick Emulator)`. `QVM` is designed to facilitate the effecient use of QEMU which is a generic and open-source machine emulator and virtualizer that allows guest operating systems to run as an application on top of an existing operating system. Tkerhis implementation focuses on providing a user-friendly, efficient, and flexible virtualization solution for various guest operating systems.

## Features

- **Multiple OS Support**: Run various Linux-based guest operating systems, including Debian, ArchLinux, Kali Linux, Ubuntu, RaspiOS, and other specialized systems.
- **Lightweight & Effecient**: `QVM` is a sleek & efficient Type 2 hypervisor that leaves minimal footprint while maximising performance with seamless integration across platforms.
- **Hardware Emulation**: Emulate a wide range of hardware devices, including CPUs, network cards, and storage devices.
- **Disk Image Management**: Utilizes the `qcow2` format for efficient disk space usage and snapshot capabilities. `raw`, `vdi`, `vmdk` & `vhd` formats can also be used.
- **VM Templating**: Create and manage VM templates for quick and efficient replication of virtual machines.
- **Memory Management**: Configure and optimize VM memory usage with various backend options.
- **NUMA Support**: Enable `Non-Uniform Memory Access (NUMA)` for improved performance in multi-processor systems.
- **KVM & VGA Support**: Enable `Kernel-based Virtual Machine` support and use KVM virtualization features to further enhance performance. `VGA` graphics display drivers can be used instead of default QEMU graphics drivers for specialised use-cases.

## Installation

First, make sure that your system is up-to-date & that `git` is installed:

Using `apt`:
```
sudo apt update && sudo apt upgrade -y
sudo apt install git
```
Using `pacman`:
```
sudo pacman -Syu
sudo pacman -S git
```
Using `dnf`:
```
dnf upgrade
dnf install git
```
Using `yum`:
```
sudo yum update && sudo yum upgrade
sudo yum install git
```
To install `QVM-Manager`, follow these steps:
```
cd /tmp/
git clone https://github.com/RoyalHighgrass/QVM-Manager.git
cd QVM-Manager
sudo chmod +x QVM/config.sh
sudo ./QVM/config.sh
```

## Requirements
```
wget
tree
cut
original-awk 2024-06-23-1
mawk 1.3.4.20240905-1
gawk 1:5.2.1-2+b1
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
qemu-kvm 
qemu-system-common
qemu-system-x86
qemu-system-modules-opengl
mgba-sdl
libsdl2-2.0-0
libsdl2-net-2.0-0
mednafen
```

## Usage

Start QVM Manager:
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

For more advanced usage and configuration options, please refer to the documentation.

## Configuration

The hypervisor can be configured using command-line application interface. Some key configuration areas include:

- Memory allocation
- CPU cores used
- Network interfaces
- Audio interfaces
- KVM & VGA intergration
- Storage devices
- Host keyboard sharing

## Contributing

Contributions to the project are welcome! Please read the [CONTRIBUTING.md](#QVM/CONTRIBUTING.md) file for guidelines on how to submit pull requests, report issues, and suggest improvements.

## License

This project is licensed under the GNU General Public License v3.0. See the LICENSE file for more details.
