#include "SendSerial.h"

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
SendSerial::SendSerial()
: initialized_(false)
, buttonFlag_(false)
{
    clear();
}


// initialized sending data
void SendSerial::clear(){
  for (int i=0; i<ELECTRODE_NUM; i++){
    contact_area[i] = 0;
  }
}

// connect to PC through Serial
void SendSerial::begin(int board){
   #define SERIAL_START_SEND
   #ifndef SERIAL_START_RECIEVE
     if(CONNECT) Serial.begin(board);
     else SerialBT.begin(bleName);
   #endif
   initialized_ = true;
}

void SendSerial::init(){
   // default 値をprocessingと同期
}

// output all data to screen or cmd prompt
void SendSerial::output(){
  printf("strength:\n");
  for (int i=0; i<ELECTRODE_NUM; i++){
    printf("%d ", contact_area[i]);
    if(i%8==7)printf("\n");
  }
}

// synchronize with retrieved data
void SendSerial::sync_contact_area(int area[ELECTRODE_NUM]){
  for (int i=0; i<ELECTRODE_NUM; i++){
    contact_area[i] = area[i];
  }
}

void SendSerial::write_byte(byte send_data){
  if(CONNECT){
    Serial.write(send_data);
  }else{
    SerialBT.write(send_data);
  }
}


void SendSerial::flush2(){
  if(CONNECT){
    Serial.flush();
  }else{
    SerialBT.flush();
  }
}


// sending data to PC through Serial or Bluetooth
void SendSerial::send(){
  write_byte(ESP32_PC_MEASURE_RESULT);
  
  for(int pin=0; pin<ELECTRODE_NUM; pin++){
    contact_area[pin] = contact_area[pin] & 0x0FFF;
    //write_int((contact_area[pin]&0x0FC0)>>6);
    //write_int(contact_area[pin]&0x003F);
    write_byte((contact_area[pin]&0x0FC0)>>6);
    write_byte(contact_area[pin]&0x003F);
  }
  
  flush2();
}


void SendSerial::pushButton(){
  if(digitalRead(BUTTON_PIN) == HIGH && buttonFlag_){
    Serial.write(ESP_PC_BUTTON_ON);
    delay(5);
    buttonFlag_ = false;
  }
}
