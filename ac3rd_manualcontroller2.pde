import processing.serial.*;

PrintWriter textLog; //create a log for our data
String headerList = "time,tailAngle,rudderAngle,heading,headingDesired,wingAngle,windDir,routeChoice,imu.a.x,imu.a.y,imu.a.z,imu.m.x,imu.m.y,imu.m.z";
Serial xBee;  // Create object from Serial class

boolean sendCommand; //switch to send a command to AC3RD
boolean autoControl; //true for auto control or false for manual control
int command = 0; //command for AC3RD
int heading = 0; //assigned heading from controller
int tailAngle = 75; //tail angle from controller 75 is zero
int rudderAngle = 90; //rudder angle from  90 is zero
int deadZone = 45; //default deadZone
int liftTailAngle = 5; //default liftTailAngle
int maxRudderAngle = 45; //default maxRudderAngle

long timer;

void setup() 
{
  fullScreen();
  String portName = Serial.list()[0];
  xBee = new Serial(this, portName, 19200);
  xBee.bufferUntil('\n');

  String logString = "AC3RDlog_"+str(hour())+"_"+str(minute())+"_"+str(second())+"_"+str(day())+"_"+str(month())+"_"+str(year())+".txt";
  textLog = createWriter(logString); //create the .txt log
  
  textLog.println(headerList);
}

void draw() {   
    size(400,400);
    background(0);
    textSize(30);
    textAlign(CENTER,CENTER);
    fill(255);
    stroke(255);
    strokeWeight(5);
    
    if (autoControl){
      int heightInterval = height/;
      int widthInterval = width/4;
      
      line(width/2,0,width/2,height);
      
      for (int i = 0; i <= dataList.length-1; i++){
        line(0,heightInterval*i,width,heightInterval*i);
        text(headerList[i],widthInterval,heightInterval*(i+1)-heightInterval/2);
        text(dataList[i],widthInterval*3,heightInterval*(i+1)-heightInterval/2);
      }
      line(0,height,width,height);
    
    ///Auto control commands/////
    if (autoControl && sendCommand){ //send command when enter is pressed
        sendCommand();
    }
    /////Manual control commands sent every 50ms////
    if ( autoControl == false && millis()-timer > 50){
        timer = millis();
        sendCommand();
    }
    
}

void serialEvent(Serial p) { 
  String inString = p.readString(); 
  textLog.print(inString);
} 

void sendCommand(){
      xBee.write(command);
      if (command == 1){
        xBee.write(',');
        xBee.write(heading);
        xBee.write('\n');
      }
      if (command == 13){
        xBee.write(',');
        xBee.write(rudderAngle);
        xBee.write('\n');
      }
      if (command == 14){
        xBee.write(',');
        xBee.write(tailAngle);
        xBee.write('\n');
      }
      if (command == 15){
        xBee.write(',');
        xBee.write(deadZone);
        xBee.write('\n');
      }
      if (command == 16){
        xBee.write(',');
        xBee.write(liftTailAngle);
        xBee.write('\n');
      }
      if (command == 17){
        xBee.write(',');
        xBee.write(maxRudderAngle);
        xBee.write('\n');
      }
      sendCommand = false;
    }
  
void keyPressed(){
  if (key == ENTER || key == RETURN){
   sendCommand = true;}
  if (key == CONTROL){ //switch auto or manual
   if (autoControl){
     autoControl = false;}
   if (!autoControl){
     autoControl = true;}
  }
    
  ///////Commands for running the automatic control code//////
  if (autoControl){
  if (key == UP){ //N
    heading = 0;
    command = 1;}
  if (key == LEFT){ //W
    heading = 270;
    command = 1;}
  if (key == DOWN){ //S
    heading = 180;
    command = 1;}
  if (key == RIGHT){ //E
    heading = 90;
    command = 1;}
  if (key == 'q' || key == 'Q'){ //Advance heading by -1 degree 
    heading += -1;
    command = 1;}
  if (key == 'e' || key == 'E'){ //Advance heading by 1 degree
    heading += 1;
    command = 1;}
  if (key == '1'){ //Tail servo flip
    command = 11;} 
  if (key == '2'){ //Rudder servo flip
    command = 12;}
  if (key == '-' || key == '_'){ //add -1 degree to deadZone
    deadZone += -1;
    command = 15;} 
  if (key == '=' || key == '+'){ //add +1 degree to deadZone
    deadZone += 1;
    command = 15;}
  if (key == '['){ //add -1 to lift tail angle
    liftTailAngle += -1;
    command = 16;} 
  if (key == ']'){ //add +1 to lift tail angle
    liftTailAngle += 1;
    command = 16;}
  if (key == '['){ //add -1 to max rudder angle
    maxRudderAngle += -1;
    command = 17;} 
  if (key == ']'){ //add +1 to max rudder angle
    maxRudderangle += 1;
    command = 17;}
  }
    
  ////For manual control//// 
  if (!autoControl){
    if (key == 'a' || key == 'A'){ //Advance tail angle by -1 degree 
      heading += -1;
      command = 1;}
    if (key == 'd' || key == 'D'){ //Advance tail by 1 degree
      heading += 1;
      command = 1;}
    if (key == 'j' || key == 'J'){ //Advance rudder by -1 degree 
      heading += -1;
      command = 13;}
    if (key == 'l' || key == 'L'){ //Advance rudder by 1 degree
      heading += 1;
      command = 14;}
  }
  
  
  if (key == ESC){
    textLog.flush();
    exit();
  }
}