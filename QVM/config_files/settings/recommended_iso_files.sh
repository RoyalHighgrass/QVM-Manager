# QVM recommends the following ISO images for creating virtual machines 
# as they are the latest or most stable releases from their official sources. 
# The URL retrieval is configured to always target the most current stable 
# version of each distro. 

#!/bin/bash


fetch_iso() {
    base_url="$1"
    filter="$2"
    extra_filter="$3"
    
    wget -qO- "$base_url" | grep -oP 'href="\K[^"]+' | grep -E "$filter" | grep -vE "$extra_filter" | head -n 1
}

case "$1" in
    "debian-12")
        base_url="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/"
	    iso=$(elinks --dump "$base_url" | grep https | grep -E "netinst.iso" | awk -F"https" "{print \"https\" \$2}" | head -n 1)
	    url="$iso"
        ;;
        
    "arch-linux")
        base_url="https://archlinux.mailtunnel.eu/iso/latest/"
        iso=$(fetch_iso "$base_url" "\.iso" "\[|sig|torrent")
        url="${base_url}${iso}"
        ;;
        
    "kali-linux")
        base_url="https://cdimage.kali.org/current/"
        iso=$(fetch_iso "$base_url" "net.*\.iso" "torrent")
        url="${base_url}${iso}"
        ;;
        
    "ubuntu-noble" | "ubuntu-server")
        base_url="https://releases.ubuntu.com/noble/"
        type_filter="desktop"
        [ "$1" = "ubuntu-server" ] && type_filter="server"
        iso=$(fetch_iso "$base_url" "${type_filter}.*\.iso" "zsync|torrent")
        url="${base_url}${iso}"
        ;;
        
    "raspi-os")
        base_url="https://downloads.raspberrypi.com/rpd_x86/images/rpd_x86-2022-07-04/"
        iso=$(fetch_iso "$base_url" "\.iso" "\[|sig|torrent|sha")
        url="${base_url}${iso}"
        ;;
        
    "manjaro-kde")
        url="https://download.manjaro.org/kde/24.2.1/manjaro-kde-24.2.1-241216-linux612.iso"
        ;;
        
    "manjaro-xfce")
        url="https://download.manjaro.org/xfce/24.2.1/manjaro-xfce-24.2.1-241216-linux612.iso"
        ;;
        
    "manjaro-gnome")
        url="https://download.manjaro.org/gnome/24.2.1/manjaro-gnome-24.2.1-241216-linux612.iso"
        ;;
        
    "parrot-os")
        base_url="https://deb.parrot.sh/parrot/iso/6.2/"
        iso=$(fetch_iso "$base_url" "security.*\.iso" "hash|torrent")
        url="${base_url}${iso}"
        ;;
        
    "fedora")
        base_url="https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/iso/"
	    iso=$(elinks --dump "$base_url" | awk '{print $2}' | grep ".iso" | head -n 1)
	    url="${base_url}${iso}"
        ;;
        
    "linux-mint")
        base_url="https://mirrors.gigenet.com/linuxmint/iso/stable/"
        version=$(wget -qO- "$base_url" | grep -oP 'href="\K[^"]+' | grep "/" | tail -n 1)
        case "$2" in
            "cin") d_type="cinnamon" ;;
            "mate") d_type="mate" ;;
            "xfce") d_type="xfce" ;;
            *) echo "Invalid Mint version"; exit 1 ;;
        esac
        iso=$(wget -qO- "${base_url}${version}" | grep -oP 'href="\K[^"]+' | grep "$d_type")
        url="${base_url}${version}${iso}"
        ;;
        
    *)
        echo "qvm-manager: Error! An unexpected error has arrived!."
        exit 1
        ;;
esac

echo "$url"
