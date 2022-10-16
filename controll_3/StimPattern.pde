final int limit_def_amp=10;  // 違う極性に移る時のsmoothによる刺激強度の変化の制限値
final int pattern = 1;
final int stimpattern = 0;


// 刺激パターン変更  
void selectPattern() {
  switch (mode) {
  case 1:
      selectFlag = !selectFlag;
      select_pattern=0;
      if (selectFlag) {
        if (patternList.size()>select_pattern) { 
          patternList.get(select_pattern).select();
          stimPattern = patternList.get(select_pattern).output();
          pola = patternList.get(select_pattern).pola();
          amp[pola] = patternList.get(select_pattern).amp();
          duration = patternList.get(select_pattern).duration();
        }
      } else {
        stimPattern = _stimPattern;
      }
    break;
  case 2: 
    if (selectFlag) {
      select_pattern++;
      pages_num = select_pattern/(smallDisplayNum_column*smallDisplayNum_row);
      if (select_pattern > patternList.size()-1){
        select_pattern = 0;
        pages_num = 0;
      }
      if (patternList.size()>select_pattern) { 
        stimPattern = patternList.get(select_pattern).output();
        pola = patternList.get(select_pattern).pola();
        amp[pola] = patternList.get(select_pattern).amp();
        duration = patternList.get(select_pattern).duration();
      }
      patternList.get(select_pattern).select();
      if(testStimFlag)testStimulation();
    }
    break;
  case 3:
    if (selectFlag) {
      select_pattern+=smallDisplayNum_column;
      pages_num = select_pattern/(smallDisplayNum_column*smallDisplayNum_row);
      if (select_pattern > patternList.size()-1){
        select_pattern = 0;
        pages_num = 0;
      }
      if (select_pattern > patternList.size())select_pattern -= smallDisplayNum_column;
      if (patternList.size()>select_pattern) { 
        stimPattern = patternList.get(select_pattern).output();
        pola = patternList.get(select_pattern).pola();
        amp[pola] = patternList.get(select_pattern).amp();
        duration = patternList.get(select_pattern).duration();
      }
      if(testStimFlag)testStimulation();
    }
    break;
  case 4:
    stimSelect_pattern = 0;
    stimSelectFlag = !stimSelectFlag;
    break;
  case 5:
    if (stimSelectFlag) {
      stimSelect_pattern++;
      if (stimSelect_pattern > stimPatternList.size()-1)stimSelect_pattern = 0;
    }
    break;
  default:
    println("error");
    break;
  }
}


void changePola(){
  if (pola == ANODE) {
    pola = CATHODE;
  } else {
    pola = ANODE;
  }
  if (pola == ANODE) {
    println("pola is anode.");
  } else {
    println("pola is cathode.");
  }
  SendStimulationPola();
  SendStimulationAmp();
}


void resetParameter(){
  amp[0] = amp[1] = 0;
  pulseWidth = 50;
  SendStimulationWidth();
  SendStimulationAmp();
  println("Stimulation parametor is reseted");
}


// フィルターがかけられている刺激点の値を0に
void stimFilterPattern(int num){
  noStroke();
  rectMode( CENTER );
  if(hexagonalStructure){
    int n=0;
    for ( int i = 0; i < max_hex_num; i++ ) {
      if(i<=max_hex_num/2){
          for ( float j = (max_hex_num+2-1)/2-(max_hex_num-min_hex_num)/2-(float)i/2; j <=max_hex_num-(max_hex_num-min_hex_num)/2+(float)i/2 ; j++) {
            if ((filter1[n]==1 && num==1) || (filter2[n]==1 && num==2)) {
              stimPattern[n] = 0;
            } 
            n++;
          }
        }else{
          for ( float j = max_hex_num+(max_hex_num-min_hex_num)/2-(float)i/2; j >(max_hex_num-min_hex_num)/2-(max_hex_num-min_hex_num)+(float)i/2 ; j--) {
            if ((filter1[n]==1 && num==1) || (filter2[n]==1 && num==2)) {
              stimPattern[n] = 0;
            }      
            n++;
        }
      }
    }
  }else{
    for ( int i = 0; i < vertical_num; i++ ) {
      for ( int j = 0; j < horizontal_num; j++ ) {
        if ((filter1[(i*horizontal_num)+j]==1 && num==1) || (filter2[(i*horizontal_num)+j]==1 && num==2)) {
          stimPattern[(i*horizontal_num)+j] = 0;
        } 
      }
    }
  }
}


int stimAmpSmoothly(int pattern_num){
  int _next_num=0;
  int _next_amp;
  int _amp;
  int def;
  
  if(stimPatternList.size() > pattern_num+1) _next_num = pattern_num+1;
  
  if(stimPatternList.size() > pattern_num){
    _amp = stimPatternList.get(pattern_num).amp();
    _next_amp = stimPatternList.get(_next_num).amp();
    def = _next_amp - _amp;
    if(stimPatternList.get(pattern_num).pola() != stimPatternList.get(_next_num).pola()){
        if(def > limit_def_amp) def = limit_def_amp;
        else if(def < -limit_def_amp) def = -limit_def_amp;
    }
    // 陽極から陰極、陰極から陽極に変わるときの変化の仕方を考慮したプログラムにかえる
    if((float)(((stimPatternList.get(pattern_num).duration())/10) / def) < 0.01) def = 0;
    return def;
    
  }else {
    return 0;
  }

}

void changeSmoothly(float ms){
  if(amp_def > 0){
    if(ms >= (float)(((stimPatternList.get(stimSelect_pattern).duration())/10) / amp_def)*smooth_num){  
      amp[pola] += 1;
      smooth_num++;
      SendStimulationAmp();  
      }
  }else if(amp_def < 0) {
    if(ms >= (float)(((stimPatternList.get(stimSelect_pattern).duration())/10) / -amp_def)*smooth_num){  
      amp[pola] -= 1;
      smooth_num++;
      SendStimulationAmp();
     }
  }
}



void nonStimulation() {
  if(connectESP){
    myPort.write((byte)PC_ESP_AMP); 
    SendIntData(0);
  }
  if(!selectFlag && !stimSelectFlag && !stimFlag){
    for(int i=0; i< ELECTRODE_NUM; i++)
      stimPattern[i] = 0;
  }
}

// 刺激の開始・テスト・終了
void startStim() { // 's'と同じ処理
  if(testStimFlag) testStimFlag = false;
  if(!stimFlag){
    start_ms = millis()/10;
    stimFlag = true;
    stimSelect_pattern = 0;
    stimPages_num = 0;
    patternOnceFlag = true;
    SendPatternData();
    if(connectESP) myPort.write((byte)STIMLATION_START); 
    drawStimPoint();
    stimSelectFlag = true;
    println("Stimulation starts");
  }
}

void testStim() { // 'c'と同じ処理
  if(!stimFlag){
    testStimFlag = !testStimFlag;
    testStimulation();
  }
}

void testStimulation(){
  if(testStimFlag){
    println("here");
      if(patternList.size()>select_pattern){
        if(selectFlag){
          stimPattern = patternList.get(select_pattern).output();
          pola = patternList.get(select_pattern).pola();
          amp[pola] = patternList.get(select_pattern).amp();
          duration = patternList.get(select_pattern).duration();
          SendStimulationPola();
          SendStimulationAmp();
          SendPatternData();
          
        }else{
          testStimFlag = false;
        }
        
      }
      if(connectESP) myPort.write((byte)STIMLATION_START);
      
    }else{
      if(connectESP) myPort.write((byte)STIMLATION_STOP); 
      stimPattern = _stimPattern;
    }
}

void finishStim(){ // 'f'と同じ処理
  if(connectESP) myPort.write((byte)STIMLATION_STOP); 
  if (stimFlag) {
    println("Stimulation is stopped");
    stimPattern = _stimPattern;
    stimSelect_pattern = 0;
    stimSelectFlag = false;
    stimFlag = false;
  } /*else {
    println("Stimulation is restarted");
  }
  stimFlag = !stimFlag;*/
}


// 刺激パターン保存に初期パターンを代入
void init_presetPattern() {
  /*
  patternList.add(new Pattern(pattern0, (char)ANODE, 30, duration));
  patternList.add(new Pattern(pattern1, (char)ANODE, 30, duration));
  patternList.add(new Pattern(pattern1, (char)CATHODE, 20, duration));
  patternList.add(new Pattern(filter1, (char)ANODE, 33, duration));
  patternList.add(new Pattern(filter2, (char)ANODE, 33, duration));*/
  //getPattern(presetFile, pattern);
}

void init_presetStimPattern() {
  //getPattern(presetStimFile, stimpattern);
}


// This is the mapping from HV513 shift resistors' output to 7 by 9 electrodes.

// プリセットパターン
final char[] pattern0 = {
  0, 0, 0, 0, 0, 0, 0, 
  0, 0, 0, 0, 0, 0, 0, 
  0, 0, 0, 0, 0, 0, 0, 
  0, 0, 0, 0, 0, 0, 0, 
  0, 0, 0, 0, 0, 0, 0, 
  0, 0, 0, 0, 0, 0, 0, 
  0, 0, 0, 0, 0, 0, 0, 
  0, 0, 0, 0, 0, 0, 0, 
  0, 0, 0, 0, 0, 0, 0, 
  0
};

final char[] pattern1 = {
  1, 1, 1, 1, 1, 1, 1, 
  1, 1, 1, 1, 1, 1, 1, 
  1, 1, 1, 1, 1, 1, 1, 
  1, 1, 1, 1, 1, 1, 1, 
  1, 1, 1, 1, 1, 1, 1, 
  1, 1, 1, 1, 1, 1, 1, 
  1, 1, 1, 1, 1, 1, 1, 
  1, 1, 1, 1, 1, 1, 1, 
  1, 1, 1, 1, 1, 1, 1, 
  0
};


// filter (刺激感度が悪くならないようにするため)
    final char[] filter1 = {
    1, 0, 1, 0, 1, 0, 1, 
    0, 1, 0, 1, 0, 1, 0, 
    1, 0, 1, 0, 1, 0, 1, 
    0, 1, 0, 1, 0, 1, 0, 
    1, 0, 1, 0, 1, 0, 1, 
    0, 1, 0, 1, 0, 1, 0, 
    1, 0, 1, 0, 1, 0, 1, 
    0, 1, 0, 1, 0, 1, 0, 
    1, 0, 1, 0, 1
  };
  
  final char[] filter2 = {
    0, 1, 0, 1, 0, 1, 0, 
    1, 0, 1, 0, 1, 0, 1, 
    0, 1, 0, 1, 0, 1, 0, 
    1, 0, 1, 0, 1, 0, 1, 
    0, 1, 0, 1, 0, 1, 0, 
    1, 0, 1, 0, 1, 0, 1, 
    0, 1, 0, 1, 0, 1, 0, 
    1, 0, 1, 0, 1, 0, 1, 
    0, 1, 0, 1, 0
  };
  
/*
  final char[] filter1 = {
    1, 0, 1, 0, 1, 0, 1, 
    0, 1, 0, 1, 0, 1, 0, 
    1, 0, 1, 0, 1, 0, 1, 
    0, 1, 0, 1, 0, 1, 0, 
    1, 0, 1, 0, 1, 0, 1, 
    0, 1, 0, 1, 0, 1, 0, 
    1, 0, 1, 0, 1, 0, 1, 
    0, 1, 0, 1, 0, 1, 0, 
    1, 0, 1, 0, 1, 0, 1, 
    0
  };
  
  final char[] filter2 = {
    0, 1, 0, 1, 0, 1, 0, 
    1, 0, 1, 0, 1, 0, 1, 
    0, 1, 0, 1, 0, 1, 0, 
    1, 0, 1, 0, 1, 0, 1, 
    0, 1, 0, 1, 0, 1, 0, 
    1, 0, 1, 0, 1, 0, 1, 
    0, 1, 0, 1, 0, 1, 0, 
    1, 0, 1, 0, 1, 0, 1, 
    0, 1, 0, 1, 0, 1, 0, 
    0
  };
*/
