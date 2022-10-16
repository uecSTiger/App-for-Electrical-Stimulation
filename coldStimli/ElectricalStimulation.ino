#include "ElectricalStimulation.h"

#ifndef SPI.h
#include <SPI.h>
#endif


ElectricalStimulation::ElectricalStimulation()
  : initialized_(false)
  , loop_(false)
  , finished_(false)
{
}

void ElectricalStimulation::clear() {
  FastScan(ELECTRODE_NUM);
}

// initialized
// setup pins and SPI values for stimulation
void ElectricalStimulation::begin() {
  pinMode(LEDPIN, OUTPUT);
  pinMode(DA_CS, OUTPUT);
  pinMode(AD_CS, OUTPUT);
  pinMode(HV_DIOB, OUTPUT);
  pinMode(HV_BL, OUTPUT);
  pinMode(HV_POL, OUTPUT);
  pinMode(HV_CLK, OUTPUT);
  pinMode(HV_LE, OUTPUT);
  // SPI.begin(SCLK, MISO, MOSI, DA_CS);
  SPI.begin(SCLK, MISO, MOSI);
  SPI.setFrequency(48000000);
  SPI.setDataMode(SPI_MODE0);
  SPI.setHwCs(true);
  initialized_ = true;
}

// stop the electrical stimulation
void ElectricalStimulation::stop() {
  for (int pin = 0; pin < ELECTRODE_NUM; pin++) {
    FastScan(pin);
    digitalWrite(HV_BL, HIGH);
    digitalWrite(HV_LE, HIGH);
    digitalWrite(HV_LE, LOW);
    DAout(0);
    digitalWrite(HV_BL, LOW);
    delayMicroseconds(10);
  }
  delayMicroseconds(10);
}

// sets the LED on
void ElectricalStimulation::LED_ON(){
  digitalWrite(LEDPIN, HIGH);   
}
// sets the LED off
void ElectricalStimulation::LED_OFF(){
  digitalWrite(LEDPIN, LOW);    
}

// reset the stimulaton parametor to default
void ElectricalStimulation::reset_parameter(){
  pola = DEFAULT_DATA_POLA;
  width = DEFAULT_DATA_WIDTH;
  amp = DEFAULT_DATA_AMP;
}

// stimli the usWhichPin. The number of usWhichPin is need to start with Pin0 Sequentially.
void ElectricalStimulation::FastScan(int usWhichPin) {
  int ii, pin;
  static int pos;

  //Load S/R
  //digitalWrite(HV_BL, HIGH);
  digitalWrite(HV_LE, LOW);

  if (usWhichPin == 0) {
    digitalWrite(HV_DIOB, HIGH);
    digitalWrite(HV_CLK, HIGH);
    digitalWrite(HV_CLK, LOW);
    pos = 0;
  } else {
    digitalWrite(HV_DIOB, LOW);
    pin = usWhichPin - pos;
    for (ii = 0; ii < pin; ii++) {
      digitalWrite(HV_CLK, HIGH);
      digitalWrite(HV_CLK, LOW);
    }
    pos = usWhichPin;
  }
  digitalWrite(HV_LE, HIGH); // 追加
}


void ElectricalStimulation::init() {
  int pin;

  digitalWrite(HV_POL, HIGH);
  digitalWrite(HV_BL, LOW);
  digitalWrite(HV_LE, LOW);
  digitalWrite(HV_CLK, LOW);

  digitalWrite(HV_BL, HIGH);
  digitalWrite(HV_DIOB, LOW);
  for (pin = 0; pin < ELECTRODE_NUM; pin++) {
    digitalWrite(HV_CLK, HIGH);
    digitalWrite(HV_CLK, LOW);
  }

  digitalWrite(HV_LE, HIGH);
  digitalWrite(HV_LE, LOW);
  digitalWrite(HV_BL, LOW);
}

// DA is ampulify of electrical stimuli.
void ElectricalStimulation::DAout(short DA) {
  digitalWrite(DA_CS, LOW);        //enable clock
  SPI.transfer16(DA << 2);
  digitalWrite(DA_CS, HIGH);       //disable clock and load data
}


// DA and get the voltage of each pin.
short ElectricalStimulation::DAAD(short DA) {
  short AD;
  digitalWrite(DA_CS, LOW);     //enable clock
  digitalWrite(AD_CS, LOW);     //enable clock
  AD = SPI.transfer16(DA << 2);
  digitalWrite(DA_CS, HIGH);    //disable clock and load data
  digitalWrite(AD_CS, HIGH);
  //return AD >> 2;               //bottom 2bits are unnecessary
  return AD;   // 12bit data
}


// measures the impedance of the area; contact with the electrode
void ElectricalStimulation::measure() {
  int pin, i;

  //Stimulation
  FastScan(0);
  for (pin = 0; pin < ELECTRODE_NUM; pin++) {
    if (stim_pattern[pin] != 0) {
      if (pin != 0) {
        FastScan(pin);
      }
      digitalWrite(HV_BL, HIGH);
      digitalWrite(HV_LE, HIGH);
      digitalWrite(HV_LE, LOW);
      if (pola == 1) {
        //Cathodic Stimulation
        digitalWrite(HV_POL, LOW);
      } else {
        //Anodic Stimulation
        digitalWrite(HV_POL, HIGH);
      }
      //50us stimulation
      DAAD(amp<<4); //0-5mA. Simultaneous DA and AD. 2.0us
      delayMicroseconds(width/2);
      impedance[pin] = DAAD(amp<<4); //0-5mA. Simultaneous DA and AD. 2.0us
      delayMicroseconds(width/2);
      //impedance[pin] = DAAD(0);
      DAAD(0);
      digitalWrite(HV_BL, LOW);
      delayMicroseconds(150);
    }
  }
  
  clear();    //cleaning
  digitalWrite(HV_LE, HIGH);
  digitalWrite(HV_LE, LOW);
  digitalWrite(HV_BL, LOW);
  delay(10);
}

void ElectricalStimulation::stimulate(){
  FastScan(0);
    for (int ch = 0; ch < ELECTRODE_NUM; ch++) {
      if (stim_pattern[ch] != 0) {
        if (ch != 0) {
          FastScan(ch);
        }
        if(pola == 1){//Cathodic Stimulation
          digitalWrite(HV_POL, LOW);
          DAAD(amp<<4);
          //DAAD(amp<<4);
          delayMicroseconds(width);
          DAAD(0);
          digitalWrite(HV_POL, HIGH); //added (POL=1 & BL=0 means ALL GND)
          digitalWrite(HV_BL, LOW);
          DAAD(0);
          digitalWrite(HV_BL, HIGH); //added
          delayMicroseconds(150);
          
        }else{//Anodic Stimulation
          digitalWrite(HV_BL, HIGH);
          digitalWrite(HV_LE, HIGH);
          digitalWrite(HV_LE, LOW);
          digitalWrite(HV_POL, HIGH);
          //50us stimulation
          DAout(amp<<4); //0-5mA. Simultaneous DA and AD. 2.0us
          delayMicroseconds(width);
          DAout(0);
          digitalWrite(HV_BL, LOW);
          delayMicroseconds(150);
        }
        
     }
  }
    clear();    //cleaning
    if(pola != 1){
      digitalWrite(HV_LE, HIGH);
      digitalWrite(HV_LE, LOW);
      digitalWrite(HV_BL, LOW);
    }
    delay(10); 
}



void ElectricalStimulation::sync_pattern(unsigned char pattern[ELECTRODE_NUM]){
  for(int i=0; i<ELECTRODE_NUM; i++){
    stim_pattern[ElectrodeMapping[i]] = pattern[i]; 
  }
}


void ElectricalStimulation::sync_stim(unsigned int amp_, unsigned char pola_, unsigned int width_){
  /*
  if(pola == pola_){
    if(amp-amp_>-10 || amp-amp_<10)  amp = amp_;
  }else{
    amp = amp_;
  }*/
  amp = amp_;
  pola = pola_;
  if(width-width_>-60 || width-width_<60)  width = width_;  
}
