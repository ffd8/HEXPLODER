# HEXPLODER
bites through bytes for reverse engineering + glitching any binary file format!  

Built with Processing ~~2.2.1~~ 3.5.4  
Requires libraries: `Drop` + `ControlP5`

--------------

HEXPLODER v1.4  
teddavis.org 2015 – 22

HEXPLODER helps you reverse engineer any file [format] by changing one byte at a time throughout a range of the file data. in CHANGE mode a new hex value 'FF' (255 as default max value) replaces each byte offset, in OFFSET mode, the existing byte is adjusted in a +/- direction. HEXPLODER duplicates the file for each change, so work with small files! by precisely mishandling each byte of the format, you'll discover sweet spots in the code for further hexploitations! 

* WARNING: can easily generate gigabytes of data when using big files!
* USE AT YOUR OWN RISK: copies files, so no irreversible damage can be done.


instructions:  
- move `HEXPLODER` to your `~/Documents` folder (`Desktop` won't work...)  
- drag + drop file into this window  
- set hexplode range using slider above  
- press HEXPLODE to generate files  
- check '/hexplodations' (folder next to app) to see outputs  
- filename (*ie file\_010_00A.gif*) has byte offset in dec _ hex for 'goto offset' in hex editor   
- adjust range and/or press <- / -> arrow keys to shift range  
- toggle mode between CHANGE and OFFSET (sets or adjusts byte value  
- HEXPLODE to your heart's [or harddrive's] delight