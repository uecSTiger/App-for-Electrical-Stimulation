#ifndef __SENDSERIAL_H__
#define __SENDSERIAL_H__

#include "ElectricalStimulation.h"

// connect to PC (Header)
#define ESP32_PC_RECEIVE_FINISHED 0xFE
#define ESP32_PC_MEASURE_RESULT 0xFF
#define ESP_PC_LIMIT 0xFC
#define ESP_PC_BUTTON_ON 0xFE

#ifndef __ELECTRICALSTIMULATION_H__
#define AMP_LIMIT 201
#define WIDTH_LIMIT 501
#endif

class SendSerial{
  public:
    int contact_area[ELECTRODE_NUM] = { 0 };
  
    SendSerial();
  
    void begin(int board = 1000000);
    void clear();
    void init();
    void write_byte(byte send_data);
    //void write_int(int send_data);
    void send();
    void flush2();
    void output();
    void sync_contact_area(int area[ELECTRODE_NUM]);
    void pushButton();

    void pushButtonFlag() { buttonFlag_ = true; }

  private:
    bool initialized_;
    bool buttonFlag_;
};

#endif
