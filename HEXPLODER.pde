/*
 HEXPLODER v1.4
 teddavis.org 2015-22
 
 - run yourself within Processing 3.5.4:
 - first install 'drop' and 'controlp5' libraries (Sketch Menu » Import Library... » Add Library...)
 - press the magical PLAY button
 
 */

boolean useWindows = false; // *** WINDOWS users: change to true! ***



String ver = "1.4";
String verDates = "2015 - 22";
import java.util.Arrays;
import java.io.File;
import java.lang.management.*;
int maxMemory;
//  maxMemory = int(((com.sun.management.OperatingSystemMXBean) ManagementFactory.getOperatingSystemMXBean()).getTotalPhysicalMemorySize()/1024/1024/1024);

import drop.*;
SDrop drop;
MyDropListener dropList;

import controlP5.*;
ControlP5 cp5;
Range range;
Slider progress;
Textlabel dropLabel;
Textlabel fileLabel;
Bang gen, can;
Toggle mode;
Numberbox setValue, offsetValue;
Textarea console;
String consoleLog = "";

int maxBytes = 1000;
int bStart = 0;
int bEnd = 100;
boolean generating = false;
boolean brakes = false;
int genCounter = 0;
int brakeCounter = 0;

String fileName = "";
String fileNameP = "";
boolean loadingFile = false;
String fileFormat = "";
byte[] b, g;
String[] filePlease = {
  "please", "bitte", "por favor", "pur favor", "per favore", "prašau", "lütfen", "snälla", "fadlan", "Požalujsta", "Proszę", "Vær så snill"
};

String hr = "\n---------------\n";
String info = "HEXPLODER v"+ver+" \nteddavis.org "+verDates+hr+"HEXPLODER helps you reverse engineer any file [format] by changing one byte at a time throughout a range of the file data. in CHANGE mode a new hex value 'FF' (255 as default max value) replaces each byte offset, in OFFSET mode, the existing byte is adjusted in a +/- direction. HEXPLODER duplicates the file for each change, so work with small files! by precisely mishandling each byte of the format, you'll discover sweet spots in the code for further hexploitations! \n* WARNING: can easily generate gigabytes of data when using big files! *"+hr+"instructions:\n- drag + drop file into this window \n- set hexplode range using slider above \n- press HEXPLODE to generate files \n- check '/hexplodations' (folder next to app) to see outputs \n- filename has byte offset in dec + hex for 'goto offset' in any hexeditor \n- adjust range and/or press <- / -> arrow keys to shift range \n- toggle mode between CHANGE and OFFSET (sets or adjusts byte value \n- HEXPLODE to your heart's [or harddrive's] delight";

void setup() {
  size(500, 300);
  background(0);
  noSmooth();
  drop = new SDrop(this);
  dropList = new MyDropListener();
  drop.addDropListener(dropList);
  setupControls();

  //println(checkSpace());
}

void draw() {
  background(50);
  fill(255, 40);
  noStroke();
  rect(10, 114, width-20, height-125);

  if (fileName != "") {
    //renderFile();
    fileViz(width*.82, height*.64, height*.35, height*.5, 24, true);
  }

  if (generating) {
    if (genCounter == bStart) {
      progress.setVisible(true).setValue(0).setCaptionLabel("").setLabelVisible(false);
      consoleLog = "hexploding offsets "+bStart+" » "+bEnd+ " = " + (bEnd-bStart+1) +" files";
    }

    byte[] temp = new byte[b.length];
    arrayCopy(b, temp);
    int tempValue = int(temp[genCounter]); // current byte value
    if(!mode.getBooleanValue()){
      temp[genCounter] = byte(constrain(tempValue + floor(offsetValue.getValue()), 0, 255)); // *** add # to current value
    }else{
      temp[genCounter] = byte(floor(setValue.getValue())); // *** add custom byte value?
    }
    int tempDigits = String.valueOf(maxBytes).length();
    String tempPath = "HEXPLODATIONS/"+fileName+"_"+fileFormat+"/"; 
    String tempName = fileName+"_"+nf(genCounter, tempDigits)+"_"+hex(genCounter)+"."+fileFormat;
    saveBytes(tempPath+tempName, temp);
    progress.setValue(map(genCounter, bStart, bEnd, 0, 100));
    consoleLog = "hexploding: "+tempName +"\n"+consoleLog;
    console.setText(consoleLog);
    if (genCounter >= bEnd-1) {
      generating = false;
      if (brakes) {
        consoleLog = "stop! hexploded " + brakeCounter +" files so far! \n"+consoleLog;
      } else {
        consoleLog = "done! hexploded " + (bEnd-bStart+1) +" files! \n"+consoleLog;
      }
      console.setText(consoleLog);
      progress.setCaptionLabel("DONE GENERATING!")
        .setValueLabel("")
          .setLabelVisible(true);
      hideGen(false);
    } else {
      genCounter++;
    }
  } else if (fileName =="") {
    int fileRand = floor(map(frameCount%60, 0, 60, 0, filePlease.length-1));
    consoleLog = "feed me a file... "+filePlease[fileRand]+"?";
    consoleLog += hr+info;
    console.setText(consoleLog);
    fill(255, 80);
    rect(10, 10, width-20, 95);
    stroke(0, 120);
    pushMatrix();
    translate(width/2, height*.2);
    int plus = 10;
    line(0, -plus, 0, plus);
    line(-plus, 0, plus, 0);
    popMatrix();
    fileViz(width*.5, height*.2, height*.15, height*.20, 12, false);
  }

  dropList.draw();
}

void fileViz(float filex, float filey, float filew, float fileh, float corner, boolean showLines) {
  noFill();
  pushMatrix();
  translate(filex, filey);
  if (showLines) {
    int lineCount = floor(fileh/2);//75;
    int linePad = 2;
    pushMatrix();
    translate(0, -fileh/2); //**
    for (int i=0; i<lineCount; i++) {
      float lineW = filew/2-linePad+1;
      if (i < 13) {
        lineW = filew/2-corner-1;
      }

      if (generating && i > map(bStart, 0, maxBytes, 0, lineCount) && i < map(genCounter, 0, maxBytes, 0, lineCount)) {
        stroke(0, 255, 0, 120);
      } else {
        stroke(255, 40);
      }

      if (i > map(bStart, 0, maxBytes, 0, lineCount) && i < map(bEnd, 0, maxBytes, 0, lineCount)) {
        line(-filew/2+linePad, i*2, lineW, i*2);
      }
    }
    popMatrix();
  }

  beginShape();
  vertex(-filew/2, -fileh/2);
  vertex(filew/2-corner, -fileh/2);
  vertex(filew/2, -fileh/2+corner);
  vertex(filew/2-corner, -fileh/2+corner);
  vertex(filew/2-corner, -fileh/2);
  vertex(filew/2, -fileh/2+corner);
  vertex(filew/2, fileh/2);
  vertex(-filew/2, fileh/2);
  vertex(-filew/2, -fileh/2);
  endShape();
  popMatrix();
}

float checkSpace() {
  File checkSpaceDir = new File("/");
  return checkSpaceDir.getUsableSpace()/1024/1024/1024;
}

void keyReleased() {
  if (fileName != "") {

    if (keyCode == 39) {
      shiftRange(1);
    } else if (keyCode == 37) {
      shiftRange(0);
    } else if (keyCode == 38) {
      growRange(1);
    } else if (keyCode == 40) {
      growRange(0);
    }
  }
}

void growRange(int mode) {
  if (mode == 1) {
    float max = range.getArrayValue(1);
    range
      .setHighValue(max*1.01)
      ;
  } else {
    float min = range.getArrayValue(0);
    float max = range.getArrayValue(1);
    if (max > min) {
      range
        .setHighValue(max-(max-min)*.01)
        ;
    }
  }
}

void shiftRange(int mode) {
  if (mode == 1) {
    float min = range.getArrayValue(0);
    float max = range.getArrayValue(1);
    float r = (max-min)+1;
    range
      .setLowValue(max)
      .setHighValue(max+r)
        ;
  } else {
    float min = range.getArrayValue(0);
    float max = range.getArrayValue(1);
    float r = (max-min)-1;
    if (min-r < 0) {
      min = r;
    }
    range
      .setLowValue(min-r)
      .setHighValue(min)
        ;
  }
}

void setupControls() {
  cp5 = new ControlP5(this);
  range = cp5.addRange("range", 0, 1000, 100, 600, 75, 20, width-85, 50)
    .setColorForeground(color(255, 80))
      .setColorBackground(color(255, 40))
        .setColorActive(color(255, 120))
          .setVisible(false);
  ;
  range.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(1)
    //.setFont(createFont("Monaco", 10))
      ;

  gen = cp5.addBang("HEXPLODE")
    .setPosition(10, 20)
      .setSize(50, 50)
        .setId(1)
          .setColorForeground(color(255, 40))
            .setColorActive(color(0, 255, 0, 120))
              .setVisible(false);
  ;
  gen.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(1)
    //.setFont(createFont("Monaco", 10))
    ;

  dropLabel = cp5.addTextlabel("droplabel")
    .setText("") // DRAG + DROP FILE TO HEXPLODE
      .setPosition(8, 13)
        //.setFont(createFont("Monaco", 10))
          ;

  progress = cp5.addSlider("progress")
    .setPosition(10, 0)
      .setSize(width-20, 10)
        .setCaptionLabel("")
          .setRange(0, 100)
            .setColorForeground(color(255, 80))
              .setColorBackground(color(50))
                .setColorActive(color(255, 120))
                  .lock()
                    .setValueLabel("")
                      .setVisible(false)
                        ;
  progress.getCaptionLabel().align(ControlP5.RIGHT, ControlP5.CENTER).setPaddingX(2);
  
  
   setValue = cp5.addNumberbox("CHANGE")
     .setPosition(140,86)
     .setSize(50,20)
     //.setScrollSensitivity(1)
     .setValue(255)
     .setRange(0, 255)
     .setDecimalPrecision(0)
            .setColorForeground(color(255, 80))
              .setColorBackground(color(255, 40))
                .setColorActive(color(255, 120))
                     .setVisible(false)
     ;
     setValue.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(1);
  
    // MODE - change / offset
    mode = cp5.addToggle("BYTE MODE")
     .setPosition(75, 86)
     .setSize(50,20)
     .setValue(true)
            .setColorForeground(color(255, 80))
              .setColorBackground(color(255, 40))
                .setColorActive(color(255, 120))
     .setMode(ControlP5.SWITCH)
          .setVisible(false)
     ;
  mode.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(1);
  mode.onChange(new CallbackListener() {
       public void controlEvent(CallbackEvent theEvent) {
        modeCheck();
       };
     });
     
     offsetValue = cp5.addNumberbox("OFFSET")
     .setPosition(140,86)
     .setSize(50,20)
     //.setScrollSensitivity(1)
     .setValue(1)
     .setRange(-255, 255)
     .setDecimalPrecision(0)
            .setColorForeground(color(255, 80))
              .setColorBackground(color(255, 40))
                .setColorActive(color(255, 120))
     .setVisible(false)
     ;
     offsetValue.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(1);
     
     
     
  console = cp5.addTextarea("cnsl") 
    .setPosition(11, 114)
      .setSize(width-20, height-125)
        //.setFont(createFont("monaco", 10))
          .setLineHeight(16)
            .setColor(200)
              ;
  console
    .setColorBackground(color(255, 40))
    .setColorForeground(color(255, 100))
      ;

  //initRange();
}

//void SET_OFFSET(){
//  modeCheck();
//}

void initRange() {
  int min = int(range.getArrayValue(0));
  int max = 10;//int(range.getArrayValue(1));
  int rangeVal = int(range.getArrayValue(1) - range.getArrayValue(0));
  if (min > maxBytes || max > maxBytes) {
    min = 0;
    max = 100;
  }

  range
    .setMin(0)
    .setMax(maxBytes)
      .setRangeValues(min, maxBytes*.01);

  while (fileName == fileNameP) {
    consoleLog = "loading file...";
    console.setText(consoleLog);
  }
  loadingFile = false;
  if (fileName != "" && !loadingFile) {
    dropLabel.setVisible(false);
    gen.setVisible(true);
    range.setVisible(true);
    mode.setVisible(true);
    modeCheck();
    consoleLog = "imported: "+fileName+"."+fileFormat+" // "+nf(maxBytes, 1)+" bytes";
    console.setText(consoleLog);
  }
}

void modeCheck(){
  if(mode.getBooleanValue()){
    setValue.setVisible(true);
    offsetValue.setVisible(false);
  }else{
    setValue.setVisible(false);
    offsetValue.setVisible(true);
  }
}

void updateRange() {   
  float min = range.getArrayValue(0);
  float max = range.getArrayValue(1);
  int total = int(range.getArrayValue(1)- range.getArrayValue(0))+1;
  String rangeVal = nf(total, 1);
  int roughVal = int(total * (b.length/1024.0/1024.0));
  int roughValDisplay = roughVal;
  String roughValTerm = "Mb";
  if (roughVal > 1024) {
    roughValDisplay = roughVal / 1024;
    roughValTerm = "Gb";
  }
  range.setCaptionLabel("set range = " +rangeVal+ " offsets (files) // roughly "+ roughValDisplay + roughValTerm)
    .setLowValueLabel(nf(int(min), 1))
      .setHighValueLabel(nf(int(max), 1))
        ;
  bStart = int(min);
  bEnd = int(max);
  genCounter = bStart;
}

void HEXPLODE() {
  if (fileName != "") {
    brakes = false;
    if (!generating) {
      genCounter = bStart;
      generating = true;
      hideGen(true);
      brakeCounter = 0;
    } else {
      hideGen(false);
      brakeCounter = genCounter-bStart;
      genCounter = bEnd;
      progress.setVisible(false);
      brakes = true;
    }
  } else {
    fileLabel.setText("feed me a file... "+filePlease[floor(random(filePlease.length))]+"?");
  }
}

void hideGen(boolean mode) {
  if (mode) {
    gen.setCaptionLabel("CANCEL")
      .setColorForeground(color(255, 0, 0, 40))
        .setColorActive(color(255, 0, 0, 120))
          ;
    range.lock();
  } else {
    gen.setCaptionLabel("HEXPLODE")
      .setColorForeground(color(255, 40))
        .setColorActive(color(0, 255, 0, 120))
          ;
    range.unlock();
    progress.setVisible(false);
  }
}


void range(ControlEvent theEvent) {
  updateRange();
}


void dropEvent(DropEvent theDropEvent) {
}
// a custom DropListener class.
class MyDropListener extends DropListener {

  int myColor;

  MyDropListener() {
    myColor = color(255, 0);
    // set a target rect for drop event.
    setTargetRect(0, 0, width, height);
  }

  void draw() {
    fill(myColor);
    noStroke();
    rect(0, 0, width, height);
  }

  void dropEnter() {
    myColor = color(0, 255, 0, 80);
  }

  void dropLeave() {
    myColor = color(255, 0);
  }

  void dropEvent(DropEvent theDropEvent) {
    boolean dirCheck = false;
    if (theDropEvent.isFile()) {
      File myFile = theDropEvent.file();
      if (myFile.isDirectory()) {
        dirCheck = true;
      }
    }

    if (!generating) {
      if (theDropEvent.isFile() && !dirCheck) {      
        loadingFile = true;
        int index;
        if(useWindows){
          index = theDropEvent.filePath().lastIndexOf("\\"); // ** changed to \\ for windows!!!!
        }else{
          index = theDropEvent.filePath().lastIndexOf("/"); 
        }
        fileNameP = fileName;
        fileName = theDropEvent.filePath().substring(index + 1);
        index = theDropEvent.filePath().lastIndexOf(".");
        fileFormat = theDropEvent.filePath().substring(index + 1);
        fileName = fileName.substring(0, fileName.length()-fileFormat.length()-1);
        println(fileName +" / "+ fileFormat);

        b = loadBytes(theDropEvent.file());
        maxBytes = b.length-1;
        initRange();
      }
    }
  }
}
