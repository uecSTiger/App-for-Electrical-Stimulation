#ifndef __RECIEVESERIAL_H__
#define __RECIEVESERIAL_H__

#include "ElectricalStimulation.h"

// connect from PC (Header)
#define PC_ESP32_STIM_PATTERN 0xFF
#define PC_ESP32_POLA 0xFE
#define PC_ESP32_WIDTH 0xFD
#define PC_ESP32_AMP 0xFC
#define PC_ESP32_MEASURE_REQUEST 0xFA 
#define PC_ESP32_STIMLATION_STOP 0xF9
#define PC_ESP32_MEASURE_DATA 0xF8
#define PC_ESP32_HAND_DATA 0xF7
#define PC_ESP32_MEASURE_RECIVED 0xF7
#define PC_ESP32_STIMLATION_START 0xF5

#ifndef __ELECTRICALSTIMULATION_H__
#define AMP_LIMIT 201
#define WIDTH_LIMIT 501
#define DEFAULT_DATA_POLA 0
#define DEFAULT_DATA_WIDTH 50
#define DEFAULT_DATA_AMP 0 
#endif


class RecieveSerial{
  public:
    typedef struct{
      unsigned char pattern[ELECTRODE_NUM];      
      unsigned char pola;
      unsigned int width;
      unsigned int amp;
    }recieve_data;

    recieve_data data_buffer;
    //recieve_data data_buffer[];
    
    RecieveSerial();
    void begin(int board=1000000);
    void clear();
    void output();
    void recieve(int rcv);
    void recieve_pattern();
    void recieve_width();
    void recieve_pola();
    void recieve_amp();
    int available2();
    byte recieve_byte();
    int recieve_int();
    char recieve_char();
    
    void updated_parametor() { update_parametor_ = false; }
    void updated_pattern() { update_pattern_ = false; }
    void respond_to_request() { requesting_ = false; }
    bool requesting() { return requesting_; }
    bool recieving() { return recieving_; }
    bool finished() { return finished_; }
    bool updating_parametor() { return update_parametor_; }
    bool updating_pattern() { return update_pattern_; }
    bool measure() { return measure_; }
    bool stopped() { return stopped_; }

  private:
    bool initialized_;
    bool recieving_;
    bool finished_;
    bool update_parametor_;
    bool update_pattern_;
    bool stopped_;
    bool measure_;
    bool request_;
    bool requesting_;
};

#endif
