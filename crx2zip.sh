#!/bin/bash
#
# Convert Chromium .CRX file to .ZIP, v1.2
# new implementation for crx v3 files
#
# Gergely Nagy - 6/15/2026 ( https://github.com/gnanet/crx2zip )
# original script by Rowan H - 8/20/2015 ( https://scramble45.github.io/ )

# This is a simple one shot bash script that uses: od and dd to
# create a .ZIP archive from a version 3 .CRX file
#
# The new implementation reads the crx version on the 5th byte,
# and is prepared to handle version 3 file
# for version 3 crx, the header length is stored on the 9-12 bytes
# in swapped order, stripped leading zero bytes, you get the length
# after converting to decimal.
# Adding the format header length (of 12) to the header length
# produces the offset bytes for *dd*


function checkDeps(){
    echo "Checking for required programs for script to work..."
    type od dd  >/dev/null || echo "Your missing a dependency, make sure you have *od* and *dd* installed."
}

function showUsage(){
    echo "Usage: $(basename $0) [-h|--help|help|crx-file]"
    echo "    Convert Chromium .CRX file to .ZIP"
    echo "    Executing without any argument causes the script to ask for the crx-file name"
    echo "    Arguments:"
    echo "       [crx-file] - the CRX filename you want to convert to ZIP"
    echo "       [-h/--help/help] - shows this help message"
    exit
}

checkDeps

clear

RED='\033[0;31m'
RST='\033[0m'
echo
printf "${RED}CRX 2 ZIP${RST}\n"
echo
if [[ -f "$1" ]] && [[ "x$(echo "$1" | grep -oE "\.crx$")" != "x" ]]; then
    crxPath="$1"
elif [[ "x$(echo "$1" | grep -oE "help|\-h|\-\-help")" != "x" ]]; then
    showUsage
else
    echo
    echo
    echo
    read -p "Enter the .CRX file path then press (Enter): " -i "$PWD/" -e crxPath
    echo
    if [[ ! -f "${crxPath}" ]]; then
        printf "${RED}Failed to open ${crxPath}${RST}\n"
        exit 1
    fi
fi

isCrx=$(od -A n --endian=little -N 4 -c ${crxPath} | tr -d " ")
if [[ "x${isCrx}" != "xCr24" ]]; then
    printf "${RED}No valid CRX format: ${crxPath}${RST}\n"
    exit 1
fi

crxVer=$(od -A n --endian=little -j 4 -N 1 -s ${crxPath} | tr -d " ")

if [ ${crxVer} -eq 3 ]; then
    headerSize=$(od -A n --endian=little -j 8 -N 2 -s ${crxPath} | tr -d " ")
    getPK=$(( ${headerSize} + 12 ))
else
    echo "Current implementation only support version 3 crx, but not version ${crxVer}"
    exit
fi

echo "PK Offset found: $getPK"

# Passes address to 'dd' to handle the rest

zipContainerName=$(echo ${crxPath::-4})

echo "Exporting our patched ZIP file to '${zipContainerName}.zip'"

dd if=$crxPath of=$zipContainerName.zip bs=1 iflag=skip_bytes skip=$getPK
echo
echo "You can now decompress your ZIP archive:"
echo
echo "${zipContainerName}.zip"

exit
