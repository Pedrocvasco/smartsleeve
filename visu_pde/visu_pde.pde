import processing.serial.* ;
import java.math.*;
import java.util.*;


PShape drawer; // declare objects
PShape mouseArrow;
PShape mussleArrow;
PShape[] objects = {drawer}; // array with all objects of the scene
PShape[] selected = new PShape[1]; // array with selected object to drag
boolean isDragging = false; // if is dragging, releaseObject. if is not dragging, grabObject.
boolean grab;
float[] vectorS = {0,0,0};
float[] offset = {0,0,0};
float[] input = {0,0,0};
float[] angles = {0,0};
int inputLenght = 6; // number of elements at the string array in the serial communication
String portName = Serial.list()[0]; // change the 0 to a 1 or 2 etc. to match your port
String inputValue;
Serial myPort = new Serial(this, portName, 9600);




void setup() {
  size(1100, 148, P3D); // set size of window

  

  // create shapes
  drawer = createShape(BOX, 50, 70, 10);
  drawer.setFill(color(97,28,28));
  mussleArrow = createShape(BOX, 3, 3, -1000);
  mussleArrow.setFill(color(255,3,3));
  mouseArrow = createShape(BOX, 3, 3, -1000);
  mouseArrow.setFill(color(0,255,3));
  
  // set First Selected
  selected[0] = drawer;
}

void draw() {
  //String[inputLenght] input = getSerial(myPort, inputLenght);
  //vectorS = {input[0], input[1], input[2]};
  //grab = boolean(input[3]);
  //print(angles[0]);
  //print("  ");
  //println(angles[1]);
  setLights();
  room();
  updateAngle();
  updateM();
  mouseTarget();
  mussleTarget();
  if(isDragging == true ){
    updateObjects();
  }
}  

void updateObjects(){
  pushMatrix();
  translate(width/2,0,0);
  rotateY(mouseX*(-0.02) - 20);
  translate(-width/2,0,0);
  translate(mouseX, height/1.3, -height/5);
  shape(drawer); // Draw the shape
  popMatrix();
  if (selected[0] != null) {
    selected[0].translate(0, 0, 0); // TO DO //REPLACE MOUSE X WITH DELTA SX
  }
}  
void mussleTarget(){  
  pushMatrix();
  noStroke();
  translate(width/2,height/2, -500);
  rotateY(0.4);
  rotateZ(0.3);
  //println(nvaluex);
  //println(nvaluey);
  //rotateX(angles[0]*PI/180);
  //rotateY(angles[1]*PI/180);
  translate(0, 0 , 500);
  shape(mussleArrow);
  stroke(1);
  popMatrix();
  
}

void mouseTarget(){  
  pushMatrix();
  noStroke();
  translate(width/2,height/2, 500);
  float nvaluex = min(max((mouseY-height/2)*0.01, -0.7), 0.7);
  float nvaluey = min(max((mouseX-width/2)*(-0.005), -1.3), 1.3);
  //println(nvaluex);
  //println(nvaluey);
  rotateX(nvaluex);
  rotateY(nvaluey);
  translate(0, 0 , -500);
  shape(mouseArrow);
  stroke(1);
  popMatrix();
  
}
void room() {
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
  fill(240);
  rect(0,0,width,height);
  popMatrix();
}

float[] getSerial(Serial myPort) {
  
  String[] resultS = new String[6];
  float[] resultF = new float[6];
    if ( myPort.available() > 0) // if port is avaiable
  {
    inputValue = myPort.readStringUntil('\n'); // read it and store it in value
        if (inputValue != null)
    {
      resultS = split(inputValue,";");
      resultF = parseFloat(resultS);
        }
    }
  
  return resultF;

}



void grabObject() { // TO DO
  isDragging = true;
  
}

void releaseObject() {
  isDragging = false;
  selected[0] = null;
}

float[] rotationAngleFromVector(float[] input){
 
 float[] angle = new float[2];  
 angle[0] = input[2]; 
 angle[1] = input[1];
 
 return angle;

}



void updateAngle(){
  
  angles = rotationAngleFromVector(getSerial(myPort));

}

void updateM(){
  
  if( getSerial(myPort)[3] == 1)
  {  
      isDragging = true;}
  else{
      isDragging = false;}
}


void setLights(){
  directionalLight(80, 90, 80, 0, height, -50);
  ambientLight(90,110,90);
  pointLight(50, 50, 50, width/2, height, 0);
}
