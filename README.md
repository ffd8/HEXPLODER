# HEXPLODER
Reverse engineer and glitch any file through hexploiting the bytes of your choice!

Built with Processing 2.2.1
Requires Libraries: sDrop + ControlP5

--------------

HEXPLODER v1.1 // teddavis.org 2015-16

HEXPLODER helps you reverse engineer any file [format] by going through a range of bytes and injecting hex value 'FF' (max value) at each offset within a duplicate of the file. by precisely mishandling each byte of the format, you'll discover sweet spots in the code for further hexploitations! 

* WARNING: can easily generate gigabytes of data when using big files!
* USE AT YOUR OWN RISK: copies files, so no irreversable damage can be done.


instructions:
- drag + drop file into this window
- set hexplode range using slider above
- press HEXPLODE to generate files
- check '/hexplodations' (folder next to app) to see outputs
- filename has byte offset in dec + hex for 'goto offset' in any hexeditor 
- adjust range and/or press <- / -> arrow keys to shift range 
- HEXPLODE to your heart's [or harddrive's] delight
