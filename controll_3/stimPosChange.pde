int preX = 0;
int preY = 0;

void changeStimPos() {
  if (mousePressed) {
    noFill();
    strokeWeight(10);
    rect(preX, preY, mouseX-preX, mouseY-preY);
  }
}


void mousePressed() {
  preX = mouseX;
  preY = mouseY;
}


void mouseReleased() {
  
    // 刺激パターン変更
    if(hexagonalStructure){
      int n=0;
      for ( int i = 0; i < max_hex_num; i++ ) {
        float drawPointY = topY + i * shapePicth;
        if(i<=max_hex_num/2){
          for ( float j = (max_hex_num+2-1)/2-(max_hex_num-min_hex_num)/2-(float)i/2; j <=max_hex_num-(max_hex_num-min_hex_num)/2+(float)i/2 ; j++) {
              float drawPointX =  j * shapePicth;
              if ((preX < drawPointX && mouseX > drawPointX) && (preY < drawPointY && mouseY > drawPointY) || 
              (preX > drawPointX && mouseX < drawPointX) && (preY > drawPointY && mouseY < drawPointY) || 
              (preX > drawPointX && mouseX < drawPointX) && (preY < drawPointY && mouseY > drawPointY) ||
              (preX < drawPointX && mouseX > drawPointX) && (preY > drawPointY && mouseY < drawPointY) 
              ) {
                if (stimPattern[n]==1) {                
                  stimPattern[n]=0;
                } else {
                  stimPattern[n]=1;
                }
              }
              n++;
          }
        }else{
          for ( float j = max_hex_num+(max_hex_num-min_hex_num)/2-(float)i/2; j >(max_hex_num-min_hex_num)/2-(max_hex_num-min_hex_num)+(float)i/2 ; j--) {
            float drawPointX = j * shapePicth;
            if ((preX < drawPointX && mouseX > drawPointX) && (preY < drawPointY && mouseY > drawPointY) || 
            (preX > drawPointX && mouseX < drawPointX) && (preY > drawPointY && mouseY < drawPointY) || 
            (preX > drawPointX && mouseX < drawPointX) && (preY < drawPointY && mouseY > drawPointY) ||
            (preX < drawPointX && mouseX > drawPointX) && (preY > drawPointY && mouseY < drawPointY) 
            ) {
              if (stimPattern[n]==1) {
                stimPattern[n]=0;
              } else {
                stimPattern[n]=1;
              }
            }
            n++;
          }
        }
      }
    
    }else{
      for ( int i = 0; i < vertical_num; i++ ) {
        float drawPointY = topY + i * shapePicth;
        for ( int j = 0; j < horizontal_num; j++ ) {
          float drawPointX = leftX + j * shapePicth - shapeSize;
          if ((preX < drawPointX && mouseX > drawPointX) && (preY < drawPointY && mouseY > drawPointY) || 
          (preX > drawPointX && mouseX < drawPointX) && (preY > drawPointY && mouseY < drawPointY) || 
          (preX > drawPointX && mouseX < drawPointX) && (preY < drawPointY && mouseY > drawPointY) ||
          (preX < drawPointX && mouseX > drawPointX) && (preY > drawPointY && mouseY < drawPointY) 
          ) {
            if (stimPattern[(i*horizontal_num)+j]==1) {
              stimPattern[(i*horizontal_num)+j]=0; //<>//
            } else {
              stimPattern[(i*horizontal_num)+j]=1; //<>//
            }
          } //<>//
        }
      }
    }
    // 刺激選択
    for (int i=pages_num*smallDisplayNum_column*smallDisplayNum_row; i<patternList.size(); i++) {
        if(patternList.get(i).Contains(mouseX, mouseY)){
          // 刺激位置保存数制限
          if(stimPatternList.size()<stimDisplayNum_limit)
            stimPatternList.add(new Pattern(patternList.get(i).output(), patternList.get(i).pola, patternList.get(i).amp, patternList.get(i).duration));
           break;
        }
    }
    for (int i=stimPages_num*(stimDisplayNum-1); i<stimPatternList.size(); i++) {
        if(stimPatternList.get(i).Contains(mouseX, mouseY)){
           stimPatternList.remove(i);
           if(stimSelect_pattern >= i) stimSelect_pattern--;
           if(stimSelect_pattern<0) stimSelect_pattern = 0;
           break;
        }
    }
    
    // filter選択rect( 430, 200, 50, 20 );
    if (leftX+pitchWidth-5<=mouseX && leftX+pitchWidth+45>mouseX && smallTopY-30<=mouseY && smallTopY-10>mouseY) {
      filter_num = 0; 
      filterFlag = false;
    }else if (leftX+pitchWidth-5<=mouseX && leftX+pitchWidth+45>mouseX && smallTopY-5<=mouseY && smallTopY+15>mouseY) {
      filter_num = 1;
      filterFlag = true;
    }else if (leftX+pitchWidth-5<=mouseX && leftX+pitchWidth+45>mouseX && smallTopY+20<=mouseY && smallTopY+40>mouseY) {
      filter_num = 2;
      filterFlag = true;
    }else if (6<=mouseX && 44>mouseX && 45<=mouseY && 135>mouseY) {
      nonStimulation();
    }
    // 刺激用リストボタン
    else if (leftX+pitchWidth+205<=mouseX && leftX+pitchWidth+295>mouseX && 9<=mouseY && 39>mouseY) {
      CSVwritePattern(stimpattern);
    }else if(leftX+pitchWidth+305<=mouseX && leftX+pitchWidth+395>mouseX && 9<=mouseY && 39>mouseY) {
      stimFlag = false;
      stimSelectFlag = false;
      getFile = getFileName(0);
    }else if(leftX+pitchWidth+405<=mouseX && leftX+pitchWidth+495>mouseX && 9<=mouseY && 39>mouseY) {
      stimSelectFlag = !stimSelectFlag; 
    }else if(leftX+pitchWidth+505<=mouseX && leftX+pitchWidth+595>mouseX && 9<=mouseY && 39>mouseY) {
        stimPatternList.clear();
    }else if(leftX+pitchWidth+605<=mouseX && leftX+pitchWidth+895>mouseX && 9<=mouseY && 39>mouseY) {
      if(!smoothFlag) consAmpFlag = !consAmpFlag;
    }else if(leftX+pitchWidth+905<=mouseX && leftX+pitchWidth+995>mouseX && 9<=mouseY && 39>mouseY) {
      if(!consAmpFlag) smoothFlag = !smoothFlag;
      if(!smoothFlag) amp_def = 0;
    }else if(leftX+pitchWidth+1005<=mouseX && leftX+pitchWidth+1095>mouseX && 9<=mouseY && 39>mouseY){
      reverseFlag = !reverseFlag;
    }
    
    // 刺激開始、終了ボタン
    else if(leftX+pitchWidth-5<=mouseX && leftX+pitchWidth+45>mouseX && smallTopY+50<=mouseY && smallTopY+90>mouseY) {
      setStimPoint();
    } else if (leftX+pitchWidth-5<=mouseX && leftX+pitchWidth+45>mouseX && smallTopY+100<=mouseY && smallTopY+140>mouseY) {
      startStim();
    }else if(leftX+pitchWidth-5<=mouseX && leftX+pitchWidth+45>mouseX && smallTopY+150<=mouseY && smallTopY+190>mouseY) {
      finishStim();
    }else if(leftX+pitchWidth-5<=mouseX && leftX+pitchWidth+45>mouseX && smallTopY+200<=mouseY && smallTopY+240>mouseY) {
      testStim();
    }
    // 記録している刺激位置の追加・削除rect( 680+(i*80), 215, 60, 30 );
    else if (leftX+pitchWidth+170<=mouseX && leftX+pitchWidth+230>mouseX && smallTopY-55<=mouseY && smallTopY-25>mouseY) {
      addMemoryPattern();
    }else if(leftX+pitchWidth+250<=mouseX && leftX+pitchWidth+310>mouseX && smallTopY-55<=mouseY && smallTopY-25>mouseY) {
      deletePreMemoryPattern();
    }else if(leftX+pitchWidth+330<=mouseX && leftX+pitchWidth+390>mouseX && smallTopY-55<=mouseY && smallTopY-25>mouseY) {
      deleteLastMemoryPattern();
    }else if(leftX+pitchWidth+410<=mouseX && leftX+pitchWidth+470>mouseX && smallTopY-55<=mouseY && smallTopY-25>mouseY) {
      mode = 1;
      selectPattern();
    }else if(leftX+pitchWidth+490<=mouseX && leftX+pitchWidth+550>mouseX && smallTopY-55<=mouseY && smallTopY-25>mouseY) {
      mode = 2;
      selectPattern();
    }else if(leftX+pitchWidth+570<=mouseX && leftX+pitchWidth+630>mouseX && smallTopY-55<=mouseY && smallTopY-25>mouseY) {
      mode = 3;
      selectPattern();
    }else if(leftX+pitchWidth+650<=mouseX && leftX+pitchWidth+710>mouseX && smallTopY-55<=mouseY && smallTopY-25>mouseY) {
      deleteSelectMemoryPattern();
    }
    // CSVにデータの書き込み、CSVのデータの読み込み
    else if(leftX+pitchWidth+730<=mouseX && leftX+pitchWidth+790>mouseX && smallTopY-55<=mouseY && smallTopY-25>mouseY) {
      CSVwritePattern(1);
    }else if(leftX+pitchWidth+810<=mouseX && leftX+pitchWidth+870>mouseX && smallTopY-55<=mouseY && smallTopY-25>mouseY) {
      getFile = getFileName(pattern); 
    }
    // memory data のページ移動
    else if(leftX+pitchWidth+895<=mouseX && leftX+pitchWidth+925>mouseX && smallTopY-55<=mouseY && smallTopY-25>mouseY) {
      PagesMemoryPatternMovePre();
    }else if(leftX+pitchWidth+985<=mouseX && leftX+pitchWidth+1015>mouseX && smallTopY-55<=mouseY && smallTopY-25>mouseY) {
      PagesMemoryPatternMoveNext(); 
    }
    // stim data のページ移動
    else if(leftX+pitchWidth+5<=mouseX && leftX+pitchWidth+35>mouseX && smallStimTopY+10<=mouseY && smallStimTopY+110>mouseY) {
      PagesStimPatternMovePre();
    }else if(width-45<=mouseX && width-15>mouseX && 50<=mouseY && 150>mouseY) {
      PagesStimPatternMoveNext(); 
    }
    //SendStimulationPattern(); //<>//
    //if(stimFlag) SendPatternData();
    delay(100);
  
}
