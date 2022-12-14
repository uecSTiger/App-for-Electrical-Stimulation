import javax.swing.*; //<>//

Table dataArray;
PrintWriter file;

String getFile = null;

void getPattern(String fileName, int num) {
  dataArray = loadTable(fileName);
  char [] csvPattern = new char [ELECTRODE_NUM];
  int _amp=0;
  float _duration=0;
  String noData = "";
  String p="";

  if(hexagonalStructure){
    for (int k=0; k<(dataArray.getRowCount()-1)/(max_hex_num+2); k++) {
      for (int j=0; j<(dataArray.getColumnCount())/max_hex_num; j++) {
        int n=0;
        noData = dataArray.getString((max_hex_num+2)*k, (max_hex_num+1)*j);
        if(noData.equals("NONE"))break;
        for(int i = 0; i < max_hex_num; i++){
          if(i<=max_hex_num/2){
            for(int l= 0; l < min_hex_num+i; l++){
              csvPattern[n]   = (char) dataArray.getInt(i+((max_hex_num+2)*k), l+((max_hex_num+1)*j));
              n++;
            }
          }else{
            for(int l= 0; l < min_hex_num+(max_hex_num-1-i); l++){
              csvPattern[n]   = (char) dataArray.getInt(i+((max_hex_num+2)*k), l+((max_hex_num+1)*j));
              n++; 
            }
          }
        }
        for(int i=vertical_num*horizontal_num; i<ELECTRODE_NUM-1;i++) csvPattern[i] = (char) 0;
        _amp = dataArray.getInt(max_hex_num+((max_hex_num+2)*k), 1+((max_hex_num+1)*j));
        _duration = dataArray.getInt(max_hex_num+((max_hex_num+2)*k),2+((max_hex_num+1)*j));
        p =  dataArray.getString(max_hex_num+((max_hex_num+2)*k), (max_hex_num+1)*j);
        if(num == pattern){
          if(patternList.size()<smallDisplayNum_limit){
            if (p.equals("ANODE")) {
              patternList.add(new Pattern(csvPattern, (char)ANODE, _amp, _duration));
            } else if(p.equals("CATHODE")) {
              patternList.add(new Pattern(csvPattern, (char)CATHODE, _amp, _duration));
            }else{    
              print("error to read csv");
            }
          }
        }else{
          if(stimPatternList.size()<stimDisplayNum_limit){
            if (p.equals("ANODE")) {
              stimPatternList.add(new Pattern(csvPattern, (char)ANODE, _amp, _duration));
            } else if(p.equals("CATHODE")){
              stimPatternList.add(new Pattern(csvPattern, (char)CATHODE, _amp, _duration));
            }else{
              print("error to read csv");
            }
          }
        }
      }
     if(noData.equals("NONE"))break;
    }
    
  }else{
    for (int k=0; k<(dataArray.getRowCount()-1)/vertical_num; k++) {
      for (int j=0; j<(dataArray.getColumnCount())/horizontal_num; j++) {
        noData = dataArray.getString((vertical_num+2)*k, (horizontal_num+1)*j);
        if(noData.equals("NONE"))break;
        for (int i = 0; i < vertical_num; i++) {
          for(int l = 0; l < horizontal_num; l++){
            csvPattern[i*horizontal_num+l]   = (char) dataArray.getInt(i+((vertical_num+2)*k), l+((horizontal_num+1)*j));
          }
        }
        int pin_mod = ELECTRODE_NUM%(vertical_num*horizontal_num);
        for(int i=vertical_num*horizontal_num; i<ELECTRODE_NUM-1;i++) csvPattern[i] = (char) 0;
        _amp = dataArray.getInt(vertical_num+((vertical_num+2)*k), pin_mod+1+((horizontal_num+1)*j));
        _duration = dataArray.getInt(vertical_num+((vertical_num+2)*k), pin_mod+2+((horizontal_num+1)*j));
        p =  dataArray.getString(vertical_num+((vertical_num+2)*k), pin_mod+((horizontal_num+1)*j));
        if(num == pattern){
          if(patternList.size()<smallDisplayNum_limit){
            if (p.equals("ANODE")) {
              patternList.add(new Pattern(csvPattern, (char)ANODE, _amp, _duration));
            } else if(p.equals("CATHODE")) {
              patternList.add(new Pattern(csvPattern, (char)CATHODE, _amp, _duration));
            }else{    
              print("here");
            }
          }
        }else{
          if(stimPatternList.size()<stimDisplayNum_limit){
            if (p.equals("ANODE")) {
              stimPatternList.add(new Pattern(csvPattern, (char)ANODE, _amp, _duration));
            } else {
              stimPatternList.add(new Pattern(csvPattern, (char)CATHODE, _amp, _duration));
            }
          }
        }
      }
      if(noData.equals("NONE"))break;
    }
  }
}



void CSVwritePattern(int num) {
  int output_num;
  String dataName= nf(year(), 2) + nf(month(), 2) + nf(day(), 2) +"-"+ nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
  if(num == stimpattern){
    file = createWriter("./stim_pattern/"+dataName+"_stim_pattern.csv");
    output_num = stimPatternList.size();
  }else{
    file = createWriter("./pattern/"+dataName+"_pattern.csv");
    output_num = patternList.size();
  }

  for (int j=0; j<output_num; j++) {
    if(num == stimpattern){
      stimPattern = stimPatternList.get(j).output();
    }else{
      stimPattern = patternList.get(j).output();
    }

    if(hexagonalStructure){
      int n=0;
      for ( int i = 0; i < max_hex_num; i++ ) {
        if(i<=max_hex_num/2){
          for ( float k = (max_hex_num+2-1)/2-(max_hex_num-min_hex_num)/2-(float)i/2; k <=max_hex_num-(max_hex_num-min_hex_num)/2+(float)i/2 ; k++) {
            file.print((int)stimPattern[n]+",");
            n++;
          }
        }else{
          for ( float k = max_hex_num+(max_hex_num-min_hex_num)/2-(float)i/2; k >(float)(max_hex_num-min_hex_num)/2-(max_hex_num-min_hex_num)+(float)i/2 ; k--) {
            file.print((int)stimPattern[n]+",");
            n++;
          }
        }
        file.println();
      }
    }else{
      for (int i=0; i<ELECTRODE_NUM; i++) {
        if (i%horizontal_num!=vertical_num-1) {
          file.print((int)stimPattern[i]+",");
        } else {
          file.println((int)stimPattern[i]);
        }
      }
    }
    if (patternList.get(j).pola == ANODE) {
      file.print("ANODE"+",");
    } else {
      file.print("CATHODE"+",");
    }
    if(num == stimpattern){
      file.print(stimPatternList.get(j).amp+",");
      file.println(stimPatternList.get(j).duration);
    }else{
      file.print(patternList.get(j).amp+",");
      file.println(patternList.get(j).duration);
    }
    file.println();
  }
  
  file.println("NONE");

  file.flush();
  file.close();

  stimPattern = _stimPattern;
}



void LoadCSV(int num) {
  if (getFile != null) {
    //???????????????????????????
    //???????????????????????????????????????????????????????????????
    String ext = getFile.substring(getFile.lastIndexOf('.') + 1);
    //????????????????????????????????????
    ext.toLowerCase();
    //??????????????????jpg,png,gif,tga??????????????????????????? 
    if (ext.equals("csv")) {
      //???????????????????????????????????????
      getPattern(getFile, num);
    }
    //???????????????????????????????????????
    getFile = null;
  }
}


//?????????????????????????????????????????????????????????????????? 
String getFileName(final int num) {
  //?????????????????????????????? 
  SwingUtilities.invokeLater(new Runnable() { 
    public void run() {
      try {
        //?????????????????????????????? 
        JFileChooser fc = new JFileChooser(); 
        int returnVal = fc.showOpenDialog(null);
        //??????????????????????????????????????????
        if (returnVal == JFileChooser.APPROVE_OPTION) {
          //???????????????????????? 
          File file = fc.getSelectedFile();
          //????????????????????????????????? 
          getFile = file.getPath();
          println("Load File.");
          LoadCSV(num);  // ?????????????????????????????????????????????
        }
      }
      //????????????????????? 
      catch (Exception e) {
        //??????????????? 
        e.printStackTrace();
      }
    }
  } 
  );
  //??????????????????????????????
  return getFile;
}
