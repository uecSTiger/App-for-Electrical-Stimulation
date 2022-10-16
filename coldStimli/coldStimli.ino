/* 電気刺激による額への温度感覚提示*/
/* Presentation the cold sensation to foreheads by using electrical stimulation */
#include "SendSerial.h"
#include "ElectricalStimulation.h"
#include "RecieveSerial.h"
#include "BluetoothSerial.h"

#define CONNECT SERIAL        // select connected mode with serial or Bluetooth

SendSerial sserial = SendSerial();
RecieveSerial rserial = RecieveSerial();
ElectricalStimulation stim = ElectricalStimulation();

#define BUTTON_PIN 17

#define SERIAL 1
#define BLE 0
#define bleName "ESP32-BLE"   // name when connect to Bluetooh device

TaskHandle_t thp[3];//for storing multi-threaded task handles

BluetoothSerial SerialBT;
#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run `make menuconfig` to and enable it
#endif

void setup() {
  // initilizing the header
  sserial.begin(921600);
  rserial.begin(921600);
  stim.begin();
  stim.init();

  pinMode(BUTTON_PIN, INPUT);
  
  // initilized stimulation pattern
  for(int i=0;i<ELECTRODE_NUM; i++){
      stim.stim_pattern[i] = 0;
  }
  
  //内容は([タスク名], "[タスク名]", [スタックメモリサイズ(4096or8192)],
  //      NULL, [タスク優先順位](1-24,大きいほど優先順位が高い)],
  //      [宣言したタスクハンドルのポインタ(&thp[0])], [Core ID(0 or 1)]); 
  // Main CPU Core
  xTaskCreatePinnedToCore(Core0_serial, "Core0_serial", 8196, NULL, 7, &thp[0], 0);
  // Sub CPU Core
  xTaskCreatePinnedToCore(Core1_stimUpdate, "Core1_stimUpdate", 4096, NULL, 3, &thp[1], 1);
  xTaskCreatePinnedToCore(Core1_LED, "Core1_LED", 4096, NULL, 1, &thp[2], 1);
}


// control electrical stimulatoin
void loop() {
  if (!rserial.stopped()) { // select the stimulation or not
    if(rserial.measure()){  // select the stimulation mode with measurement or stimulation only
      stim.measure(); 
        
    }else {
      stim.stimulate();
    }
    
  }else {
    stim.stop();
  }
}

// connect to PC, and using received data to control the modes or pattern status
void Core0_serial(void *args) {
  char rcv;
  while (1) {
    if (rserial.available2() > 0) { // if received data, change the modes or pattern status using it
      rcv = rserial.recieve_byte();
      rserial.recieve(rcv);
    }
    if(rserial.requesting()){ // send data to PC when received request
      sserial.sync_contact_area(stim.impedance); // synchronize impedance data
      sserial.send();
    }
    sserial.pushButton();
    delay(1); // to avoid watch dog
  }
}

// if updated the pattern status, change stimulation data
void Core1_stimUpdate(void *args) {
  while (1) { 
    if (rserial.updating_parametor()) { // when update the pola or pluse amplitude, pluse width
      stim.sync_stim(rserial.data_buffer.amp, rserial.data_buffer.pola, rserial.data_buffer.width);
      rserial.updated_parametor();
    }
    
    if(rserial.updating_pattern()){ // when update the stimulation pattern
      stim.sync_pattern(rserial.data_buffer.pattern);
      rserial.updated_pattern();
    }
    
    delay(1); // to avoid watch dog
  }
}

// control the LED and others by time
void Core1_LED(void *args) {
  int t;
  
  while (1) { 
    t = micros();

    if ((t / 2000000) % 2 == 0) {
      stim.LED_ON();
    } else {
      stim.LED_OFF();
    }
    delay(1); // to avoid watch dog
  }
}
