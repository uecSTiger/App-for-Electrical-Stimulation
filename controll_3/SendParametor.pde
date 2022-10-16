//software definitions
final int PC_ESP_STIM_PATTERN = 0xFF;
final int PC_ESP_POLA = 0xFE;
final int PC_ESP_WIDTH = 0xFD;
final int PC_ESP_AMP = 0xFC;
final int PC_ESP_MEASURE_REQUEST = 0xFA;
final int STIMLATION_STOP = 0xF9;
final int PC_ESP32_MEASURE_DATA = 0xF8;
final int PC_ESP32_MEASURE_RECIVED = 0xF7;
final int STIMLATION_START = 0xF5;

final int ESP_PC_MEASURE_RESULT = 0xFF;
final int ESP_PC_BUTTON_ON = 0xFE;


//send stimulation signal to ESP
void SendIntData(int value) {
  byte high = (byte)((value & 0xFF00) >> 8);
  byte low =  (byte)( value & 0x00FF);
  if (connectESP) {
    myPort.write(high); // 上位バイトの送信
    myPort.write(low);  // 下位バイトの送信
  }
}


void SendCharData(int value) {
  if (connectESP) myPort.write((byte)(value & 0x00FF));
}


void SendPatternData() {
  char [] pattern = new char [ELECTRODE_NUM];
  byte send=0x00;
  if (connectESP) myPort.write((byte)PC_ESP_STIM_PATTERN); 
  //println((ELECTRODE_NUM+7-1)/7);
  for (int i=0; i<(ELECTRODE_NUM+7-1)/7; i++) {
    for (int j=0; j<7; j++) {
      if((i*7)+j>=ELECTRODE_NUM)break;
      if (stimPattern[(i*7)+j]==1) send |= 0x1<<(7-1-j);
      //if (stimPattern[ElectrodeMapping[(i*7)+j]]==1) send |= 0x1<<(7-1-j);
        
    }
    if (connectESP)myPort.write(send);
    //println(send);
    send=0x00;
  }
  /*
   for (int i=0; i<ELECTRODE_NUM; i++) {
   print((int)stimPattern[i]+" ");
   if (i%7==7-1)println();
   }*/
}

/*
void SendStimulationPattern() {
 if(connectESP) myPort.write((byte)PC_ESP_STIM_PATTERN); 
 for (int pin=0; pin<ELECTRODE_NUM; pin++) {
 SendCharData(stimPattern[pin]);
 }
 }
 */

void SendStimulationPola() {
  if (connectESP) myPort.write((byte)PC_ESP_POLA); 
  SendCharData(pola);
}


void SendStimulationWidth() {
  if (connectESP) myPort.write((byte)PC_ESP_WIDTH); 
  SendIntData(pulseWidth);
}


void SendStimulationAmp() {
  if (connectESP) myPort.write((byte)PC_ESP_AMP); 
  SendIntData(amp[pola]);
}
