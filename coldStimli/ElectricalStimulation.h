#ifndef __ELECTRICALSTIMULATION_H__
#define __ELECTRICALSTIMULATION_H__

#define HVxxx 0  // HV507 1, HV513 0
#define HV_NUM 8 // Number of using HV elements

#include "StimPattern.h"

// output pins of HVxxx
#if HVxxx == 1        // HV507
#define HV_PIN_NUM 64
#elif HVxxx == 0      // HV513
#define HV_PIN_NUM 8
#endif

#define ELECTRODE_NUM HV_PIN_NUM*HV_NUM

// setup pins for electrical stimulation
#define SCLK 18
#define MOSI 23
#define MISO 19
#define DA_CS 22
#define AD_CS 5
#define LEDPIN 32
#define HV_DIOB 13
#define HV_BL 25
#define HV_POL 27
#define HV_CLK 14
#define HV_LE 26

// setup parametor for stimulation
#define AMP_LIMIT 201
#define WIDTH_LIMIT 501

#define DEFAULT_DATA_POLA 0
#define DEFAULT_DATA_WIDTH 50
#define DEFAULT_DATA_AMP 0 

class ElectricalStimulation {
  public:
    // datas for stimulation including stim_pattern, amplitude(PA), width(PW) and polarity,
    unsigned char stim_pattern[ELECTRODE_NUM] = { 0 };
    int impedance[ELECTRODE_NUM] = { 0 };
    float stim[ELECTRODE_NUM] = { 0 };
    unsigned char pola = DEFAULT_DATA_POLA;
    unsigned int width = DEFAULT_DATA_WIDTH;
    unsigned int amp = DEFAULT_DATA_AMP;

    ElectricalStimulation();

    void begin();
    void init() ;
    void FastScan(int usWhichPin);
    void clear();
    void stop();
    void reset_parameter();
    void LED_ON();
    void LED_OFF();
    void DAout(short DA) ;
    short DAAD(short DA) ;
    void measure();
    void stimulate();
    void sync_pattern(unsigned char pattern[ELECTRODE_NUM]);
    void sync_stim(unsigned int amp_, unsigned char pola_, unsigned int width_);
    
    bool finished() { return finished_; }

  private:
    bool initialized_;
    bool finished_;
    bool loop_;
};

#endif
