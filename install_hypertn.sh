#!/data/data/com.termux/files/usr/bin/bash

set -e  # Stop execution if an error occurs

# Function to display messages in a formatted way
function print_message() {
    echo
    echo "***********************************************"
    echo "$1"
    echo "***********************************************"
    echo
}

# Check and install zstd if not available
if ! command -v zstd &>/dev/null; then
    echo "zstd not found, installing zstd..."
    pkg update -y && pkg install zstd -y
    echo "zstd successfully installed."
fi

# Replace platform-tools with android-tools if necessary
if pkg list-installed | grep -q 'platform-tools'; then
    echo "platform-tools detected, removing..."
    pkg uninstall platform-tools -y
    echo "Installing android-tools..."
    pkg update -y && pkg install -y termux-api android-tools
elif ! pkg list-installed | grep -q 'android-tools'; then
    echo "android-tools not found, installing..."
    pkg update -y && pkg install -y termux-api android-tools
fi

# Default slot
slot="AB"

clear

# Display information and instructions to the user
print_message "HyperTN/MIUITN ROM Mod by Thang Nguyen (Based on China ROM)"

echo "  1. Ensure your computer has at least 15 GB of free storage."
echo "  2. Put your phone into Fastboot mode before running this script."
echo "  3. If flashing fails, check your PC drivers."
echo
echo "  y = Keep data (Update HyperTN/MIUITN)"
echo "  n = Format data (First install of HyperTN/MIUITN)"
echo
read -p "Your choice {y/n}: " CHOICE

# Additional instructions
print_message "Put your phone into Fastboot mode"
echo "Ignore the 'Invalid sparse file format at magic header' message during the flashing process."
echo "Please wait during the flashing process, do not exit the script."

# Extract .new.dat.zst files to .img
for file in *.new.dat.zst; do
    base_name="${file%.new.dat.zst}"
    echo "Extracting $base_name..."
    zstd -d "$file" -o "$base_name.img"
done

# Flash firmware
for file in firmware-update/*; do
    base_name=$(basename "$file")
    base_name="${base_name%.*}"

    if [[ "$base_name" == "cust" ]]; then
        fastboot flash "$base_name" "$file"
    elif [[ "$base_name" == "preloader_raw" ]]; then
        for preloader in preloader_a preloader_b preloader1 preloader2; do
            fastboot flash "$preloader" "$file"
        done
    elif [[ "$slot" == "AB" ]]; then
        fastboot flash "${base_name}_a" "$file"
        fastboot flash "${base_name}_b" "$file"
    else
        fastboot flash "$base_name" "$file"
    fi
done

# Flash super.img if available
if [[ -f super.img ]]; then
    echo "Flashing super.img..."
    fastboot flash super super.img
    rm -f super.img
fi

# Format data if the user's choice is "n"
if [[ "$CHOICE" == "n" ]]; then
    echo "Formatting data..."
    fastboot erase userdata
    fastboot erase metadata
fi

# Set active slot if the device supports AB slots
if [[ "$slot" == "AB" ]]; then
    fastboot set_active a
fi

# Reboot the device
echo "Process complete, the device will now reboot..."
fastboot reboot
