# QVM-Manager (QEMU Virtual Machine Manager)

# QVM Manager-1.0.3 © 2024 P.H.

## Overview

This project implements a Type 2 hypervisor for Linux-based systems using `QEMU (Quick Emulator)`. `QVM` is designed to facilitate the effecient use of QEMU which is a generic and open-source machine emulator and virtualizer that allows guest operating systems to run as an application on top of an existing operating system. This implementation focuses on providing a user-friendly, efficient, and flexible virtualization solution for various guest operating systems.

## Features

- **Multiple OS Support**: Run various Linux-based guest operating systems, including Debian, ArchLinux, Kali Linux, Ubuntu, RaspiOS, and other specialized systems.
- **Lightweight & Effecient**: `QVM` is a sleek & efficient Type 2 hypervisor that leaves minimal footprint while maximising performance with seamless integration across platforms.
- **Hardware Emulation**: Emulate a wide range of hardware devices, including CPUs, network cards, and storage devices.
- **Disk Image Management**: Utilizes the `qcow2` format for efficient disk space usage and snapshot capabilities. `raw`, `vdi`, `vmdk` & `vhd` formats can also be used.
- **VM Templating**: Create and manage VM templates for quick and efficient replication of virtual machines.
- **Memory Management**: Configure and optimize VM memory usage with various backend options.
- **NUMA Support**: Enable `Non-Uniform Memory Access (NUMA)` for improved performance in multi-processor systems.
- **KVM & VGA Support**: Enable `Kernel Virtual Machine` support and use KVM virtualization features to further enhance performance. `VGA` graphics display drivers can be used instead of default QEMU graphics drivers for specialised use-cases.

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

Contributions to the project are welcome! Please read the CONTRIBUTING.md file for guidelines on how to submit pull requests, report issues, and suggest improvements.

## License

This project is licensed under the GNU General Public License v3.0. See the LICENSE file for more details.
