import processing.serial.* ;
import java.math.*;
import java.util.*;


PShape drawer; // declare objects
PShape[] objects = {drawer}; // array with all objects of the scene
PShape[] selected = new PShape[1]; // array with selected object to drag
boolean isDragging = false; // if is dragging, releaseObject. if is not dragging, grabObject.
int[] vectorS;
boolean grab;


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

void grabObject() { // TO DO
  isDragging = true;
  
}

void releaseObject() {
  isDragging = false;
  selected[0] = null;
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

void setup() {
  size(1100, 148, P3D); // set size of window
  //int inputLenght = 5; // number of elements at the string array in the serial communication
  //String portName = Serial.list()[0]; // change the 0 to a 1 or 2 etc. to match your port
  //myPort = new Serial(this, portName, 9600);
  
  // texture
  PImage img = loadImage("image.jpeg");
  texture(img);
  // create shapes
  drawer = createShape(BOX, 50, 70, 10);
  drawer.setFill(color(97,28,28));
  selected[0] = drawer;
}

void draw() {
  //String[inputLenght] input = getSerial(myPort, inputLenght);
  //vectorS = {input[0], input[1], input[2]};
  //grab = boolean(input[3]);
  directionalLight(80, 90, 80, 0, height, -50);
  ambientLight(90,110,90);
 // pointLight(50, 50, 50, width/2, height, 0);
  
  room();
  pushMatrix();
  translate(-24, height/1.7, -height/5);
  shape(drawer); // Draw the shape
  popMatrix();
  if (selected[0] != null) {
    selected[0].translate(mouseX, 0, 0); // TO DO //REPLACE MOUSE X WITH DELTA SX
  }
}  
