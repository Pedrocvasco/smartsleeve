import processing.serial.* ;
import java.math.*;
import java.util.*;

float[][] positions = {{width/2 + 400,height + 400,0},{width/2,height/4,height+10}} ;
int[][] colors = {{97,28,28},{140,28,128},{0,0,50},{255,0,0},{0,255,0}};
PShape drawer; // declare objects
PShape window;
PShape icon;
PShape mouseArrow;
PShape muscleArrow;
String[] shapes = {"drawer", "window"}; // array with all objects of the scene
String[] selected = new String[1]; // array with selected object to drag
boolean isDragging = true; // if is dragging, releaseObject. if is not dragging, grabObject.
boolean grab;
float[] vectorS = {0, 0, 0};
float[] offset = {0, 0, 0};
float[] input = new float[6];
float[] angles = {45, 45};
float[] anglesF = {45, 45};
float[] point = {600,600} ; 
float threshold = 200;
int inputLenght = 6; // number of elements at the string array in the serial communication
String portName = Serial.list()[0];
String inputValue;// change the 0 to a 1 or 2 etc. to match your port
Serial myPort = new Serial(this, portName, 74880);




void setup() {
  size(1920, 1080, P3D); // set size of window

  smooth(4);

  // create shapes
  icon = createShape(RECT,0,0,10,10);
  icon.setFill(color(colors[4][0], colors[4][1],colors[4][2]));
  drawer = createShape(BOX, 50, 70, 70);
  drawer.setFill(color(colors[0][0], colors[0][1],colors[0][2]));
  window = createShape(BOX, 50, 70, 70);
  window.setFill(color(colors[1][0], colors[1][1],colors[1][2]));
  muscleArrow = createShape(BOX, 3, 3, -1000);
  muscleArrow.setFill(color(colors[2][0], colors[2][1],colors[2][2]));
  mouseArrow = createShape(BOX, 3, 3, -1000);
  mouseArrow.setFill(color(colors[3][0], colors[3][1],colors[3][2]));

  // set First Selected
  selected[0] = "drawer";
}

void draw() {
  textSize(30);
  fill(10, 10, 70, 80);
  text(String.valueOf(isDragging),800,800,-400);
  /*text(String.valueOf(selected[0]),800,880,-400);
  textSize(120);
  text(String.valueOf(point[0]),800,960,-400);
  text(String.valueOf(point[1]),900,1020,-400);
  */
  //String[inputLenght] input = getSerial(myPort, inputLenght);
  //vectorS = {input[0], input[1], input[2]};
  //grab = boolean(input[3]);
  lights();
  setLights();
  room();
  updateAngle();
  updatePoint();
  updateMo();
  updateSelection();
  updateObjects();
  mouseTarget();
  muscleTarget();
  print(" PONTEIRO = ");
      print(point[0]);
      print("  ");
      println(point[1]);
      print("Threshold = ");
      print(abs(point[0] - positions[0][0]));
      print("   ");
      println(abs(point[1] - positions[0][1]));
      print(shapes[0]);
      print("   ");
      println(shapes[1]);
}  

void updatePoint() {
  if(anglesF.length>1){
  point[1] = 535 - min(max(-1*(anglesF[0]*13*PI),-900), 900) ;
  point[0] = min(max(anglesF[1]*11*PI,-920), 1020) + 950;
}
}
void updateObjects() {



  if (selected[0] == "drawer" && isDragging) {
    /*positions[0][0] = anglesF[1]*10.2*PI + width/2 ;
    positions[0][1] = 8.4*(anglesF[0]*PI) + height/2;*/
    positions[0][0] = point[0] ;
    positions[0][1] = point[1];
  }
  
    if (selected[0] == "window" && isDragging) {
    /*positions[0][0] = anglesF[1]*10.2*PI + width/2 ;
    positions[0][1] = 8.4*(anglesF[0]*PI) + height/2;*/
    positions[1][0] = point[0] ;
    positions[1][1] = point[1];
  }
  

  //Drawing objects
  pushMatrix();
  translate(positions[0][0], positions[0][1], positions[0][2]);
  rotateY(-PI/4);
  shape(drawer); // Draw the shape
  popMatrix();
  
  
  //Drawing objects
  pushMatrix();
  translate(positions[1][0], positions[1][1], positions[1][2]);
  rotateY(-PI/4);
  shape(window); // Draw the shape
  popMatrix();
  
  pushMatrix();
  translate(point[0],point[1]);
  shape(icon);
  popMatrix();
  
} 


void muscleTarget() {  
  pushMatrix();
  noStroke();
  translate(width/2, height/2, -500);
  //rotateY(0.4);
  //rotateZ(0.3);
  //println(nvaluex);
  //println(nvaluey);
  rotateX(min(max(-1*(anglesF[0]*PI/180),-0.7), 0.7));
  rotateY(min(max(anglesF[1]*PI/180,-1.3), 1.3));
  translate(0, 0, 500);
  shape(muscleArrow);
  stroke(1);
  popMatrix();
}

void mouseTarget() {  
  pushMatrix();
  noStroke();
  translate(width/2, height/2, 500);
  float nvaluex = min(max((mouseY-height/2)*0.01, -0.7), 0.7);
  float nvaluey = min(max((mouseX-width/2)*(-0.005), -1.3), 1.3);
  //println(nvaluex);
  //println(nvaluey);
  rotateX(nvaluex);
  rotateY(nvaluey);
  translate(0, 0, -500);
  shape(mouseArrow);
  stroke(1);
  popMatrix();
}
void room() {
  // left wall
  pushMatrix();
  rotateY(PI/2);
  fill(255);
  rect(0, 0, height, height);
  popMatrix();
  // right wall
  pushMatrix();
  translate(width, 0, 0);
  rotateY(PI/2);
  fill(255);
  rect(0, 0, height, height);
  popMatrix();
  // roof
  pushMatrix();
  rotateX(-PI/2);
  fill(255);
  rect(0, 0, width, height);
  popMatrix();
  // floor
  pushMatrix();
  translate(0, height, 0);
  rotateX(-PI/2);
  fill(255);
  rect(0, 0, width, height);
  popMatrix();
  // background wall
  pushMatrix();
  translate(0, 0, -height);
  fill(195);
  rect(0, 0, width, height);
  popMatrix();
}

float[] getSerial(Serial myPort, int inputLenght) {

  if ( myPort.available() > 0) // if port is avaiable
  {
    inputValue = myPort.readStringUntil('\n'); // read it and store it in value
    //print(inputValue);
    if (inputValue != null)
    { //print(inputValue);
      String resultS[]= new String[6];
      float resultF[] = new float[6];
      resultS = inputValue.split(";");
      for (int i = 0; i< resultS.length; i++) {
        //print(resultS[i]);
        //print("    ");
       
      }

      resultF = float(resultS);
      input = resultF;
    }
  }
  return input;
}





float[] rotationAngleFromVector() {
  input = getSerial(myPort, inputLenght);
  float[] angle = new float[2];  

  if ( input.length > 3) {
    angle[0] = input[2]; 
    angle[1] = input[3];
  }
  return angle;
}



void updateAngle() {

  for (int j = 0; j < angles.length; j++) {

    anglesF[j] = (rotationAngleFromVector()[j] + 5*anglesF[j])/6;
  }
}

void updateMo(){
  if(mousePressed){
    isDragging = true;
  }
  else{
    isDragging = false;
  }
  
}
void updateM() {

  if ( getSerial(myPort, inputLenght)[4] == 1)
  {  
    isDragging = true;
  } else {
    isDragging = false;
  }
}

void setLights() {
  //directionalLight(20, 30, 20, 0, height, -50);
  //ambientLight(25, 25, 20);
  // pointLight(50, 50, 50, width/2, height, 0);
}

void updateSelection() {
 

    if(abs(point[0] - positions[0][0]) < threshold && abs(point[1] - positions[0][1]) < threshold){
    selected[0] = shapes[0];
    
}
    if(abs(point[0] - positions[1][0]) < threshold && abs(point[1] - positions[1][1]) < threshold){
    selected[0] = shapes[1];
}
}
