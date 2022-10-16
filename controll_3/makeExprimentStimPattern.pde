/*******************************
 パラメータ数2つ：位置，刺激（陽極，陰極）．
 刺激周波数[Hz]：90Hz
 刺激の時間間隔  [ms] ：500
 刺激位置：0, 1, 2, 3, ...　, 190, 191 (192点)
 各パラメータの組み合わせに対する試行回数：1回
 刺激電流値：2mA???   なぜこの刺激電流値を選んだのか？－＞1mA生じる箇所が少ないかも？，3mA強すぎる（痛い）かもしれない
 　　　3種類の傾向の間の位置だから（生起するし，痛すぎないであろう値）

fileを作成するプログラム
 
 名前フォルダの下に実験数の実験結果をつくる
 ********************************/

/***** 実験パラメータの設定 *****/
// 刺激パラメータ
final int POS_NUM = 64;                    // 電極数 64
final int POLA_NUM = 1;                    // 極性数 2

// 試行パラメータ
final int EXP_NUM_SINGLE_SET = 1;                               // 実験の試行回数 1 3日に分けて実験を行う．
final int SINGLE_SET = POS_NUM*POLA_NUM;                        // 一回の実験の回数 64*2=128
final int TOTAL_EXP_NUM_SET = SINGLE_SET * EXP_NUM_SINGLE_SET;  // 全体の実験の回数 128*3?=384

// 実験データ記録パラメータ
final String Name = "aaaa";                // ファイル名 (人の名前)
final int set = 1;                         // 現在のセット変更用パラメータ(1セット目:set=1)途中からや修正用

exp_param[] _exp = new exp_param[TOTAL_EXP_NUM_SET];        // 実験データ保存用変数
setExcelFile DataSet = new setExcelFile();                      // ファイル作成用変数


// ソート用関数
void onePassOfSelectionSort(int num, int t) {
  int i = num;
  int s = i;
  for (int j = i + 1; j < SINGLE_SET*t; ++j) {
    if (_exp[j].rnd < _exp[s].rnd) {
      s = j;
    }
  }
  int tmp1 = _exp[i].position;
  int temp2 = _exp[i].polarity;
  float tmp3 = _exp[i].rnd; 

  _exp[i].position = _exp[s].position;
  _exp[i].polarity = _exp[s].polarity;
  _exp[i].rnd = _exp[s].rnd;

  _exp[s].position = tmp1;
  _exp[s].polarity = temp2;
  _exp[s].rnd = tmp3;
}


void setStimPoint(){
  //試行回数分の「カード」を用意する
  for (int i=0; i<TOTAL_EXP_NUM_SET; i++) {
    _exp[i] = new exp_param();
  }

  int n=0;   // 0-TOTAL_EXP_NUM_SET　のデータ作成回数記録用変数
  int k=0;   // SINGLE_SETごとにソートする回数記録用変数
  //「カード」に実験パラメータを書き込む
  for (int t=0; t<EXP_NUM_SINGLE_SET; t++) {
    for (int i=0; i<POS_NUM; i++) {
      for (int j=0; j<POLA_NUM; j++) {      
        _exp[n].position = ElectrodeMapping[i%POS_NUM];
        _exp[n].polarity = j%POLA_NUM;
        _exp[n].rnd =  random(10);
        n++;
      }
    }

    // ソート(SINGLE_SETごとに)
    for (k=t*SINGLE_SET; k <SINGLE_SET*(t+1); k++) {
      //「カード」に書き込んだランダム変数に基づいてソートすることで「カード」をシャッフルする
      onePassOfSelectionSort(k, t+1);
    }
  }

  DataSet.setFilepath(Name);                    // ExcelFileの作成
  for (int i=set-1; i<EXP_NUM_SINGLE_SET; i++) {
    DataSet.makeExcelfile(i+1);    // iセットごとの結果データの作成
    println(i);
    DataSet.writeFile(SINGLE_SET*i, Name);
    DataSet.closeFile();
  }
  for (int i=set-1; i<EXP_NUM_SINGLE_SET; i++) {
    DataSet.writeStimPosFile(SINGLE_SET*i, Name);
  }
  
  println("Set stimluation position.");
  delay(100);
}




//実験パラメータと結果を書き込む「カード」のフォーマット
class exp_param { 
  int position;  //パラメータ１：位置
  int polarity;  //パラメータ２：極性(-1:陰極,1:陽極, 0:エラー) 
  float rnd;     //ランダム数．実験セットをシャッフルするために使用
  char ans1;     //被験者の回答(温度)
  char ans2;     //被験者の回答(振動)
  char ans3;     //被験者の回答(圧覚)
  char ans4;     //被験者の回答(痛み)

  void exp_param() {
  }
}

// CSV出力ファイル作成用の関数
class setExcelFile {
  PrintWriter file; 
  String path;

  void setExcelFile() {
  }

  void setFilepath(String name) {
    path = "./result/"+name+"/";
  }

  void makeExcelfile(int cnt) {
    file = createWriter(path +year()+nf(month(), 2)+nf(day(), 2)+"_"+hour()+nf(minute(), 2)+nf(second(), 2)+"_" + str(cnt) + ".csv");
  }

  void closeFile() {
    file.flush();
    file.close();
  }

  void writeFile(int _n, String name) {
    file.println(name);
    file.println("Position"+","+"Polarity"+","+"Temperature"+","+"Pressure"+","+"Vibration"+","+"Pain");
    for (int n=_n; n<SINGLE_SET+_n; n++) {
      file.println(_exp[n].position  +","+ _exp[n].polarity  +","+ _exp[n].ans1 +","+ _exp[n].ans2 +","+ _exp[n].ans3 +","+ _exp[n].ans4);
    }
    file.println("");
  }
  
  void writeStimPosFile(int _n, String name){
    char [] ppattern = new char [ELECTRODE_NUM];
    String dataName= nf(year(), 2) + nf(month(), 2) + nf(day(), 2) +"-"+ nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
    file = createWriter("./pattern/"+name+"/"+dataName+"_test.csv");
  
    for (int j=_n; j<SINGLE_SET+_n; j++) {
      for(int k=0; k<ELECTRODE_NUM; k++){
        ppattern[k] = (_exp[j].position!=k)? (char)0:(char)1;
      }
      for (int i=0; i<ELECTRODE_NUM; i++) {
        if (i%horizontal_num!=horizontal_num-1) {
          file.print((int)ppattern[i]+",");
        } else {
          file.println((int)ppattern[i]);
        }
      }
      if (_exp[j].polarity == ANODE) {
        file.print("ANODE"+",");
      } else {
        file.print("CATHODE"+",");
      }
      file.print(amp[_exp[j].polarity]+",");
      file.println(duration);
      file.println();
    }
  
    file.flush();
    file.close();
  
  }
  
  
}
