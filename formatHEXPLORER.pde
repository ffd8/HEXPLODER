/*
formatHexplorer v.1
cc teddavis.org 2015
*/


import java.util.Arrays;
import sojamo.drop.*;
SDrop drop;

import controlP5.*;
ControlP5 cp5;
Range range;
Slider progress;
Textlabel dropLabel;
Textlabel fileLabel;
Bang gen, can;
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
String fileFormat = "";
byte[] b, g;
String[] filePlease = {
  "please", "bitte", "por favor", "pur favor", "per favore", "prašau", "lütfen", "snälla", "fadlan", "Požalujsta", "Proszę", "Vær så snill"
};

void setup() {
  size(500, 300);
  background(0);
  noSmooth();
  drop = new SDrop(this);
  setupControls();
}

void draw() {
  background(50);
  fill(255, 40);
  noStroke();
  rect(10, 95, width-20, height-105);

  if (generating) {
    if (genCounter == bStart) {
      progress.setVisible(true).setValue(0).setCaptionLabel("").setLabelVisible(false);
      consoleLog = "hexploring offsets "+bStart+" » "+bEnd+ " = " + (bEnd-bStart+1) +" files";
    }

    byte[] temp = new byte[b.length];
    arrayCopy(b, temp);
    temp[genCounter] = byte(255);
    int tempDigits = String.valueOf(maxBytes).length();
    String tempPath = "outputs/"+fileName+"_"+fileFormat+"/";
    String tempName = fileName+"_"+nf(genCounter, tempDigits)+"_"+hex(genCounter)+"."+fileFormat;
    saveBytes(tempPath+tempName, temp);
    progress.setValue(map(genCounter, bStart, bEnd, 0, 100));
    consoleLog = "hexploring: "+tempName +"\n"+consoleLog;
    console.setText(consoleLog);
    if (genCounter >= bEnd-1) {
      generating = false;
      if(brakes){
        consoleLog = "stop! hexplored " + brakeCounter +" files so far! \n"+consoleLog;
      }else{
        consoleLog = "done! hexplored " + (bEnd-bStart+1) +" files! \n"+consoleLog;
      }
      console.setText(consoleLog);
      progress.setCaptionLabel("DONE GENERATING!")
        .setValueLabel("")
          .setLabelVisible(true);
      hideGen(false);
    } else {
      genCounter++;
    }
  } else if(fileName ==""){
    int fileRand = floor(map(frameCount%60, 0, 60, 0, filePlease.length-1));
    consoleLog = "feed me a file... "+filePlease[fileRand]+"?";
    console.setText(consoleLog);
  }
}

void keyReleased() {
  if (keyCode == 39) {
    shiftRange(1);
  } else if (keyCode == 37) {
    shiftRange(0);
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
  range = cp5.addRange("range", 0, 1000, 100, 600, 75, 30, width-85, 50)
    .setColorForeground(color(255, 80))
      .setColorBackground(color(255, 40))
        .setColorActive(color(255, 120))
          .setVisible(false);
  ;
  range.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(1)
    .setFont(createFont("Monaco", 10))
      ;

  gen = cp5.addBang("HEXPLORE")
    .setPosition(10, 30)
      .setSize(50, 50)
        .setId(1)
          .setColorForeground(color(255, 40))
            .setColorActive(color(0, 255, 0, 120))
              .setVisible(false);
  ;
  gen.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(1)
    .setFont(createFont("Monaco", 10));

  dropLabel = cp5.addTextlabel("droplabel")
    .setText("DRAG + DROP FILE TO HEXPLORE")
      .setPosition(8, 13)
        .setFont(createFont("Monaco", 10))
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

  console = cp5.addTextarea("cnsl") 
    .setPosition(10, 95)
      .setSize(width-20, height-105)
        .setFont(createFont("monaco", 10))
          .setLineHeight(14)
            .setColor(200)
              ;
  console
    .setColorBackground(color(255, 40))
    .setColorForeground(color(255, 100))
  ;

  initRange();
}

void initRange() {
  int min = int(range.getArrayValue(0));
  int max = int(range.getArrayValue(1));
  int rangeVal = int(range.getArrayValue(1) - range.getArrayValue(0));
  if (min >maxBytes || max > maxBytes) {
    min = 0;
    max = 100;
  }

  range.setMax(maxBytes).setRangeValues(min, max);

  if (fileName != "") {
    dropLabel.setVisible(false);
    gen.setVisible(true);
    range.setVisible(true);
    consoleLog = "imported: "+fileName+"."+fileFormat+" // "+nf(maxBytes, 1)+" bytes";
    console.setText(consoleLog);
  }
}

void updateRange() {   
  float min = range.getArrayValue(0);
  float max = range.getArrayValue(1);
  String rangeVal = nf(int(range.getArrayValue(1)- range.getArrayValue(0))+1, 1);
  range.setCaptionLabel("set range = " +rangeVal+ " offsets (files)")
    .setLowValueLabel(nf(int(min), 1))
      .setHighValueLabel(nf(int(max), 1))
        ;
  bStart = int(min);
  bEnd = int(max);
  genCounter = bStart;
}

void HEXPLORE() {
  if (fileName != "") {
    brakes = false;
    if (!generating) {
      genCounter = bStart;
      generating = true;
      hideGen(true);
      brakeCounter = 0;
    } else {
      hideGen(false);
      brakeCounter = genCounter;
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
    gen.setCaptionLabel("HEXPLORE")
      .setColorForeground(color(255, 40))
        .setColorActive(color(0,255,0, 120))
          ;
    range.unlock();
    progress.setVisible(false);
  }
}


void range(ControlEvent theEvent) {
  updateRange();
}

void dropEvent(DropEvent theDropEvent) {
  if (!generating) {
    println("isFile()\t"+theDropEvent.isFile());
    int index = theDropEvent.filePath().lastIndexOf("/");
    fileName = theDropEvent.filePath().substring(index + 1);
    index = theDropEvent.filePath().lastIndexOf(".");
    fileFormat = theDropEvent.filePath().substring(index + 1);
    fileName = fileName.substring(0, fileName.length()-fileFormat.length()-1);
    println(fileName +" / "+ fileFormat);

    if (theDropEvent.isFile()) {
      b = loadBytes(theDropEvent.file());
      maxBytes = b.length-1;
      initRange();
    }
  }
}

