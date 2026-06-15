# crx2zip - Convert .CRX files to .ZIP to allow for unpacking

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
