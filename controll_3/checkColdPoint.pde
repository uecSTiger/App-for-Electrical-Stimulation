void CheckColdPoint() { //<>// //<>// //<>// //<>//
/*
  int inByte;// https://garretlab.web.fc2.com/arduino_reference/language/functions/communication/serial/readBytesUntil.html
  println("hhhh");
  
  if (myPort.available()>1) {
    inByte = myPort.read();

    // println("data: ", inByte);

    if (inByte == ESP_PC_BUTTON_ON) {
         println("data");
    } else {
      myPort.readBytesUntil(ESP_PC_BUTTON_ON);
      if (myPort.available()>0) {
         println("data2");
        inByte = myPort.read();
        }   
      }
    }*/
  
    
  int inByte;
  if (connectESP) {
    if (myPort.available()>0) {
      inByte = myPort.read();
      //println("hhh");
        if (inByte == ESP_PC_BUTTON_ON) {
           println("data2");
           println(temperatureOccurFlag);
           if(temperatureOccurFlag){
             println("2");
             patternList.add(new Pattern(stimPattern, pola, amp[pola],duration));
             temperatureOccurFlag = false;
           }
        } 
    }
  }
    
}
