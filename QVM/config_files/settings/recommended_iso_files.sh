if [ "$1" = "debian-12" ]; then
    url="https://cdimage.debian.org/debian-cd/current/"
    deb_latest=$(elinks --dump "$url" | grep https | grep -E "netinst.iso" | awk -F"https" "{print \"https\" \$2}")
    url+="$deb_latest"
fi
if [ "$1" = "arch-linux" ]; then
    url="https://archlinux.mailtunnel.eu/iso/latest/"
    arch_latest=$(elinks --dump "$url" | grep -v -E "\[|sig|torrent" | grep "\.iso" | awk '{print $2}' | tail -n 1)
    url+="$arch_latest"
fi
if [ "$1" = "kali-linux" ]; then
    url="https://cdimage.kali.org/current/"
    kali_latest=$(elinks --dump "$url" | awk -F ". " '{print $3}' | grep .iso | grep net | grep -v torrent | tail -n 1)
    url+="$kali_latest"
fi
if [ "$1" = "ubuntu-noble" ]; then
    url="https://releases.ubuntu.com/noble/"
    ubuntu_n=$(elinks --dump "$url" | grep -v "\[" | awk -F ". " '{print $3}' | grep .iso | grep desktop | grep -v -E "zsync|torrent" | tail -n 1)
    url="$ubuntu_n"
fi
if [ "$1" = "ubuntu-server" ]; then
    url=$(elinks --dump )
fi
if [ "$1" = "raspi-os" ]; then
    url=$(elinks --dump )
fi
if [ "$1" = "manjaro-kde" ]; then
    url=$(elinks --dump )
fi
if [ "$1" = "manjaro-xfce" ]; then
    url=$(elinks --dump )
fi
if [ "$1" = "manjaro-gnome" ]; then
    url=$(elinks --dump )
fi
if [ "$1" = "parrot-os" ]; then
    url=$(elinks --dump )
fi
if [ "$1" = "fedora" ]; then
    url=$(elinks --dump )
fi
if [ "$1" = "linux-mint" ]; then
    url=$(elinks --dump )    
fi
echo "$url"
