#!/bin/bash
#
# crx-downloader.sh - Download Chrome Webstore Extension as CRX file
#
# IMPORTANT: Intended for linux desktops,
# This script requires either a working URL to get the latest chrome version,
# or installed deb package of chromium or google-chrome browser to retrieve its version,
# and builds a download URL.
# it uses **curl** to get the CRX file
#
# Gergely Nagy - 6/15/2026 ( https://github.com/gnanet/crx2zip )
#
# Sample URL https://chromewebstore.google.com/detail/new-tab-override/apjmekmegbmapdldmpnjjelchjcolmck

curlVerbose=0

function showUsage(){
    echo "Usage: $(basename $0) <URL>"
    echo
    echo "Download Chrome Webstore Extension as CRX file"
    echo "    Arguments:"
    echo "       [URL] - Chrome Webstore URL starting with https://chromewebstore.google.com/detail/"
    exit
}

if [ $# -eq 0 ]; then
    showUsage
    exit
fi

chromeVersion=$(curl -s -L "https://chromiumdash.appspot.com/fetch_releases?channel=Stable&platform=Linux" 2>/dev/null | grep -oE '"version":"[^\"]+"' | head -n1 | cut -d '"' -f4)

if [[ -z "${chromeVersion}" ]]; then
    echo "Failed to fetch latest chrome release version, trying to locate installed deb package version"
    chromeVersion=$(dpkg -l | grep -E "google-chrome|chromium-browser" | grep -i "web browser" | awk '{ print $3 }' | sort -V | tail -n1 | cut -d'.' -f1-4 | cut -d '-' -f1)
fi

if [[ -z "${chromeVersion}" ]]; then
    echo "This script requires either a working URL to get the latest chrome version, or installed deb package of chromium or google-chrome browser to retrieve its version"
    exit 127
fi

if [[ "$(echo "$1" | grep -E "^https://chromewebstore.google.com/detail/")" != "x" ]]; then
    webstoreurl="$1"
else
    echo "Provide a https://chromewebstore.google.com/detail/ URL"
    exit
fi

extensionName=$(echo "${webstoreurl}" | cut -d '/' -f5)
extensionId=$(echo "${webstoreurl}" | cut -d '/' -f6)
mainVersion=$(echo "${chromeVersion}" | cut -d '.' -f1)

if [[ ${curlVerbose} -eq 0 ]]; then
    curlSilent="-s"
else
    curlSilent=""
fi

curl ${curlSilent} -L "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=${chromeVersion}&acceptformat=crx2,crx3&x=id%3D${extensionId}%26uc" \
  -H 'accept: */*' \
  -H 'accept-language: en-US' \
  -H 'cache-control: no-cache' \
  -H 'pragma: no-cache' \
  -H 'priority: u=0, i' \
  -H "sec-ch-ua: \"Chromium\";v=\"${mainVersion}\", \"Google Chrome\";v=\"${mainVersion}\", \"Not/A)Brand\";v=\"99\"" \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Linux"' \
  -H 'sec-fetch-dest: document' \
  -H 'sec-fetch-mode: navigate' \
  -H 'sec-fetch-site: none' \
  -H 'sec-fetch-user: ?1' \
  -H 'upgrade-insecure-requests: 1' \
  -H "user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/${mainVersion}.0.0.0 Safari/537.36" \
  -H 'x-browser-channel: stable' \
  -H "x-browser-copyright: Copyright $(date +%Y) Google LLC. All Rights Reserved." \
  -H "x-browser-year: $(date +%Y)" \
  -o ${extensionName}.crx

if [ -f ${extensionName}.crx ]; then
    echo "The downloaded CRX file is:"
    echo "${extensionName}.crx"
else
    echo "No file downloaded, change curlVerbose= to 1, retry and check the curl output"
    exit 1
fi
