#!/data/data/com.termux/files/usr/bin/bash

set -ex
clear

echo "HyperTN/MIUITN Rom Mod by Thang Nguyen (Based on China ROM)"

fastboot_cmd="META-INF/fastboot"

echo "***********************************************"
echo ""
echo "  1. Make sure your computer's hard drive is more than 15 Gb"
echo "  2. Please put the phone into Fastboot mode, and then open this script"
echo "  3. If the flashing fails, please check driver of PC"
echo ""
echo "***********************************************"
echo ""
echo "  y = Keep data (Update HyperTN/MIUITN)           n = Format data (First install HyperTN/MIUITN)"
echo ""
read -p "Your choice {y/n}: " CHOICE

echo ""
echo "  Please enter your phone into fastboot"
echo ""
echo ""
echo "***********************************************"

fqlx="AB"

echo ""
echo ""
echo "  Please ignore the prompt 'Invalid sparse file format at magic header'"
echo "  Please wait during the flashing process, don't exit"
echo ""
echo ""

for file in *.new.dat.zst; do
    par=${file%.new.dat.zst}
    rm -f "$par.img"
    echo "  Extracting $par ..."
    META-INF/zstd -d "$file" -o "$par.img"
done

for file in firmware-update/*; do
    par=$(basename "$file")
    par=${par%.*}

    if [[ "$par" == "cust" ]]; then
        $fastboot_cmd flash "$par" "$file"
    elif [[ "$par" == "preloader_raw" ]]; then
        for preloader in preloader_a preloader_b preloader1 preloader2; do
            $fastboot_cmd flash "$preloader" "$file"
        done
    elif [[ "$fqlx" == "AB" ]]; then
        $fastboot_cmd flash "${par}_a" "$file"
        $fastboot_cmd flash "${par}_b" "$file"
    else
        $fastboot_cmd flash "$par" "$file"
    fi
done

if [[ -f super.img ]]; then
    $fastboot_cmd flash super super.img
    rm -f super.img
fi

if [[ "$CHOICE" == "n" ]]; then
    echo "  Formatting..."
    $fastboot_cmd erase userdata
    $fastboot_cmd erase metadata
    echo ""
fi

echo ""
echo "  Success, system is restarting..."
echo ""

[[ "$fqlx" == "AB" ]] && $fastboot_cmd set_active a
$fastboot_cmd reboot
