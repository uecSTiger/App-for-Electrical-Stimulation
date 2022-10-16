/******************************
電気刺激をUI的に変更できるIDE
長方形と六方最密構造に対応していますが、それ以外の形は長方形とフィルタ、ElectrodeMapping等を組み合わせることで対応できると思います。

ElectrodeMappingはarduino IDE 側のプログラムも変更する必要がありますのでご注意ください。

Amplitude：電流強度（0 - 200）
Duration：（0.1 - 10.0s）

矢印キー：
  上下：電流強度の調整
  左右：パルス幅の調整
テンキー：
  1：メモリー電極選択
  2：右へ移動
  3：下へ移動
  4：刺激電極選択
  5：右へ移動
  7：durationを-1.0
  8：durationを-0.1
  9：durationを+0.1
  0：durationを+1.0
  
電極：
  左　；刺激点の変更、カーソルドラッグアンドドロップで刺激点を反転、
   　   pで極性全反転
    reset：左の電極の刺激位置を前削除
    
  右上：刺激電極群
    save：刺激位置をCSVファイルとして保存
    load：保存したCSVファイルを読み込み
    Select：電極選択
    Delete Memory：刺激位置を前削除
    cons,：全ての刺激で同強度を使用（極性別）
    smooth：次の刺激に合わせて強度を滑らかに移動（cons.中は使用不可）
    <：前のページに移動
    >：次のページに移動
    
  右下：記録した刺激電極位置、クリックで刺激電極の最後尾にも保存
    add：現在の刺激を追加
    Delete Pre：先頭の保存刺激点を削除
    Delete Last：最後尾の保存刺激点を削除
    select：左の電極に表示、select中の電極の刺激点、時間、間隔調整用
    →：select中移動
    ↓：select中、下に移動
    Del：select中の電極の削除
    save：刺激位置をCSVファイルとして保存
    load：保存したCSVファイルを読み込み
    <：前のページに移動
    >：次のページに移動
  
  Filter 0：フィルター無し
  Filter 1：フィルター用、長方形以外の時に使用、電気刺激に慣れないように使用
  Filter 2：フィルター用、長方形以外の時に使用、電気刺激に慣れないように使用
  
  setP：実験の刺激パターンやCSV生成用
  Start：刺激開始（右上の刺激電極群を使用）
  Stop：刺激終了（右上の刺激電極群が空の場合は強制終了）
  pause: (未実装)
  Test：刺激強度確認用（startしておらず、刺激電極をセレクト中）<-右下へ移動

*******************************/


import processing.serial.*;
final char CATHODE = 1;
final char ANODE = 0;

//  user definitions
// The serial port:
final boolean connectESP = false;
String COM_PORT="COM3"; // sereial com7,3,  ble: com10, 7
final int ELECTRODE_NUM=64;
// electrodes_num(vertical, horizontal)
final int vertical_num = 8;
final int horizontal_num = 8;

final boolean hexagonalStructure = true;
final int min_hex_num=5;
final int max_hex_num=9;

// 5, 6, 7, 8, 9, 8, 7, 6, 5
// 4, 5, 6, 7, 8, 7, 6, 5, 4
// アルゴリズムを考える、(max-min)/2飛ばした場所から電極を配置,
// 奇数時もしくは偶数時(maxの反対に合わせる)に位置をずらす

// initial variable
final char defaultPola = ANODE;
final int defaultPulseWidth = 50;
final float defaultDuration = 10.0;

// page limits
final int pages_num_limit = 10;
final int stimPages_num_limit = 8;

// This is the mapping from HV513 shift resistors' output to 7 by 9 electrodes.

final char[] ElectrodeMapping = {
  0, 1, 2, 3, 4, 5, 6, 7, 
  8, 9, 10, 11, 12, 13, 14, 15, 
  16, 17, 18, 19, 20, 21, 22, 23, 
  24, 25, 26, 27, 28, 29, 30, 31, 
  32, 33, 34, 35, 36, 37, 38, 39, 
  40, 41, 42, 43, 44, 45, 46, 47, 
  48, 49, 50, 51, 52, 53, 54, 55, 
  56, 57, 58, 59, 60, 61, 62, 63
};
/*

final char[] ElectrodeMapping = {
 34, 35, 32, 29, 28, 31, 30, 
 38, 39, 36, 37, 24, 27, 26, 
 43, 40, 41, 20, 23, 22, 25, 
 47, 44, 45, 42, 19, 18, 21, 
 48, 49, 46, 15, 14, 17, 16, 
 52, 53, 50, 51, 10, 13, 12, 
 57, 54, 55, 6, 9, 8, 11, 
 61, 58, 59, 56, 5, 4, 7, 
 62, 63, 60, 1, 0, 3, 2, 
 33
 };
 
 
 final char[] ElectrodeMapping = {
         28, 36, 51, 22, 9,
       29, 43, 58, 23, 10,  3,
     37, 44, 49, 24,  0, 13, 27,
   38, 52, 56, 14,  1, 12, 26, 41,
 35, 42, 57, 15,  2, 11, 25, 40, 45,
   50, 30, 16, 63, 20, 34, 39, 55, 
     21,  7,  6, 19, 33, 48, 54,
        8,  5, 18, 32, 47, 53,
          4, 17, 31, 46, 62,
 59,60,61,
 //60,61,62なし
 };
 */


// 刺激パターンを記録しているリスト
ArrayList<Pattern> patternList;
ArrayList<Pattern> stimPatternList;

Serial myPort;       
final int  BOARDRATE = 921600; //921600

//graphical attributes
final int WINDOW_SIZE_X=1700;
final int WINDOW_SIZE_Y=600;

// graphical setup
final int shapePicth = 50;
final int shapeSize = 40;
// small drawing
final int smallShapePicth = 12;
final int smallShapeSize = 10;


// 刺激パターン
char pola = defaultPola;
int pulseWidth = defaultPulseWidth;
float duration = defaultDuration;
char [] stimPattern = new char [ELECTRODE_NUM];
int [] stim_strength = new int[ELECTRODE_NUM];
int [] contactArea = new int [ELECTRODE_NUM]; 
int [] amp = new int[2];

// 刺激、接触、電極選択フラグ
boolean stimFlag = false;        // 刺激開始
boolean measureFlag = false;     // 接触位置取得
boolean request_flag = true;     // 接触位置の電圧値取得
boolean selectFlag = false;      // メモリ電極選択
boolean stimSelectFlag = false;  // 刺激電極選択
boolean filterFlag = false;      // 刺激感度低下防止
boolean smoothFlag = false;      // 刺激電流の変化を緩やかにする
boolean consAmpFlag = true;     // 刺激電流で同じ電流値（陽極、陰極別）を使用
boolean patternOnceFlag = true;  // 一刺激で一回で良い作業のフラグ
boolean testStimFlag = false;    // 刺激強度の確認用
boolean reverseFlag = false;     // 刺激逆再生用
boolean temperatureOccurFlag = false; // 冷覚生起場所保存用

// 選択電極（メモリ、刺激）
int select_pattern = 0;
int stimSelect_pattern = 0;
int filter_num = 0;

// アドレスによる誤操作防止
char [] _stimPattern = new char [ELECTRODE_NUM];

int mode = 1;
int freq = 10;

float start_ms = 0;
int amp_def=0;
float smooth_num=0;

// プリセット刺激位置ファイル
final String presetFile = "./pattern/experiment_pattern.csv";
final String presetStimFile = "./stim_pattern/experiment_pattern_vertical.csv";

void init_StimParametors() {
  for (int pin=0; pin<ELECTRODE_NUM; pin++) {
    stimPattern[pin] = 0;
    contactArea[pin] = 0;
    stim_strength[stimPattern[pin]] = 1;
  }
  amp[0] = 0; 
  amp[1] = 0;
}


void settings() {
  size(WINDOW_SIZE_X, WINDOW_SIZE_Y);
  // init variables
  init_drawPattern();
  init_StimParametors();
}


void setup() {
  println(Serial.list());

  frameRate( 60 );

  smooth();
  ellipseMode( RADIUS );

  // stimulation setup
  // Open the port. baud rate=921600
  if (connectESP) { 
    myPort = new Serial(this, COM_PORT, BOARDRATE);
    myPort.clear();
  }

  println("Now volume is set to 0. Press UP and DOWN keys to adjust volume.");
  println("Pulse Width is set to 50. Press LEFT and RIGHT keys to adjust pulse width.");
  println("Press 's or v' keys to start stimulation or velvet illusion.");
  println("Press 'p' keys to change polarity.");
  println("Press 'r' keys to reset parametors.");
  println("Press 'f' keys to stop or restart stimulation.");

  patternList = new ArrayList<Pattern>();
  stimPatternList = new ArrayList<Pattern>();
  init_presetPattern();
  init_presetStimPattern();
}


//assume 60fps reflesh rate
void draw() {

  if (measureFlag) {
    // 接触領域を測る
    if (connectESP) contactArea();
  } else {
    //clear screen
    background(0);
    if (selectFlag) if (patternList.size()>0)patternList.get(select_pattern).select(); 
    if (stimSelectFlag) if (stimPatternList.size()>0) stimPatternList.get(stimSelect_pattern).select(); 
    drawDisplay();
    if (filterFlag) {
      stimFilterPattern(filter_num);
      drawFilterPoint(filter_num);
    }
    CheckColdPoint();/////////////////////
  }
  drawParameter();


  if (stimFlag) {
    // 刺激開始
    text("Stimulation", 170, 32);
    // 一刺激間で一回で良い作業
    if (patternOnceFlag) {
      // 刺激パターンの変更
      if (stimPatternList.size()>0) {
        stimPattern = stimPatternList.get(stimSelect_pattern).output();
        pola = stimPatternList.get(stimSelect_pattern).pola();
        if (!consAmpFlag)amp[pola] = stimPatternList.get(stimSelect_pattern).amp();
      }
      SendStimulationPola();
      SendStimulationAmp();
      SendPatternData();

      if (smoothFlag) {
        amp_def = stimAmpSmoothly(stimSelect_pattern);
        smooth_num=0;
      }
      temperatureOccurFlag = true;
      patternOnceFlag = false;
    }

    if (stimPatternList.size()>stimSelect_pattern) {
      float ms = millis()/10;
      ms = (ms-start_ms)/10;
      // 刺激時間分刺激を行う
      if (ms>=stimPatternList.get(stimSelect_pattern).duration()) {
        start_ms = millis()/10;
        if(reverseFlag){
          stimSelect_pattern--;
          if (stimSelect_pattern < 0) {
              stimSelect_pattern = (stimPatternList.size()-1);
              stimPages_num = (stimPatternList.size()-1)/(stimDisplayNum-1);
          }else if(stimSelect_pattern%(stimDisplayNum-1)==(stimDisplayNum-2)){
              stimPages_num--;
              if (stimPages_num < 0) stimPages_num = (stimPatternList.size()-1)/(stimDisplayNum-1);
          }    
          
        }else{
          stimSelect_pattern++;
          if (stimSelect_pattern > stimPatternList.size()-1) {
            stimSelect_pattern = 0;
            stimPages_num = 0;
          }
          else if (stimSelect_pattern%(stimDisplayNum-1)==0) {
            stimPages_num++;
            if (stimPages_num>(stimPatternList.size()-1)/(stimDisplayNum-1)) stimPages_num = 0;
          } 
        }
          
        patternOnceFlag = true;
      }

      text("time:"+ nf(ms/10, 1, 2), 300, WINDOW_SIZE_Y-30);

      // durationとmsを加味して刺激パターンや条件を変更
      // 刺激の変化をスムーズに
      if (smoothFlag) changeSmoothly(ms);
    } else if (stimPatternList.size() == 0) {
      finishStim();
    }
  } else {
    // 刺激修了
    text("Stop Stimulation", 170, 32);
  }
  changeStimPos();
}



void keyPressed() {
  boolean widthFlag = false;
  boolean ampFlag = false;

  // pulse amplitude or width 
  if (key == CODED) {
    if (keyCode == UP) {
      amp[pola] = amp[pola] + 1;
      ampFlag = true;
    } else if (keyCode == DOWN) {
      amp[pola] = amp[pola] -1;
      ampFlag = true;
    } else if (keyCode == LEFT) {
      pulseWidth = pulseWidth - 10;
      widthFlag = true;
    } else if (keyCode == RIGHT) {
      pulseWidth = pulseWidth + 10;
      widthFlag = true;
    }

    if (widthFlag == true) {
      if (pulseWidth > 500) pulseWidth = 500;
      else if (pulseWidth < 30) pulseWidth = 30;
      SendStimulationWidth();
      widthFlag = false;
      println("Width is set to: ", pulseWidth);
    } else if (ampFlag == true) {
      if (amp[pola] > 200) amp[pola] = 200;
      else if (amp[pola] <0) amp[pola] = 0;
      SendStimulationAmp();
      ampFlag = false;
      if (selectFlag) patternList.get(select_pattern).setAmp(amp[pola]);
      println("Volume is set to: ", amp[pola]);
    }
  }

  // mode settings by number 48:0 - 57:9
  // memory関係 mode 1:select, 2: move_column, 3:move_row
  // stim memory関係 mode 4: select, 5: move_column
  /*
  if ( key == 49) {
    mode = 1;
    selectPattern();
  } else if (key == 50) {
    mode = 2;
    selectPattern();
  } else if (key == 51) {
    mode = 3;
    selectPattern();
  } else if ( key == 52) {
    mode = 4;
    selectPattern();
  } else if (key == 53) {
    mode = 5;
    selectPattern();
  }

  if (key == 48) {
    duration +=1.0;
    if (duration > 100) duration = 100;
    if (selectFlag) patternList.get(select_pattern).setDuration(duration);
  } else if (key == 55) {
    duration -=1.0;
    if (duration < 1) duration = 1;
    if (selectFlag) patternList.get(select_pattern).setDuration(duration);
  }else if (key == 56) {
    duration -=0.1;
    if (duration < 1) duration = 1;
    if (selectFlag) patternList.get(select_pattern).setDuration(duration);
  }else if (key == 57) {
    duration +=0.1;
    if (duration > 100) duration = 100;
    if (selectFlag) patternList.get(select_pattern).setDuration(duration);;
  }
*/
  if (key == 50) {
      amp[pola] = amp[pola] -2;
      ampFlag = true;
  } else if (key == 56) {
    amp[pola] = amp[pola] + 1;
    ampFlag = true;
  }
   if (ampFlag == true) {
      if (amp[pola] > 200) amp[pola] = 200;
      else if (amp[pola] <0) amp[pola] = 0;
      SendStimulationAmp();
      ampFlag = false;
      if (selectFlag) patternList.get(select_pattern).setAmp(amp[pola]);
      println("Volume is set to: ", amp[pola]);
    }


  // stimulation parametor settings
  if (key == 'p') {
    changePola();
  } else if (key == 'f') {
    finishStim();
  } else if (key == 'r') {
    resetParameter();
  } else if (key == 's') {
    startStim();
  } else if (key == 'c') {
    testStim();
  } else if (key == 'm') {
    measureFlag = !measureFlag;
    if (connectESP) myPort.write(PC_ESP_MEASURE_REQUEST);
    // 記録している刺激電極位置の追加・削除
  } else if (key == 'j') {
    addMemoryPattern();
  } else if (key == 'k') {
    deletePreMemoryPattern();
  } else if (key == 'l') {
    deleteLastMemoryPattern();
  } else if (key == DELETE) {
    deleteSelectMemoryPattern();
  }
}



void dispose() {
  if (connectESP) {
    myPort.clear();
    while (myPort.available()>0) {
      myPort.read();
    }
  }
  amp[0] = amp[1] = 0;
  pulseWidth = 50;
  if (connectESP) {
    SendStimulationWidth();
    SendStimulationAmp();
    if (!stimFlag)  myPort.write((byte)STIMLATION_STOP);
  }
  stimFlag = false;

  println("Stimulation is finished");
}
