// filterの場所を変えて、刺激用の追加・削除・選択ボタンの追加

// 電極の配置
// 刺激電極
int pitchWidth;
int leftX;
// drawPattern と StimPattern_memoryで使用する変数
int pitchHeight;
int topY;
// 記録電極
int smallLeftX;
int smallTopY;
int smallPitchWidth;
int smallPitchHeight;
int smallDisplayNum_row;
int smallDisplayNum_column;
int smallDisplayNum_limit;
int pages_num=0;

// 使用する刺激電極
int smallStimLeftX;
int smallStimTopY;
int stimDisplayNum;
int stimDisplayNum_limit;
int stimPages_num=0;



// 描画に必要な変数の値の初期化
void init_drawPattern() {

  if (hexagonalStructure) {
    pitchWidth = shapePicth * ( max_hex_num - 1 );
    pitchHeight = shapePicth * ( max_hex_num - 1 );
    // 記憶した小さい電極位置
    smallPitchWidth = smallShapePicth * ( max_hex_num + 1);
    smallPitchHeight = smallShapePicth * ( max_hex_num + 1);
    smallLeftX =  ( width - (smallShapePicth * ( max_hex_num - 1 ))) / 20 +pitchWidth+100;
    smallTopY = ( height - (smallShapePicth * ( max_hex_num - 1 ))) /2;
      // 刺激に使用する電極位置
    smallStimLeftX = ( width - (smallShapePicth * ( max_hex_num - 1 ))) +pitchWidth+150;
    smallStimTopY = ( height - (smallShapePicth * ( max_hex_num - 1 )))/10;
  } else {
    pitchWidth = shapePicth * ( horizontal_num - 1 );
    pitchHeight = shapePicth * ( vertical_num - 1 );
    // 記憶した小さい電極位置
    smallPitchWidth = smallShapePicth * ( horizontal_num + 1);
    smallPitchHeight = smallShapePicth * ( vertical_num + 1);
    smallLeftX =  ( width - (smallShapePicth * ( horizontal_num - 1 ))) / 3;
    smallTopY = ( height - (smallShapePicth * ( vertical_num - 1 ))) /2;
      // 刺激に使用する電極位置
    smallStimLeftX = ( width - (smallShapePicth * ( horizontal_num - 1 ))) / 3;
    smallStimTopY = ( height - (smallShapePicth * ( vertical_num - 1 )))/10;
  }
  
  // 電極位置
  leftX = ( width - pitchWidth ) / 11;
  topY = ( height - pitchHeight ) / 3;

  smallDisplayNum_column = (width - (leftX+pitchWidth+80))/smallPitchWidth;  // 記録している電極の表示数（横）
  smallDisplayNum_row = (height - smallTopY)/smallPitchHeight;    // 記録している電極の表示数（縦）
  smallDisplayNum_limit = smallDisplayNum_column*smallDisplayNum_row*pages_num_limit;


  stimDisplayNum = (width - (leftX+pitchWidth+80))/smallPitchWidth+1;
  stimDisplayNum_limit = (stimDisplayNum-1) * stimPages_num_limit;
}

void drawDisplay() {
  // 刺激箇所描画
  drawStimPoint();
  drawUSingStimPoint();
  drawMemoryStimPoint();
  //noStroke();
  //rect((width-(leftX+pitchWidth)), 180, width-(leftX+pitchWidth)-100, 10 );

  // filter箇所描画
  pushMatrix();
  translate(leftX+pitchWidth+20, smallTopY-20);
  drawFilterButton();
  popMatrix();
  fill(255);
  // 刺激用リスト制御ボタン
  drawResetPatternButton();
  pushMatrix();
  translate(leftX+pitchWidth+20, smallTopY+70);
  drawStimStartButton();
  drawStimStopButton();
  drawStimTestButton();
  drawSetStimButton(); // set 刺激場所
  popMatrix();

  pushMatrix();
  translate(leftX+pitchWidth+250, smallStimTopY-30);  // この場所に判定を決める
  drawStimSaveLoadButton();
  drawStimSelectButton();
  drawAmpButton();
  drawAmpSmoothButton();
  drawReverseButton();
  deleteAllMemoryButton();
  translate(-230, 90);
  drawPagesStimPatternButton();
  popMatrix();

  // 刺激記録用リスト制御ボタン
  pushMatrix();
  translate(leftX+pitchWidth+200, smallTopY-40);
  drawMemoryPatternButton();
  drawSaveLoadMemoryPatternButton();
  drawPagesMemoryPatternButton();
  popMatrix();
}

void drawParameter() {
  int h = WINDOW_SIZE_Y * amp[pola] / 260;
  int w = WINDOW_SIZE_X/2* pulseWidth / 1000;

  rectMode( CORNER );
  noFill();
  stroke(0, 255, 0);
  strokeWeight(4);
  rect(WINDOW_SIZE_X/6, WINDOW_SIZE_Y-h, w, h);
  textSize(32);
  fill(255, 255, 255);
  text("Amplitude: "+amp[pola], 10, WINDOW_SIZE_Y-60); 
  text("Pulse Width: "+pulseWidth, 10, WINDOW_SIZE_Y-30);
  text("Duration: "+ nf(duration/10, 1, 2), 250, WINDOW_SIZE_Y-60);  
  if (pola == ANODE) {
    text("ANODIC", 0, 32);
  } else {
    text("CATHODIC", 0, 32);
  }
}


// 変更や現在刺激している点を描画
void drawStimPoint() {
  noStroke();
  rectMode( CENTER );
  if(hexagonalStructure){
    int n=0;
      for ( int i = 0; i < max_hex_num; i++ ) {
        float drawPointX;
        float drawPointY = topY + i * shapePicth;
        if(i<=max_hex_num/2){
          for ( float j = (max_hex_num+2-1)/2-(max_hex_num-min_hex_num)/2-(float)i/2; j <=max_hex_num-(max_hex_num-min_hex_num)/2+(float)i/2 ; j++) {
            drawPointX =  j * shapePicth;
            if (stimPattern[n]==1) {
              if (this.pola == CATHODE) {
                fill( 0, 0, 200, 200);
              } else {
                fill( 200, 0, 0, 200); // 接触によって色を変化する
              }
            } else {
              fill( 255, 217, 0, 200 );
            }
            rect( drawPointX, drawPointY, shapeSize, shapeSize );
            n++;
          }
        }else{
          for ( float j = max_hex_num+(max_hex_num-min_hex_num)/2-(float)i/2; j >(max_hex_num-min_hex_num)/2-(max_hex_num-min_hex_num)+(float)i/2 ; j--) {
            drawPointX = j * shapePicth;
            if (stimPattern[n]==1) {
              if (this.pola == CATHODE) {
                fill( 0, 0, 200, 200);
              } else {
                fill( 200, 0, 0, 200); // 接触によって色を変化する
              }
            } else {
              fill( 255, 217, 0, 200 );
            }
      
            rect( drawPointX, drawPointY, shapeSize, shapeSize );
            n++;
          }
        }
      }
  }else{
    for ( int i = 0; i < vertical_num; i++ ) {
      float drawPointY = topY + i * shapePicth;
      for ( int j = 0; j < horizontal_num; j++ ) {
        float drawPointX = leftX + j * shapePicth-shapeSize;
        if (stimPattern[(i*horizontal_num)+j]==1) {
          if (pola == CATHODE) {
            fill( 0, 0, 200, 200);
          } else {
            fill( 200, 0, 0, 200); // 接触によって色を変化する
          }
        } else {
          fill( 255, 217, 0, 200 );
        }
  
        rect( drawPointX, drawPointY, shapeSize, shapeSize );
      }
    }
  }
}


// フィルターをかけている場所の描画
void drawFilterPoint(int num) {
  noStroke();
  rectMode( CENTER );
  
  if(hexagonalStructure){
    int n=0;
      for ( int i = 0; i < max_hex_num; i++ ) {
        float drawPointX;
        float drawPointY = topY + i * shapePicth;
        if(i<=max_hex_num/2){
          for ( float j = (max_hex_num+2-1)/2-(max_hex_num-min_hex_num)/2-(float)i/2; j <=max_hex_num-(max_hex_num-min_hex_num)/2+(float)i/2 ; j++) {
            drawPointX =  j * shapePicth;
            if ((num==1 && filter1[n]==1) || (num==2 && filter2[n]==1)) {
              fill( 100, 100, 100);
              rect( drawPointX, drawPointY, shapeSize, shapeSize );
            }
            n++;
          }
        }else{
          for ( float j = max_hex_num+(max_hex_num-min_hex_num)/2-(float)i/2; j >(max_hex_num-min_hex_num)/2-(max_hex_num-min_hex_num)+(float)i/2 ; j--) {
            drawPointX = j * shapePicth;
            if ((num==1 && filter1[n]==1) || (num==2 && filter2[n]==1)) {
              fill( 100, 100, 100);
              rect( drawPointX, drawPointY, shapeSize, shapeSize );
            }
      
            n++;
          }
        }
      }
  }else{
    for ( int i = 0; i < vertical_num; i++ ) {
      float drawPointY = topY + i * shapePicth;
      for ( int j = 0; j < horizontal_num; j++ ) {
        float drawPointX = leftX + j * shapePicth-40;
        if ((num==1 && filter1[(i*horizontal_num)+j]==1) || (num==2 && filter2[(i*horizontal_num)+j]==1)) {
          fill( 100, 100, 100);
          rect( drawPointX, drawPointY, shapeSize, shapeSize );
        }
      }
    }
  }
}


// フィルターをかけるためのボタンの描画
void  drawFilterButton() {
  rectMode( CENTER );
  if (!filterFlag) {
    fill( 255, 255, 255);
    rect( 0, 0, 50, 20 );
    fill( 255, 255, 255, 100);
    rect( 0, 25, 50, 20 );
    rect( 0, 50, 50, 20 );
  } else {
    if (filter_num == 1) {
      fill( 255, 255, 255);
      rect( 0, 25, 50, 20 );
      fill( 255, 255, 255, 100);
      rect( 0, 0, 50, 20 );
      rect( 0, 50, 50, 20 );
    } else {
      fill( 255, 255, 255);
      rect( 0, 50, 50, 20 );
      fill( 255, 255, 255, 100);
      rect( 0, 0, 50, 20 );
      rect( 0, 25, 50, 20 );
    }
  }

  textSize(15);
  fill(0);
  text("Filter 0", -25, 5); 
  text("Filter 1", -25, 30); 
  text("Filter 2", -25, 55);
}


void drawStimSaveLoadButton() {
  fill( 255, 255, 255);
  rect( 0, 0, 90, 30 );
  rect(100, 0, 90, 30 );
  textSize(30);
  fill(0);
  text("Save", -30, 9); 
  text("Load", 65, 9);
}

void drawStimSelectButton() {
  if (stimSelectFlag) {
    fill( 255, 255, 255);
  } else {
    fill( 255, 255, 255, 100);
  }
  rect( 200, 0, 90, 30 );
  textSize(25);
  fill(0);
  text("Select", 165, 9);
}


void  drawResetPatternButton() {
  rectMode( CENTER );
  if (!selectFlag && !stimSelectFlag && !stimFlag) {
    fill( 255, 255, 255);
  } else {
    fill( 100, 100, 100);
  }
  rect( 25, 90, 38, 90 );

  textSize(35);
  fill(0);

  pushMatrix();
  rotate(radians(-90));
  text("reset", -135, 35); 
  popMatrix();
}


void  drawAmpButton() {
  rectMode( CENTER );
  if (consAmpFlag && !smoothFlag) {
    fill( 255, 255, 255);
  } else {
    fill( 255, 255, 255, 100);
  }
  rect( 500, 0, 290, 30 );
  textSize(20);
  fill(0);
  text("cons, anode:"+nf(amp[ANODE], 1)+", cathode:"+nf(amp[CATHODE], 1), 370, 6);
}


void deleteAllMemoryButton(){
  fill( 255, 255, 255);
  rect( 300, 0, 90, 30 );
  textSize(15);
  fill(0);
  text("Delete", 270, 0);
  text("Memory", 270, 12);

}

void  drawPagesStimPatternButton() {

  rectMode( CENTER );
  if (stimPages_num==0) {
    fill( 255, 255, 255, 100);
  } else {
    fill( 255, 255, 255);
  }
  rect( 0, 0, 30, 100 );

  if (stimPages_num>=(stimPatternList.size()-1)/(stimDisplayNum-1)) {
    fill( 255, 255, 255, 100);
  } else {
    fill( 255, 255, 255);
  }
  rect( width-(leftX+pitchWidth+50), 0, 30, 100 );
  textSize(25);
  fill(0);
  text("<", -10, 10);
  text(">", width-(leftX+pitchWidth+60), 10);
}


void  drawAmpSmoothButton() {
  rectMode( CENTER );
  if (smoothFlag && !consAmpFlag) {
    fill( 255, 255, 255);
  } else {
    fill( 255, 255, 255, 100);
  }
  rect( 700, 0, 90, 30 );
  textSize(20);
  fill(0);
  text("smooth", 660, 6);
}

void drawReverseButton(){
  rectMode( CENTER );
  if (reverseFlag) {
    fill( 255, 255, 255);
  } else {
    fill( 255, 255, 255, 100);
  }
  rect( 800, 0, 90, 30 );
  textSize(20);
  fill(0);
  text("reverse", 760, 6);
  
}
//reverseFlag


void  drawSetStimButton() {
  rectMode( CENTER );
  fill( 255, 255, 255);
  rect( 0, 0, 60, 40 );
  textSize(28);
  fill(255, 100, 100);
  text("setP", -30, 10);
}

void  drawStimStartButton() {
  rectMode( CENTER );
  if (!stimFlag) {
    fill( 255, 255, 255);
  } else {
    fill( 255, 255, 255, 100);
  }
  rect( 0, 50, 60, 40 );
  textSize(28);
  fill(255, 100, 100);
  text("Start", -30, 60);
}

void  drawStimStopButton() {
  rectMode( CENTER );
  if (stimFlag) {
    fill( 255, 255, 255);
  } else {
    fill( 255, 255, 255, 100);
  }
  rect( 0, 100, 60, 40 );
  textSize(28);
  fill(255, 100, 100);
  text("Stop", -30, 110);
}

void  drawStimTestButton() {
  rectMode( CENTER );
  if (testStimFlag) {
    fill( 200, 200, 0);
  } else if (!stimFlag) {
    fill( 255, 255, 255);
  } else {
    fill( 255, 255, 255, 100);
  }
  rect( 0, 150, 60, 40 );
  textSize(28);
  fill(255, 100, 100);
  text("Test", -30, 160);
}


void drawMemoryPatternButton() {
  rectMode( CENTER );
  fill( 255, 255, 255);
  for (int i=0; i<7; i++) {
    if (i>3 && !selectFlag) fill( 255, 255, 255, 100);
    rect((i*80), 0, 60, 30 );
  }
  textSize(20);
  fill(0);
  text("Add", -20, 10);
  text("Select", 210, 10);
  textSize(30);
  text("→", 310, 10);
  text("↓", 395, 10);
  text("Del", 455, 10);

  textSize(15);
  text("Delete", 60, 0);
  text("pre", 70, 10);
  text("Delete", 140, 0);
  text("last", 145, 10);
}

void drawSaveLoadMemoryPatternButton() {
  rectMode( CENTER );
  fill( 255, 255, 255);
  rect( 560, 0, 60, 30 );
  rect( 640, 0, 60, 30 );
  textSize(25);
  fill(0);
  text("Save", 535, 10);
  text("Load", 610, 10);
}

void drawPagesMemoryPatternButton() {
  rectMode( CENTER );
  fill( 255, 255, 255);
  rect( 710, 0, 30, 30 );
  rect( 800, 0, 30, 30 );
  textSize(25);
  text((pages_num+1)+"/"+(((patternList.size()-1)/(smallDisplayNum_column*smallDisplayNum_row))+1), 730, 10);
  fill(0);
  text("<", 700, 10);
  text(">", 790, 10);
}


// 記録した刺激点を描画
void drawMemoryStimPoint() {
  int x = 0, y = 0;

  textSize(20);
  fill(255, 255, 255);
  text("Memory Pattern", leftX+pitchWidth, smallTopY-35);
  for (int i=pages_num*smallDisplayNum_column*smallDisplayNum_row; i<patternList.size(); i++) {
    if (x==smallDisplayNum_column) {
      y++;
      x=0;
    }

    if (y>smallDisplayNum_row-1) return;
    patternList.get(i).onDisplay(x, y);
    x++;
  }
}

// 実際に使用する刺激するパターンの描画
void drawUSingStimPoint() {
  int x = 0;

  textSize(20);
  fill(255, 255, 255);
  text("Stimulation Pattern", leftX+pitchWidth, smallStimTopY-20); 
  for (int i=stimPages_num*(stimDisplayNum-1); i<stimPatternList.size(); i++) {
    if (x>stimDisplayNum-2)return;
    stimPatternList.get(i).onDisplayStimPattern(x);
    x++;
  }
}


// 記録している刺激位置の追加・削除
void addMemoryPattern() {
  if (patternList.size()<smallDisplayNum_limit) patternList.add(new Pattern(stimPattern, pola, amp[pola], duration));
}

void deletePreMemoryPattern() {
  if (patternList.size()>0) patternList.remove(0);
}

void deleteLastMemoryPattern() {
  if (patternList.size()>0) patternList.remove(patternList.size()-1);
}

void deleteSelectMemoryPattern() {
  if (patternList.size()>select_pattern && selectFlag) {
    patternList.remove(select_pattern);
    if (select_pattern > patternList.size()-1) select_pattern--;
    if (select_pattern <= 0) select_pattern = 0;
  }
}  

void PagesMemoryPatternMovePre() {
  pages_num--;
  if (pages_num<0) pages_num=0;
}

void PagesMemoryPatternMoveNext() {
  pages_num++;
  if ((pages_num>pages_num_limit-1) || (pages_num>((patternList.size()-1)/(smallDisplayNum_column*smallDisplayNum_row)))) pages_num--;
}

void PagesStimPatternMovePre() {
  stimPages_num--;
  if (stimPages_num<0) stimPages_num=0;
}

void PagesStimPatternMoveNext() {
  stimPages_num++;
  if ((stimPages_num>stimPages_num_limit-1) || (stimPages_num>((stimPatternList.size()-1)/(stimDisplayNum-1)))) stimPages_num--;
}




// 接触している領域を描画
void contactArea() {
  if (request_flag) {
    if (connectESP)myPort.write(PC_ESP32_MEASURE_DATA);
    //println("request data");
    request_flag = false;
  }

  stroke( 255, 217, 0);
  rectMode( CENTER );

  int inByte;// https://garretlab.web.fc2.com/arduino_reference/language/functions/communication/serial/readBytesUntil.html

  if (myPort.available()>(ELECTRODE_NUM*2)+1) {
    // println("here");
    inByte = myPort.read();

    // println("data: ", inByte);

    if (inByte == ESP_PC_MEASURE_RESULT) {
      if (myPort.available()>(ELECTRODE_NUM*2)) {
        // println("data");
        for (int pos=0; pos<ELECTRODE_NUM; pos++) {
          inByte = myPort.read()*64;
          inByte = inByte+myPort.read();
          //contactArea[ElectrodeMapping[pos]] = inByte;
          contactArea[pos] = inByte;
        }   
        myPort.write(PC_ESP32_MEASURE_RECIVED);
        request_flag = true;
      }
    } else {
      myPort.readBytesUntil(ESP_PC_MEASURE_RESULT);
      if (myPort.available()>(ELECTRODE_NUM*2)) {
        // println("data2");
        for (int pos=0; pos<ELECTRODE_NUM; pos++) {
          inByte = myPort.read()*64;
          inByte = inByte+myPort.read();
          //contactArea[ElectrodeMapping[pos]] = inByte;
          contactArea[pos] = inByte;
        }   
        myPort.write(PC_ESP32_MEASURE_RECIVED);
        request_flag = true;
      }
    }
  }

  //clear screen
  background(0);

  for ( int i = 0; i < vertical_num; i++ ) {
    for ( int j = 0; j < horizontal_num; j++ ) {
      float drawPointX = leftX + j * shapePicth;
      float drawPointY = topY + i * shapePicth;
      //println( contactArea[(i*horizontal_num)+j]);
      //fill(0, map(contactArea[(i*horizontal_num)+j], 0, 4095, 0, 255), 0);
      fill(0, map(contactArea[(ELECTRODE_NUM-1) - ElectrodeMapping[(i*horizontal_num)+j]], 0, 4095, 0, 255), 0);
      //fill(0,contactArea[(i*horizontal_num)+j],0);
      rect( drawPointX, drawPointY, shapeSize, shapeSize );
    }
  }
}
