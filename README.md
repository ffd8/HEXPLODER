# HEXPLODER
bites through bytes for reverse engineering + glitching any binary file format!  

Built with Processing ~~2.2.1~~ 3.5.4  
Requires libraries: `Drop` + `ControlP5`

HEXPLODER v1.3
teddavis.org 2015 – 22

HEXPLODER helps you reverse engineer any file [format] by going through a range of bytes and injecting hex value 'FF' (max of 256 values for a byte) at each offset within a duplicate of the file. by precisely mishandling each byte of the format, you'll discover sweet spots in the code for further hexploitations! 

* WARNING: can easily generate gigabytes of data when using big files!
* USE AT YOUR OWN RISK: copies files, so no irreversible damage can be done.


instructions:
- drag + drop file into this window
- set hexplode range using slider above
- press HEXPLODE to generate files
- check '/hexplodations' (folder next to app) to see outputs
- filename (*ie myfile\_0560_00000230.gif*) has byte offset in dec + hex for 'goto offset' in any hexeditor 
- adjust range and/or press <- / -> arrow keys to shift range 
- HEXPLODE to your heart's [or harddrive's] delight
