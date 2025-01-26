# QVM recommends the following ISO images for creating virtual machines 
# as they are the latest or most stable releases from their official sources. 
# The URL retrieval is configured to always target the most current stable 
# version of each distro. 

if [ "$1" = "debian-12" ]; then
    url="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/"
    deb_latest=$(elinks --dump "$url" | grep https | grep -E "netinst.iso" | awk -F"https" "{print \"https\" \$2}" | head -n 1)
    url="$deb_latest"
elif [ "$1" = "arch-linux" ]; then
    url="https://archlinux.mailtunnel.eu/iso/latest/"
    arch_latest=$(elinks --dump "$url" | grep -v -E "\[|sig|torrent" | grep "\.iso" | awk '{print $2}' | tail -n 1)
    url="$arch_latest"
elif [ "$1" = "kali-linux" ]; then
    url="https://cdimage.kali.org/current/"
    kali_latest=$(elinks --dump "$url" | awk -F ". " '{print $3}' | grep .iso | grep net | grep -v torrent | tail -n 1)
    url="$kali_latest"
elif [ "$1" = "ubuntu-noble" ]; then
    url="https://releases.ubuntu.com/noble/"
    ubuntu_n=$(elinks --dump "$url" | grep -v "\[" | awk -F ". " '{print $3}' | grep .iso | grep desktop | grep -v -E "zsync|torrent" | tail -n 1)
    url="$ubuntu_n"
elif [ "$1" = "ubuntu-server" ]; then
    url="https://releases.ubuntu.com/noble/"
    ubuntu_s=$(elinks --dump "$url" | grep -v "\[" | awk -F ". " '{print $3}' | grep .iso | grep server | grep -v -E "zsync|torrent" | tail -n 1)
    url="$ubuntu_s"
elif [ "$1" = "raspi-os" ]; then
    url="https://downloads.raspberrypi.com/rpd_x86/images/rpd_x86-2022-07-04/"
    rpi=$(elinks --dump "$url" | grep -v -E "\[|sig|torrent|sha" | grep .iso | awk -F ". " '{print $3}')
    url="$rpi"
elif [ "$1" = "manjaro-kde" ]; then
    url="https://download.manjaro.org/kde/24.2.1/manjaro-kde-24.2.1-241216-linux612.iso"
elif [ "$1" = "manjaro-xfce" ]; then
    url="https://download.manjaro.org/xfce/24.2.1/manjaro-xfce-24.2.1-241216-linux612.iso"
elif [ "$1" = "manjaro-gnome" ]; then
    url="https://download.manjaro.org/gnome/24.2.1/manjaro-gnome-24.2.1-241216-linux612.iso"
elif [ "$1" = "parrot-os" ]; then
    url="https://deb.parrot.sh/parrot/iso/6.2/"
    parrot=$(elinks --dump "$url" | awk -F". " '{print $3}' | grep "\.iso" | grep -v -E "hash|torrent" | grep security)
    url="$parrot"
elif [ "$1" = "fedora" ]; then
    url="https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/iso/"
    fedora_latest=$(elinks --dump "$url" | awk '{print $2}' | grep ".iso" | head -n 1)
    url="${url}${fedora_latest}"
elif [ "$1" = "linux-mint" ]; then
    url="https://mirrors.gigenet.com/linuxmint/iso/stable/"
    version=$(elinks --dump "$url" | awk '{print $1}' | grep "/" | cut -d] -f2 | tail -n 1)
    if [[ "$2" = "cin" ]]; then
        d_type="cin"
    elif [[ "$2" = "mate" ]]; then
        d_type="mate"
    elif [[ "$2" = "xfce" ]]; then
        d_type="xfce"
    fi
    mint_latest=$(elinks --dump "${url}${version}" | grep https | awk '{print $2}' | grep "$d_type")
    url="$mint_latest"
fi
echo "$url"
