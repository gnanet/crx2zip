# crx2zip + crx-downloader

## crx2zip - Convert .CRX files to .ZIP

## new implementation for crx v3 files

This is a simple one shot bash script that uses: od and dd to create a .ZIP archive from a .CRX file

### Technical background

The script reads the first 4 bytes, to ensure it is a CRX file, and reads the crx version from the 5th byte, to ensure its version 3 crx file
For version 3 crx, the header length is stored on the 9-12 bytes of the file. The 4 bytes in swapped order, stripped leading zero bytes, you get the length as 2 byte hex number.
Adding the format-header length (of 12) to the header length converted to decimal, produces the offset-bytes for **dd**
Finally it is stripping the offset bytes from the CRX using **dd**, and produces a valid ZIP format file.

### History

- original script by Rowan H - 8/20/2015 ( https://scramble45.github.io/ )
- Gergely Nagy - 6/15/2026 ( https://github.com/gnanet/crx2zip )
  idea taken from https://github.com/akhileshthite/chrome-extension-fetch/blob/main/index.js


## crx-downloader - Download Chrome Webstore Extension as CRX file

This is a simple bash script to download Chrome Extensions from the Chrome Webstore as a CRX file

### Technical background

**IMPORTANT: Intended mainly for linux desktops**

This script requires either a working URL like [this](https://chromiumdash.appspot.com/fetch_releases?channel=Stable&platform=Linux) to get the latest chrome version, or an installed deb package of chromium or google-chrome browser to retrieve the used chrome version, to build a download URL.
Then it uses **curl** to get the CRX file

Sample URL: https://chromewebstore.google.com/detail/new-tab-override/apjmekmegbmapdldmpnjjelchjcolmck

### History

- Gergely Nagy - 6/15/2026 ( https://github.com/gnanet/crx2zip )
