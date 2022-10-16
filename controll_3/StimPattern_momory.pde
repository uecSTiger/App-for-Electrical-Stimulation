// 刺激や描画に使用するリストの関数
class Pattern{
  char [] pattern = new char [ELECTRODE_NUM];
  char pola;
  int amp;
  float duration=10;
  float drawPointX;
  float drawPointY;
  boolean select=false;  // select 機能追加。

  Pattern(char _pattern[], char _pola, int _amp, float _duration){
    for(int i=0; i<ELECTRODE_NUM;i++){
      this.pattern[i]=_pattern[i];
    }
    this.pola = _pola;
    this.duration = _duration;
    this.amp = _amp;
  }
  
  public void setDuration(float _duration){
    this.duration = _duration;
  }
  
  public void setAmp(int _amp){
    this.amp = _amp;
  }
  
  public char pola(){
    return this.pola;
  }
  
  public int amp(){
    return this.amp;
  }
  
  public float duration(){
    return this.duration;
  }

  public char[] output(){
    return this.pattern;
  }
  
  // 記録している電極の描画
  void onDisplay(int num_x, int num_y){
    noStroke();
    rectMode( CENTER );
    if(hexagonalStructure){
      int n=0;
      for ( int i = 0; i < max_hex_num; i++ ) {
        this.drawPointY = smallTopY + i * smallShapePicth +  smallPitchHeight * num_y-10;
        if(i<=max_hex_num/2){
          for ( float j = (max_hex_num+2-1)/2-(max_hex_num-min_hex_num)/2-(float)i/2; j <=max_hex_num-(max_hex_num-min_hex_num)/2+(float)i/2 ; j++) {
             this.drawPointX = smallLeftX + j * smallShapePicth + smallPitchWidth * num_x;
             if(this.pattern[n]==1) {
              if (this.pola == CATHODE) {
                fill( 0, 0, 200, 200);
              } else {
                fill( 200, 0, 0, 200); // 接触によって色を変化する
              }
            } else {
              fill( 255, 217, 0, 200 );
            }
      
            rect( this.drawPointX, this.drawPointY, smallShapeSize, smallShapeSize );
            n++;
          }
        }else{
          for ( float j = max_hex_num+(max_hex_num-min_hex_num)/2-(float)i/2; j >(float)(max_hex_num-min_hex_num)/2-(max_hex_num-min_hex_num)+(float)i/2 ; j--) {
            this.drawPointX = smallLeftX + j * smallShapePicth + smallPitchWidth * num_x;
            if (this.pattern[n]==1) {
              if (this.pola == CATHODE) {
                fill( 0, 0, 200, 200);
              } else {
                fill( 200, 0, 0, 200); // 接触によって色を変化する
              }
            } else {
              fill( 255, 217, 0, 200 );
            }
      
            rect( this.drawPointX, this.drawPointY, smallShapeSize, smallShapeSize );
            n++;
          }
        }
      }
      textSize(15);
      fill(255, 255, 255);
      text(this.amp+","+nf(this.duration/10, 1, 2)+"s", this.drawPointX, this.drawPointY+smallShapePicth+5); 
      
    }else{
      for ( int i = 0; i < vertical_num; i++ ) {
        this.drawPointY = smallTopY + i * smallShapePicth +  smallPitchHeight * num_y-10;
        
        for ( int j = 0; j < horizontal_num; j++ ) {
          this.drawPointX = smallLeftX + j * smallShapePicth + smallPitchWidth * num_x;
          if (this.pattern[(i*horizontal_num)+j]==1) {
            if (this.pola == CATHODE) {
              fill( 0, 0, 200, 200);
            } else {
              fill( 200, 0, 0, 200); // 接触によって色を変化する
            }
          } else {
            fill( 255, 217, 0, 200 );
          }
    
          rect( this.drawPointX, this.drawPointY, smallShapeSize, smallShapeSize );
        }
      }
      textSize(15);
      fill(255, 255, 255);
      text(this.amp+","+nf(this.duration/10, 1, 2)+"s", this.drawPointX-smallPitchWidth*2/3, this.drawPointY+smallShapePicth+5); 
    }
   
  }
 
  
  void onDisplayStimPattern(int num_x){
    noStroke();
    rectMode( CENTER );
    if(hexagonalStructure){
      int n = 0;
      for ( int i = 0; i < max_hex_num; i++ ) {
        this.drawPointY = smallStimTopY + i * smallShapePicth;
        if(i<=max_hex_num/2){
          for ( float j = (max_hex_num+2-1)/2-(max_hex_num-min_hex_num)/2-(float)i/2; j <=max_hex_num-(max_hex_num-min_hex_num)/2+(float)i/2 ; j++) {
            this.drawPointX = leftX+pitchWidth+30 + j * smallShapePicth + smallPitchWidth * num_x;
            if (this.pattern[n]==1) {
              if (this.pola == CATHODE) {
                fill( 0, 0, 200, 200);
              } else {
                fill( 200, 0, 0, 200); // 接触によって色を変化する
              }
            } else {
              fill( 255, 217, 0, 200 );
            }
      
            rect( this.drawPointX, this.drawPointY, smallShapeSize, smallShapeSize );
            n++;
          }
        }else{
          for ( float j = max_hex_num+(max_hex_num-min_hex_num)/2-(float)i/2; j >(max_hex_num-min_hex_num)/2-(max_hex_num-min_hex_num)+(float)i/2 ; j--) {
            this.drawPointX = leftX+pitchWidth+30 + j * smallShapePicth + smallPitchWidth * num_x;
            if (this.pattern[n]==1) {
              if (this.pola == CATHODE) {
                fill( 0, 0, 200, 200);
              } else {
                fill( 200, 0, 0, 200); // 接触によって色を変化する
              }
            } else {
              fill( 255, 217, 0, 200 );
            }
      
            rect( this.drawPointX, this.drawPointY, smallShapeSize, smallShapeSize );
            n++;
          }
        }
      }
      textSize(15);
      fill(255, 255, 255);
      text(this.amp+","+nf(this.duration/10, 1, 2)+"s", this.drawPointX, this.drawPointY+smallShapePicth+5); 
      
    }else{
      for ( int i = 0; i < vertical_num; i++ ) {
        this.drawPointY = smallStimTopY + i * smallShapePicth;
        for ( int j = 0; j < horizontal_num; j++ ) {
          this.drawPointX = leftX+pitchWidth+80 + j * smallShapePicth + smallPitchWidth * num_x;
          if (this.pattern[(i*horizontal_num)+j]==1) {
            if (this.pola == CATHODE) {
              fill( 0, 0, 200, 200);
            } else {
              fill( 200, 0, 0, 200); // 接触によって色を変化する
            }
          } else {
            fill( 255, 217, 0, 200 );
          }
    
          rect( this.drawPointX, this.drawPointY, smallShapeSize, smallShapeSize );
        }
      }
      textSize(15);
      fill(255, 255, 255);
      text(this.amp+","+nf(this.duration/10, 1, 2)+"s", this.drawPointX-smallPitchWidth*2/3, this.drawPointY+smallShapePicth+5); 
    }
  }
  
  void view(){
    println();
    for ( int i = 0; i < vertical_num; i++ ) {
      for ( int j = 0; j < horizontal_num; j++ ) {
        print(int(pattern[(i*horizontal_num)+j]));
      }
      println();
    }
    println();
  }
  
  void select(){
    if(hexagonalStructure){
      rect( this.drawPointX-smallPitchWidth/4, this.drawPointY-smallPitchHeight+smallShapeSize, smallPitchWidth, smallPitchHeight );
    
    }else{
      rect( this.drawPointX-smallPitchWidth+smallShapeSize, this.drawPointY-smallPitchHeight+smallShapeSize, smallPitchWidth, smallPitchHeight );
    }
    
  
  }
  
  public boolean Contains(int x, int y) {
    boolean ret = false;
    
    
    if(hexagonalStructure){
      if (drawPointX-smallShapeSize-smallShapePicth<=x && drawPointX+smallShapeSize*max_hex_num-smallShapePicth>x && drawPointY-smallPitchHeight+smallShapePicth*2/3<=y && drawPointY>y) {
        ret = true;
      }
    
    }else{
      if (drawPointX-smallPitchWidth+smallShapePicth<=x && drawPointX>x && drawPointY-smallPitchHeight+smallShapePicth*2/3<=y && drawPointY>y) {
        ret = true;
      }
    }
    return ret;
  }

}
