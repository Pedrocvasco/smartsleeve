import processing.serial.* ;
import java.math.*;


PShape drawer;


String[] getSerial(Serial myPort, int inputLenght) {
  String inputValue;
  String[] result = new String[inputLenght];
  if ( myPort.available() > 0) // if port is avaiable
  {
    inputValue = myPort.readStringUntil('\n'); // read it and store it in value
    if (inputValue != null)
    {
      result = inputValue.split(";");  
    }  
  }
  
  return result;
}


void createRoom() {
  // left wall
  pushMatrix();
  rotateY(PI/2);
  fill(255);
  rect(0,0,height,height);
  popMatrix();
  // right wall
  pushMatrix();
  translate(width,0,0);
  rotateY(PI/2);
  fill(255);
  rect(0,0,height,height);
  popMatrix();
  // roof
  pushMatrix();
  rotateX(-PI/2);
  fill(255);
  rect(0,0,width,height);
  popMatrix();
  // floor
  pushMatrix();
  translate(0,height,0);
  rotateX(-PI/2);
  fill(255);
  rect(0,0,width,height);
  popMatrix();
  // background wall
  pushMatrix();
  translate(0,0,-height);
  fill(#1d69e2);
  rect(0,0,width,height);
  popMatrix();
}


void setup() {
  size(1100, 148, P3D); // set size of window
  //int inputLenght = 5; // number of elements at the string array in the serial communication
  //String portName = Serial.list()[0]; // change the 0 to a 1 or 2 etc. to match your port
  //myPort = new Serial(this, portName, 9600);
  
}


void draw() {
  //String[inputLenght] input = getSerial(myPort, inputLenght);
  createRoom();
}
