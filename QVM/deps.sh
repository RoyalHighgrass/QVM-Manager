#!/bin/bash

# A helper function to print an error message and exit the script.
error_exit() {
    echo "[-] ERROR: $1" >&2
    exit 1
}

# System Information Detection

# Determine the package manager
# It tries common package managers in a specific order (dnf, yum, pacman, zypper, apt).
pm=$(which dnf 2>/dev/null || \
     which yum 2>/dev/null || \
     which pacman 2>/dev/null || \
     which zypper 2>/dev/null || \
     which apt 2>/dev/null)
pm=$(basename "$pm") # Extracts just the name of the executable (e.g., 'apt', 'dnf')

# Determine the host OS name
# Reads /etc/os-release to get the OS name, handling various formats.
host_os=$(cat /etc/os-release | grep NAME | cut -d'"' -f2 | grep -v "=" | tail -n 1)

# Determine the system architecture
# 'uname -m' provides the machine hardware name (e.g., x86_64, aarch64).
sys_arch=$(uname -m)

echo "[*] Detected Package Manager: $pm"
echo "[*] Detected Host OS: $host_os"
echo "[*] Detected System Architecture: $sys_arch"

# Packages common across various distributions
common_packages=(
    "wget" "tree" "locate" "zenity" "wmctrl" "make" "autoconf" "gawk" "acpi" "bc" "cmake" "intltool" "bridge-utils"
    "mgba-sdl" "mesa-utils" "elinks"
)

# Debian/Ubuntu (APT) specific packages
apt_dependencies=(
    "cpu-checker" "original-awk" "mawk" "libgtk-3-common" "libgtk-3-dev" "cgroup-tools" "grub-pc-bin"
    "libvirt-clients" "libvirt-daemon-system" "virtinst" "libvirt-daemon" "qemu-kvm" "automake"
    "intltool" "qemu-system-common" "qemu-system-arm" "qemu-system-x86" "qemu-efi-aarch64" "yad"
    "libsdl2-2.0-0" "libsdl2-net-2.0-0" "mednafen" "build-essential" "mesa-vulkan-drivers"
    "libwebkit2gtk-4.0-doc" "libgspell-1-dev" "libgtksourceview-3.0-dev" "libwebkit2gtk-4.0-dev"
)

# Arch Linux (Pacman) specific packages
pacman_dependencies=(
    "yad" "gtk-layer-shell" "gtk3" "gtk3-docs" "gtk3-demos" "gtk4" "gtk4-docs" "gtk4-demos"
    "libportal-gtk3" "libportal-gtk4" "libindicator-gtk3" "libvirt" "libvirt-dbus" "libvirt-glib"
    "libguestfs" "virt-firmware" "vulkan-virtio" "gcc" "libdaemon" "qemu-full" "qemu-guest-agent"
    "qemu-system-arm" "qemu-system-aarch64" "glbinding" "mesa" "vulkan-mesa-layers" "sdl2"
)

# Initialize variables for the chosen package manager and package list
install_command=""
declare -a all_required_packages # Use an array to store all unique packages for the current OS

# Determine Installation Method and Collect All Required Packages
case "$pm" in
    apt)
        install_command="sudo apt install -y"
        # Start with common packages, then add apt-specific ones
        all_required_packages=("${common_packages[@]}" "${apt_dependencies[@]}")

        # Handle Kali Linux specific APT dependencies
        case "$host_os" in
            *Kali*)
                all_required_packages+=("gtk4-layer-shell-doc" "libgtk-3-0t64" "qemu-system-modules-opengl")
            ;;
        esac

        # Handle Raspberry Pi specific APT dependencies
        is_rpi=$(cat /etc/hostname 2>/dev/null) # Suppress errors if /etc/hostname is missing
        if [[ "$is_rpi" != "raspberry" ]]; then # If it's NOT a Raspberry Pi
            all_required_packages+=("libgtk-4-common" "libgtk-4-dev" "libwebkit2gtk-4.1-0" "libwebkit2gtk-4.1-dev" "gtk-4-examples" "libgtk-4-1")
        fi
    ;;

    pacman)
        install_command="sudo pacman -S --noconfirm"
        all_required_packages=("${common_packages[@]}" "${pacman_dependencies[@]}")
    ;;

    # Add other package managers (dnf, zypper, yum) if needed.
    # For now, if an unsupported manager is found, it will prompt manual installation.
    dnf|yum|zypper)
        error_exit "Unsupported package manager: $pm. Please manually install QVM dependencies."
        # You would typically add dnf_dependencies and zypper_dependencies arrays here
        # and populate all_required_packages accordingly, similar to apt/pacman.
    ;;

    *) # Default case for unsupported or unknown package managers
        echo "[+] QVM-Manager: Error: Unsupported package manager: $pm"
        echo -e "[+] The following packages must be manually installed before proceeding with the QVM setup script:"
        echo "[+] Common dependencies: ${common_packages[*]}"
        echo "[+] Debian/Ubuntu specific dependencies (if applicable): ${apt_dependencies[*]}"
        echo "[+] Arch Linux specific dependencies (if applicable): ${pacman_dependencies[*]}"
        echo "\n[+] **Note**: The QVM setup wizard will likely fail if these are not installed!"
        read -rp "[+] Are you ready to proceed? [Y/n]: " proceed_choice
        proceed_choice=${proceed_choice:-Y} # Default to Y

        case "$proceed_choice" in
            [Yy])
                # Continue, assuming user has manually handled dependencies
                ;;
            *)
                exit 1 # Exit if user chooses not to proceed
                ;;
        esac
    ;;
esac

# Dependency Check and Installation Logic
packages_to_install=()
unavailable_packages=()

echo "[*] Beginning dependency check for QVM..."

# First, check which packages are NOT installed from the determined list
for req_pkg in "${all_required_packages[@]}"; do
    # Use dpkg for apt-based systems, and check 'pacman -Q' for pacman
    if [[ "$pm" == "apt" ]]; then
        if ! dpkg -l | grep -qw "$req_pkg"; then
            packages_to_install+=("$req_pkg")
        fi
    elif [[ "$pm" == "pacman" ]]; then
        # pacman -Q will exit with 0 if installed, 1 if not
        if ! pacman -Q "$req_pkg" &>/dev/null; then
            packages_to_install+=("$req_pkg")
        fi
    else
        # For other managers, if you implement them, add their specific checks here
        # For now, the script will error_exit earlier if it's not apt or pacman.
        echo "[-] WARNING: No specific installation check implemented for $pm for package '$req_pkg'. Assuming it needs to be installed."
        packages_to_install+=("$req_pkg")
    fi
done

# If there are missing packages, check their availability in repositories
if [[ "${#packages_to_install[@]}" -gt 0 ]]; then
    echo "[+] Found missing dependencies. Checking their availability in repositories..."

    # Perform an apt update if using apt to ensure fresh package lists
    if [[ "$pm" == "apt" ]]; then
        echo "[+] Updating apt repositories to check for package availability..."
        sudo apt update || error_exit "Failed to update apt repositories for availability check!"
    elif [[ "$pm" == "pacman" ]]; then
        echo "[+] Updating pacman repositories to check for package availability..."
        sudo pacman -Sy --noconfirm || error_exit "Failed to update pacman repositories for availability check!"
    fi

    declare -a actually_installable_packages
    for pkg in "${packages_to_install[@]}"; do
        # Check if the package is available using the appropriate command
        if [[ "$pm" == "apt" ]]; then
            if apt-cache show "$pkg" &>/dev/null; then
                actually_installable_packages+=("$pkg")
            else
                unavailable_packages+=("$pkg")
                echo "[-] WARNING: Package '$pkg' is not found in APT repositories and cannot be installed."
            fi
        elif [[ "$pm" == "pacman" ]]; then
            if pacman -Si "$pkg" &>/dev/null; then # pacman -Si checks synced databases for package info
                actually_installable_packages+=("$pkg")
            else
                unavailable_packages+=("$pkg")
                echo "[-] WARNING: Package '$pkg' is not found in Pacman repositories and cannot be installed."
            fi
        fi
    done

    # Proceed with installation if there are installable packages
    if [[ "${#actually_installable_packages[@]}" -gt 0 ]]; then
        echo "[+] Installing the missing and available required dependencies..."
        echo "[+] '${#actually_installable_packages[@]}' package(s) along with their dependencies will now be installed."

        # Convert array to space-separated string for the installation command
        install_string="${actually_installable_packages[*]}"
        eval "$install_command" "$install_string" || error_exit "Failed to install dependencies!"
        echo "[+] Package installation complete."
    else
        echo "[-] No missing packages were found to be available for installation."
    fi
else
    echo "[+] All required dependencies are already installed."
fi

# Report any packages that were listed but are unavailable
if [[ "${#unavailable_packages[@]}" -gt 0 ]]; then
    echo "" # Add a newline for readability
    echo "---"
    echo "[!] The following packages were listed as recommended but are NOT available in your current repositories:"
    for ua_pkg in "${unavailable_packages[@]}"; do
        echo "    - $ua_pkg"
    done
    echo "    Please check the package names or your repository configuration."
    echo "---"
fi

# Perform a final system update/upgrade for all systems
echo "[+] Performing a final system update..."
if [[ "$pm" == "apt" ]]; then
    sudo apt update && echo "[+] APT system update complete." || error_exit "Failed to perform the final APT update!"
    sudo apt upgrade -y && echo "[+] APT system upgrade complete." || echo "[-] No APT packages to upgrade or upgrade failed." # Allow upgrade to fail without exiting
elif [[ "$pm" == "pacman" ]]; then
    sudo pacman -Syu --noconfirm && echo "[+] Pacman system update and upgrade complete." || error_exit "Failed to perform the final Pacman update/upgrade!"
else
    echo "[+] Skipping final system update for unsupported package manager: $pm."
fi

echo "[*] QVM dependency check and installation process finished."

pwd
ls
sudo ./QVM/config.sh "$pm"
