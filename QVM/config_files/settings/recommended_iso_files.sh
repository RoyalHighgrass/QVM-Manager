if [ "$1" = "debian-12" ]; then
    url=$(elinks --dump https://debian.org/download | grep https | grep -E "netinst.iso" | awk -F"https" "{print \"https\" \$2}")
    echo "$url"
fi
if [ "$1" = "arch-linux" ]; then
    url=$(elinks --dump )
    echo "$url"
fi
if [ "$1" = "kali-linux" ]; then
    url=$(elinks --dump )
    echo "$url"
fi
if [ "$1" = "ubuntu-noble" ]; then
    url=$(elinks --dump )
    echo "$url"
fi
if [ "$1" = "ubuntu-server" ]; then
    url=$(elinks --dump )
    echo "$url"
fi
if [ "$1" = "raspi-os" ]; then
    url=$(elinks --dump )
    echo "$url"
fi
if [ "$1" = "manjaro-kde" ]; then
    url=$(elinks --dump )
    echo "$url"
fi
if [ "$1" = "manjaro-xfce" ]; then
    url=$(elinks --dump )
    echo "$url"
fi
if [ "$1" = "manjaro-gnome" ]; then
    url=$(elinks --dump )
    echo "$url"
fi
if [ "$1" = "parrot-os" ]; then
    url=$(elinks --dump )
    echo "$url"
fi
if [ "$1" = "fedora" ]; then
    url=$(elinks --dump )
    echo "$url"
fi
if [ "$1" = "linux-mint" ]; then
    url=$(elinks --dump )
    echo "$url"
fi
