if [ "$1" = "debian-12" ]; then
    url="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/"
    deb_latest=$(elinks --dump "$url" | grep https | grep -E "netinst.iso" | awk -F"https" "{print \"https\" \$2}" | head -n 1)
    url="$deb_latest"
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
    url="https://releases.ubuntu.com/noble/"
    ubuntu_s=$(elinks --dump "$url" | grep -v "\[" | awk -F ". " '{print $3}' | grep .iso | grep server | grep -v -E "zsync|torrent" | tail -n 1)
    url="$ubuntu_s"
fi
if [ "$1" = "raspi-os" ]; then
    url="https://downloads.raspberrypi.com/rpd_x86/images/rpd_x86-2022-07-04/"
    rpi=$(elinks --dump "$url" | grep -v -E "\[|sig|torrent|sha" | grep .iso | awk -F ". " '{print $3}')
    url="$rpi"
fi
if [ "$1" = "manjaro-kde" ]; then
    url="https://download.manjaro.org/kde/24.2.1/manjaro-kde-24.2.1-241216-linux612.iso"
fi
if [ "$1" = "manjaro-xfce" ]; then
    url="https://download.manjaro.org/xfce/24.2.1/manjaro-xfce-24.2.1-241216-linux612.iso"
fi
if [ "$1" = "manjaro-gnome" ]; then
    url="https://download.manjaro.org/gnome/24.2.1/manjaro-gnome-24.2.1-241216-linux612.iso"
fi
if [ "$1" = "parrot-os" ]; then
    url="https://deb.parrot.sh/parrot/iso/6.2/"
    parrot=$(elinks --dump "$url" | awk -F". " '{print $3}' | grep "\.iso" | grep -v -E "hash|torrent" | grep security)
    url="$parrot"
fi
if [ "$1" = "fedora" ]; then
    url=""
    fedora_latest=$(elinks --dump )
    url="$fedora_latest"
fi
if [ "$1" = "linux-mint" ]; then
    url=""
    mint_latest=$(elinks --dump )
    url="$mint_latest"
fi
echo "$url"
