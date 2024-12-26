# QVM-Manager (QEMU Virtual Machine Manager)

# QVM Manager-1.0.3 © 2024 P.H.

## Overview

This project implements a Type 2 hypervisor using QEMU (Quick Emulator). QEMU is a generic and open-source machine emulator and virtualizer that runs as an application on top of an existing operating system. Our implementation focuses on providing a user-friendly, efficient, and flexible virtualization solution for various guest operating systems.

## Features

- **Multiple OS Support**: Run various guest operating systems, including Windows, Linux, and other specialized systems.
- **Hardware Emulation**: Emulate a wide range of hardware devices, including CPUs, network cards, and storage devices.
- **Disk Image Management**: Utilize the `qcow2` format for efficient disk space usage and snapshot capabilities.
- **VM Templating**: Create and manage VM templates for quick and efficient replication of virtual machines.
- **Memory Management**: Configure and optimize VM memory usage with various backend options.
- **NUMA Support**: Enable Non-Uniform Memory Access (NUMA) for improved performance in multi-processor systems.

## Installation

To install the QVM-Manager, follow these steps:

cd /tmp/
git clone https://github.com/RoyalHighgrass/QVM-Manager.git
cd QVM-Manager
chmod +x QVM/config.sh
sudo ./QVM/config.sh

## Usage

Start QVM Manager:    qvm-manager
Launch GUI interface: qvm-manager --gui
Get version info:     qvm-manager --version
Show help message:    qvm-manager --help


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

We welcome contributions to the project! Please read our CONTRIBUTING.md file for guidelines on how to submit pull requests, report issues, and suggest improvements.

## License

This project is licensed under the GNU General Public License v3.0. See the LICENSE file for more details.
