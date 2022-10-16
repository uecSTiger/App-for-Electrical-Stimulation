#include "RecieveSerial.h"
// byte recieve_byte()
// char recieve_char()
// int recieve_int()

#ifndef MIN
  #define MIN(a,b)  (((a) < (b)) ? (a) : (b))
#endif

#ifndef MAX
  #define MAX(a,b)  (((a) > (b)) ? (a) : (b))
#endif

#ifndef ARRAY_NUM
  #define ARRAY_NUM(a) (sizeof(a) / sizeof(a[0]))
#endif

// initialized private variable
RecieveSerial::RecieveSerial()
: initialized_(false)
, recieving_(false)
, finished_(false)
, update_parametor_(false)
, update_pattern_(false)
, stopped_(false)
, measure_(false)
, request_(false)
{
    clear();
}

// initialized recieve data
void RecieveSerial::clear(){  
  for (int i=0; i<ELECTRODE_NUM; i++){
    data_buffer.pattern[i] = 0;
  }
  data_buffer.pola = DEFAULT_DATA_POLA;
  data_buffer.width = DEFAULT_DATA_WIDTH;
  data_buffer.amp = DEFAULT_DATA_AMP;
  if(CONNECT) while(Serial.available()>0)recieve_byte();
  else while(SerialBT.available()>0)recieve_byte();
}

// connect to PC through Serial or Bluetooth
void RecieveSerial::begin(int board){
   #define SERIAL_START_RECIEVE
   #ifndef SERIAL_START_SEND
     if(CONNECT) Serial.begin(board);
     else SerialBT.begin(bleName);
   #endif
   initialized_ = true;
}

// output all data to screen or cmd prompt
void RecieveSerial::output(){
  printf("pattern:\n");
  for (int i=0; i<ELECTRODE_NUM; i++){
    printf("pattern[%d]: %d ", i, data_buffer.pattern[i]);
    if(i%8==7)printf("\n");
  }
  printf("amp: %d\n", data_buffer.amp);
  printf("pola: %d\n", data_buffer.pola);
  printf("width: %d\n", data_buffer.width);
}

int RecieveSerial::available2(){
  if(CONNECT) return Serial.available();
  else return SerialBT.available();
}

byte RecieveSerial::recieve_byte(){
  if(CONNECT) return Serial.read();
  else return SerialBT.read();
}

int RecieveSerial::recieve_int(){
  while(available2()<2);
  byte high = recieve_byte();
  byte low  = recieve_byte();
  int recieve_data = high * 256 + low;

  return recieve_data; 
}

char RecieveSerial::recieve_char(){
  while(available2()<1);
  int recieve_data = recieve_byte();

  return recieve_data; 
}


// recieve data from PC 
void RecieveSerial::recieve(int rcv){
  switch(rcv){
    case PC_ESP32_STIM_PATTERN:
      sserial.pushButtonFlag();
      recieve_pattern();
      break;
      
    case PC_ESP32_POLA:
      recieve_pola();
      break;
      
    case PC_ESP32_WIDTH:
      recieve_width();
      break;
  
    case PC_ESP32_AMP:
      recieve_amp();
      break;
  
    case PC_ESP32_STIMLATION_STOP:
      stopped_ = true;
      break;

    case PC_ESP32_STIMLATION_START:
      stopped_ = false;
      break;
      
    case PC_ESP32_MEASURE_REQUEST:
      measure_ = !measure_;
      break;

    case PC_ESP32_MEASURE_DATA:
        requesting_ = true;
      break;

    case PC_ESP32_MEASURE_RECIVED:
        requesting_ = false;
        break;
        
    default:
      break;
  }
}


// recieve stimulation pattern data from PC(0, 1) such as 0XXXXXXX, top of 0 is header and others are pattern status
void RecieveSerial::recieve_pattern(){
  byte inByte;
  while(available2()<ELECTRODE_NUM/7);
  
  for(int i=0; i< (ELECTRODE_NUM+7-1)/7;i++){
    inByte = recieve_byte();
    for(int j=0;j<7;j++){
      if((i*7)+j>=ELECTRODE_NUM)break;
      data_buffer.pattern[i*7+j] = (char)((inByte & (1<<6-j))>>(6-j));
    }
  }
  update_pattern_ = true;
}
/*
void RecieveSerial::recieve_pattern(){
  while(Serial.available()<ELECTRODE_NUM);
  
  for(int i=0; i<ELECTRODE_NUM; i++){
    data_buffer.pattern[i] = Serial.read();
    
  }
  update_pattern_ = true;
}*/


// recieve pola data from PC(0, 1)
void RecieveSerial::recieve_pola(){
  if(available2()>0){
    data_buffer.pola = recieve_char(); 
    update_parametor_ = true;
  }
  
  if(data_buffer.pola > 1 || data_buffer.pola<0){
    data_buffer.pola = 0;
  }
}

// recieve Pulse Width data from PC(0~500)
void RecieveSerial::recieve_width(){
  if(available2()>0){
    data_buffer.width = recieve_int();
    update_parametor_ = true;
  }

  if(data_buffer.width > WIDTH_LIMIT || data_buffer.width<0){
    data_buffer.width = 50;
  }
}

// recieve Pulse Amplitude data from PC(0-200)
void RecieveSerial::recieve_amp(){
  if(available2()>0){
    data_buffer.amp = recieve_int();
    update_parametor_ = true;
  }

  if(data_buffer.amp > AMP_LIMIT || data_buffer.amp < 0){
    data_buffer.amp = 0;
  }
}
