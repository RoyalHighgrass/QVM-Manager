# Dear Virtualization Community,

As a long-time Linux user and VM enthusiast, I've encountered numerous challenges in running virtual machines on Linux. These experiences inspired me to create QVM, a new virtualization solution that addresses common pain points. Over the years, I've experimented with various hypervisors and virtualization software on Linux systems. While Windows users have Hyper-V and VMware Workstation, and macOS users have Parallels and VMware Fusion, Linux users have traditionally relied on VirtualBox, KVM, and virt-manager.

In autumn 2024, I discovered that virt-manager was deprecated, which explained some recent frustrations. This realization, coupled with the lack of a suitable alternative, motivated me to develop QVM. My goal was to combine the best features of virt-manager and GNOME Boxes to create a compelling alternative for Linux virtualization needs. Interestingly, after creating QVM, I came across a 2018 paper by Dr. Emmanuel Ogunshile, who had proposed a similar concept called "qvm: A command line tool for the provisioning of virtual machines". While Ogunshile's qvm was developed in Python and utilized YAML for configuration, the QVM I unknowingly created was implemented in Bash. This coincidental parallel development highlights the ongoing need for efficient virtualization tools in the Linux community.

# QVM Features:

- **Core Technology**: QVM is built on QEMU and is supported by KVM, providing powerful, hardware-assisted virtualization.
- **Streamlined Interface**: Unlike libvirt, QVM interfaces directly with QEMU for a more efficient experience.
- **User-Friendly**: QVM offers both a lightweight CLI and a user-friendly GUI for managing virtual machines.

# The Project

As my first open-source project, developing QVM has been an enlightening experience. Overcoming various challenges has deepened my understanding of emulation processes and boosted my confidence in tackling complex projects.

I hope QVM will become a valuable tool for the virtualization community. Your feedback and contributions are welcome as we continue to improve and expand its capabilities.

Happy virtualizing!

## P.H.
QVM Developer
