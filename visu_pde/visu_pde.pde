import processing.serial.* ;
import java.math.*;
import java.util.*;

float[][] positions = {
{-360,height + 900,-500},
{width/2 + 230, height + 400,-100},
{width/2 + 1950, height + 950 ,-200},
{2400, 500 + 2*height, - 1050  },
{width/2 + 1150, 0,-200},
{width/2 + 1250, height + 750 ,-200},
{width/2 + 230, height + 400,-100}} ;

int[][] colors = {{47,14,14},{70,14,63},{120,76,34},{0,0,25},{125,0,0},{0,125,0},{100,100,13},{125,125,125},{125,125,0}};
PShape drawer; // declare objects
PShape window;
PShape windowway;
PShape lamp;
PShape box;
PShape puff;
PShape door;
PShape doorway;
PShape icon;
PShape mouseArrow;
PShape muscleArrow;
String[] shapes = {"drawer", "window", "puff", "door","box","lamp"}; // array with all objects of the scene
String[] selected = new String[1]; // array with selected object to drag
boolean isDragging = true; // if is dragging, releaseObject. if is not dragging, grabObject.
boolean grab;
float[] vectorS = {0, 0, 0};
float[] offset = {0, 0, 0};
float[] input = new float[6];
float[] angles = {45, 45};
float[] anglesF = {45, 45};
float[] point = {600,600} ; 
float threshold = 100;
int inputLenght = 6; // number of elements at the string array in the serial communication
String portName = Serial.list()[0];
String inputValue;// change the 0 to a 1 or 2 etc. to match your port
Serial myPort = new Serial(this, portName, 74880);
boolean thresh1;
boolean thresh2;
boolean thresh3;
boolean thresh4;
boolean thresh5;
boolean thresh6;
float doorAngle = 0;
float doorAngleoff = 0;
float doorGrabValue = 0;
float doorReleaseValue = 0;
int doorGrab=0;
float lampValue= 10;



void setup() {
  size(2400, 1050, P3D); // set size of window

  smooth(4);

  // create shapes
  //noCursor();
  icon = createShape(RECT,0,0,10,10);
  icon.setFill(color(colors[4][0], colors[4][1],colors[4][2]));
  puff = createShape(SPHERE,210);
  puff.setFill(color(colors[5][0], colors[5][1],colors[5][2]));
  drawer = createShape(BOX, 730, 70, 840);
  drawer.setFill(color(colors[0][0], colors[0][1],colors[0][2]));
  window = createShape(BOX, 20, 270, 470);
  window.setFill(color(colors[1][0], colors[1][1],colors[1][2]));
  windowway = createShape(BOX ,10 ,260, 460);
  windowway.setFill(color(0,10,15));
  door = createShape(BOX ,590, 750 , 20);
  door.setFill(color(colors[6][0], colors[6][1],colors[6][2]));
  doorway = createShape(BOX ,580, 740 , 10);
  doorway.setFill(color(0,10,15));
  box = createShape(BOX , 50,50,50);
  box.setFill(color(colors[8][0], colors[8][1],colors[8][2]));
  lamp = createShape(SPHERE,40);
  lamp.setFill(color(colors[7][0], colors[7][1],colors[7][2]));
 
  muscleArrow = createShape(BOX, 3, 3, -1000);
  muscleArrow.setFill(color(colors[2][0], colors[2][1],colors[2][2]));
  mouseArrow = createShape(BOX, 3, 3, -1000);
  mouseArrow.setFill(color(colors[3][0], colors[3][1],colors[3][2]));
  

  // set First Selected
  selected[0] = "drawer";
}

void draw() {
  
  lights();
  setLights();
  room();
  updateAngle();
  updatePoint();
  updateM();
  updateSelection();
  updateObjects();
  //mouseTarget();
  muscleTarget();
  printinfo();    
  updateSelection();
  colorUpdate();
}  

void printinfo(){
  
     textSize(60);
     fill(10, 10, 10, 180);
     if(isDragging){
     text("Grabbed",1000,150,-200);
     }
     else{
        text("Free",1000,150,-200);
     }
     text(selected[0],1265,150,-200);
      print("PONTEIRO = ");
      print(point[0]);
      print("  ");
      println(point[1]);
      print("Positions = ");
      print(positions[0][0]+"  ");
      print(positions[0][1]+"  ");
      print(positions[0][2]+"  ");
      print(positions[1][0]+"  ");
      print(positions[1][1]+"  ");
      print(positions[1][2]+"  ");
      print(positions[2][0]+"  ");
      print(positions[2][1]+"  ");
      print(positions[2][2]+"  ");
      print(positions[3][0]+"  ");
      print(positions[3][1]+"  ");
      println(positions[3][2]+"  ");
      print("Threshold = ");
      print(abs(point[0] - positions[0][0] -760));
      print("   ");
      print(abs(point[1] - positions[0][1] + 174));
      print("   ");
      print(abs(point[0] - positions[1][0]));
      print("   ");
      print(abs(point[1] - positions[1][1]));
      print("   ");
      print(abs(point[0] - positions[2][0])-20);
      print("   ");
      print(abs(point[1] - positions[2][2] - 1050));
      print("   ");
      print(abs(point[0] - positions[3][0]));
      print("   ");
      print(abs(point[1] - positions[3][1]));
      print("   ");
      print(abs(point[0] - positions[4][0]));
      print("   ");
      print(abs(point[1] - positions[4][1]));
      print("   ");
      print(abs(point[0] - positions[5][0]));
      print("   ");
      print(abs(point[1] - positions[5][1]));
      println("   ");
      print("Selected = ");
      println(selected[0]);
      println("lampValue = " + lampValue);
      //println("doorReleaseValue   doorAngle   doorAngleoff  doorGrabValue   doorReleaseValue  doorGrab");
      //println(doorReleaseValue + "  " + doorAngle + "  " + doorAngleoff + "  " + doorGrabValue  + "  " + doorReleaseValue + "  " + doorGrab);


}

void updatePoint() {
  if(anglesF.length>1){
  point[1] = 525 - min(max(-1*(anglesF[0]*13*PI),-900), 900) ;
  point[0] = min(max(anglesF[1]*11*PI,-920), 1020) + 1200;
  
  
}
}
void updatePointo() {
  if(anglesF.length>1){
  point[1] = mouseY ;
  point[0] = mouseX ;
}


}
void updateObjects() {



  if (selected[0] == "drawer" && isDragging) {
    /*positions[0][0] = anglesF[1]*10.2*PI + width/2 ;
    positions[0][1] = 8.4*(anglesF[0]*PI) + height/2;*/
    positions[0][0] = max(point[0] -760, -360) ;
    //positions[0][2] = max(1.4*point[1] - 1642, -618);
    colors[0][0] = 255;
    colors[0][1] = 0;
    colors[0][2] = 0;
    colors[1][0] = 70;
    colors[1][1] = 14;
    colors[1][2] = 63;
    colors[5][0] = 0;
    colors[5][1] = 125;
    colors[5][2] = 0;
    colors[6][0] = 100;
    colors[6][1] = 100;
    colors[6][2] = 13;
    colors[7][0] = 100;
    colors[7][1] = 100;
    colors[7][2] = 100;
    colors[8][0] = 140;
    colors[8][1] = 120;
    colors[8][2] = 50;
    lamp.setFill(color(colors[7][0], colors[7][1],colors[7][2]));
    box.setFill(color(colors[8][0], colors[8][1],colors[8][2]));
    door.setFill(color(colors[6][0], colors[6][1],colors[6][2]));
    puff.setFill(color(colors[5][0], colors[5][1],colors[5][2]));
    window.setFill(color(colors[1][0], colors[1][1],colors[1][2]));
    drawer.setFill(color(colors[0][0], colors[0][1],colors[0][2]));
  }
  
    if (selected[0] == "window" && isDragging) {
    /*positions[0][0] = anglesF[1]*10.2*PI + width/2 ;
    positions[0][1] = 8.4*(anglesF[0]*PI) + height/2;*/
    //positions[1][2] = -1.4*point[0] + 350 ;
    positions[1][1] =   min(max((point[1]), 253), 789);
    colors[0][0] = 47;
    colors[0][1] = 14;
    colors[0][2] = 14;
    colors[1][0] = 255;
    colors[1][1] = 0;
    colors[1][2] = 0;
    colors[5][0] = 0;
    colors[5][1] = 125;
    colors[5][2] = 0;
    colors[6][0] = 100;
    colors[6][1] = 100;
    colors[6][2] = 13;
    colors[7][0] = 100;
    colors[7][1] = 100;
    colors[7][2] = 100;
    colors[8][0] = 140;
    colors[8][1] = 120;
    colors[8][2] = 50;
    lamp.setFill(color(colors[7][0], colors[7][1],colors[7][2]));
    box.setFill(color(colors[8][0], colors[8][1],colors[8][2]));
    door.setFill(color(colors[6][0], colors[6][1],colors[6][2]));
    puff.setFill(color(colors[5][0], colors[5][1],colors[5][2]));
    window.setFill(color(colors[1][0], colors[1][1],colors[1][2]));
    drawer.setFill(color(colors[0][0], colors[0][1],colors[0][2]));
  }
  
      if (selected[0] == "puff" && isDragging) {
    /*positions[0][0] = anglesF[1]*10.2*PI + width/2 ;
    positions[0][1] = 8.4*(anglesF[0]*PI) + height/2;*/
    positions[2][0] = point[0] ;
    positions[2][2] = point[1]- 1133 ;
    colors[0][0] = 47;
    colors[0][1] = 14;
    colors[0][2] = 14;
    colors[1][0] = 70;
    colors[1][1] = 14;
    colors[1][2] = 63;
    colors[5][0] = 255;
    colors[5][1] = 0;
    colors[5][2] = 0;
    colors[6][0] = 100;
    colors[6][1] = 100;
    colors[6][2] = 13;
    colors[7][0] = 100;
    colors[7][1] = 100;
    colors[7][2] = 100;
    colors[8][0] = 140;
    colors[8][1] = 120;
    colors[8][2] = 50;
    lamp.setFill(color(colors[7][0], colors[7][1],colors[7][2]));
    box.setFill(color(colors[8][0], colors[8][1],colors[8][2]));
    door.setFill(color(colors[6][0], colors[6][1],colors[6][2]));
    puff.setFill(color(colors[5][0], colors[5][1],colors[5][2]));
    window.setFill(color(colors[1][0], colors[1][1],colors[1][2]));
    drawer.setFill(color(colors[0][0], colors[0][1],colors[0][2]));
    

  }
  
        if (selected[0] == "door" && isDragging) {
     doorAngle = (point[0] - doorGrabValue +300)*30/3200 ; 
     // angles
    colors[0][0] = 47;
    colors[0][1] = 14;
    colors[0][2] = 14;
    colors[1][0] = 70;
    colors[1][1] = 14;
    colors[1][2] = 63;
    colors[5][0] = 0;
    colors[5][1] = 125;
    colors[5][2] = 0;
    colors[6][0] = 255;
    colors[6][1] = 0;
    colors[6][2] = 0;
    colors[7][0] = 100;
    colors[7][1] = 100;
    colors[7][2] = 100;
    colors[8][0] = 140;
    colors[8][1] = 120;
    colors[8][2] = 50;
    lamp.setFill(color(colors[7][0], colors[7][1],colors[7][2]));
    box.setFill(color(colors[8][0], colors[8][1],colors[8][2]));
    door.setFill(color(colors[6][0], colors[6][1],colors[6][2]));
    puff.setFill(color(colors[5][0], colors[5][1],colors[5][2]));
    window.setFill(color(colors[1][0], colors[1][1],colors[1][2]));
    drawer.setFill(color(colors[0][0], colors[0][1],colors[0][2]));
    

  }
  
          if (selected[0] == "lamp" && isDragging) {
    lampValue = (point[0] * 255 /1000 - 250) ;
    colors[0][0] = 47;
    colors[0][1] = 14;
    colors[0][2] = 14;
    colors[1][0] = 70;
    colors[1][1] = 14;
    colors[1][2] = 63;
    colors[5][0] = 0;
    colors[5][1] = 125;
    colors[5][2] = 0;
    colors[6][0] = 100;
    colors[6][1] = 100;
    colors[6][2] = 13;
    colors[7][0] = 255;
    colors[7][1] = 0;
    colors[7][2] = 0;
    colors[8][0] = 140;
    colors[8][1] = 120;
    colors[8][2] = 50;
    lamp.setFill(color(colors[7][0], colors[7][1],colors[7][2]));
    box.setFill(color(colors[8][0], colors[8][1],colors[8][2]));
    door.setFill(color(colors[6][0], colors[6][1],colors[6][2]));
    puff.setFill(color(colors[5][0], colors[5][1],colors[5][2]));
    window.setFill(color(colors[1][0], colors[1][1],colors[1][2]));
    drawer.setFill(color(colors[0][0], colors[0][1],colors[0][2]));
    

  }
  
          if (selected[0] == "box" && isDragging) {

    positions[5][0] = point[0] ;
    positions[5][1] = point[1] ;
    colors[0][0] = 47;
    colors[0][1] = 14;
    colors[0][2] = 14;
    colors[1][0] = 70;
    colors[1][1] = 14;
    colors[1][2] = 63;
    colors[5][0] = 0;
    colors[5][1] = 125;
    colors[5][2] = 0;
    colors[6][0] = 100;
    colors[6][1] = 100;
    colors[6][2] = 13;
    colors[7][0] = 100;
    colors[7][1] = 100;
    colors[7][2] = 100;
    colors[8][0] = 255;
    colors[8][1] = 0;
    colors[8][2] = 0;
    lamp.setFill(color(colors[7][0], colors[7][1],colors[7][2]));
    box.setFill(color(colors[8][0], colors[8][1],colors[8][2]));
    door.setFill(color(colors[6][0], colors[6][1],colors[6][2]));
    puff.setFill(color(colors[5][0], colors[5][1],colors[5][2]));
    window.setFill(color(colors[1][0], colors[1][1],colors[1][2]));
    drawer.setFill(color(colors[0][0], colors[0][1],colors[0][2]));
    

  }

  //Drawing objects
  pushMatrix();
  translate(positions[0][0], positions[0][1], positions[0][2]);
  //rotateY(-PI/4);
  shape(drawer); // Draw the shape
  popMatrix();
  
  //Drawing objects
  pushMatrix();
  translate(positions[2][0], positions[2][1] ,  positions[2][2] );
  rotateY(-PI/4);
  shape(puff); // Draw the shape
  popMatrix();
  
  
  //Drawing objects
  pushMatrix();
  translate(positions[1][0], positions[1][1], positions[1][2]);
  rotateY(PI);
  shape(window); // Draw the shape
  popMatrix();
  
    //Drawing objects
  
   float teta= min(max((doorAngle), 3.14), 4.66); 
  
  pushMatrix();
  translate(positions[3][0] , positions[3][1] , positions[3][2] );
  rotateY(teta);
  shape(door); // Draw the shape
  popMatrix();
  
    
  pushMatrix();
  translate(positions[3][0] , positions[3][1] , positions[3][2] -2 );
  shape(doorway); // Draw the shape
  popMatrix();
  
  //Drawing objects
  pushMatrix();
  translate(point[0] ,point[1]);
  shape(icon);
  popMatrix();
  
    //Drawing objects
  pushMatrix();
  translate(positions[6][0]+1, positions[6][1], positions[6][2]);
  rotateY(PI);
  shape(windowway); // Draw the shape
  popMatrix();
  
    //Drawing objects
  pushMatrix();
  translate(positions[5][0], positions[5][1] ,  positions[5][2] );
  rotateY(-PI/4);
  shape(box); // Draw the shape
  popMatrix();
  
    //Drawing objects
   
  pushMatrix();

  translate(positions[4][0], positions[4][1] ,  positions[4][2] );
  rotateY(-PI/4);
  shape(lamp); // Draw the shape
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
  translate(width/2, height/2 + 70, 500);
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

void colorUpdate(){

  



if (thresh1==false && thresh2==false && thresh3==false && thresh4 == false){
    colors[0][0] = 47;
    colors[0][1] = 14;
    colors[0][2] = 14;
    colors[1][0] = 70;
    colors[1][1] = 14;
    colors[1][2] = 63;
    colors[5][0] = 0;
    colors[5][1] = 125;
    colors[5][2] = 0;
    colors[6][0] = 100;
    colors[6][1] = 100;
    colors[6][2] = 13;
    colors[7][0] = 100;
    colors[7][1] = 100;
    colors[7][2] = 100;
    colors[8][0] = 140;
    colors[8][1] = 120;
    colors[8][2] = 50;
    lamp.setFill(color(colors[7][0], colors[7][1],colors[7][2]));
    box.setFill(color(colors[8][0], colors[8][1],colors[8][2]));
    door.setFill(color(colors[6][0], colors[6][1],colors[6][2]));
    door.setFill(color(colors[6][0], colors[6][1],colors[6][2]));
    puff.setFill(color(colors[5][0], colors[5][1],colors[5][2]));
    window.setFill(color(colors[1][0], colors[1][1],colors[1][2]));
    drawer.setFill(color(colors[0][0], colors[0][1],colors[0][2]));

}
}

void updateMo(){
  if(mousePressed){
    isDragging = true;
  }
  else{
    isDragging = false;
    selected[0] = "none";
  }
  
}
void updateM() {
if(getSerial(myPort, inputLenght).length >3){
  if ( getSerial(myPort, inputLenght)[4] == 1)
  {  
    isDragging = true;
  } else {
    isDragging = false;
    

    
  }
}

}



void setLights() {
  //directionalLight(20, 30, 20, 0, height, -50);
  ambientLight(lampValue,lampValue,lampValue);
  //spotLight(lampValue,lampValue,lampValue, 1170, 0,-200, 1, 1, 1, PI/8, 20);
  //pointLight(lampValue,lampValue,lampValue, 1170, 0,-200);
}

void updateSelection() {
    if(isDragging==false){

    if(abs(point[0] - positions[0][0] - 760) < threshold + 200 && abs(point[1] - positions[0][1] + 174) < threshold){
    selected[0] = shapes[0];
    colors[0][0] = 90;
    colors[0][1] = 30;
    colors[0][2] = 30;
    colors[1][0] = 70;
    colors[1][1] = 14;
    colors[1][2] = 63;
    colors[5][0] = 0;
    colors[5][1] = 125;
    colors[5][2] = 0;
    colors[6][0] = 100;
    colors[6][1] = 100;
    colors[6][2] = 13;
    colors[7][0] = 100;
    colors[7][1] = 100;
    colors[7][2] = 100;
    colors[8][0] = 140;
    colors[8][1] = 120;
    colors[8][2] = 50;
    lamp.setFill(color(colors[7][0], colors[7][1],colors[7][2]));
    box.setFill(color(colors[8][0], colors[8][1],colors[8][2]));
    door.setFill(color(colors[6][0], colors[6][1],colors[6][2]));
    puff.setFill(color(colors[5][0], colors[5][1],colors[5][2]));
    window.setFill(color(colors[1][0], colors[1][1],colors[1][2]));
    drawer.setFill(color(colors[0][0], colors[0][1],colors[0][2]));
    thresh1=true;
    
}

    else{
       thresh1=false;
    }
    if(abs(point[0] - positions[1][0]) < threshold +100 && abs(point[1] - positions[1][1]) < threshold +50){
    selected[0] = shapes[1];
    colors[1][0] = 150;
    colors[1][1] = 30;
    colors[1][2] = 130;
    colors[0][0] = 47;
    colors[0][1] = 14;
    colors[0][2] = 14;
    colors[5][0] = 0;
    colors[5][1] = 125;
    colors[5][2] = 0;
    colors[6][0] = 100;
    colors[6][1] = 100;
    colors[6][2] = 13;
    colors[7][0] = 100;
    colors[7][1] = 100;
    colors[7][2] = 100;
    colors[8][0] = 140;
    colors[8][1] = 120;
    colors[8][2] = 50;
    lamp.setFill(color(colors[7][0], colors[7][1],colors[7][2]));
    box.setFill(color(colors[8][0], colors[8][1],colors[8][2]));
    door.setFill(color(colors[6][0], colors[6][1],colors[6][2]));
    puff.setFill(color(colors[5][0], colors[5][1],colors[5][2]));
    window.setFill(color(colors[1][0], colors[1][1],colors[1][2]));
    drawer.setFill(color(colors[0][0], colors[0][1],colors[0][2]));
    thresh2=true;
}

        else{
       thresh2=false;
    }
    if(abs(point[0] - positions[2][0] - 20) < threshold + 80 && abs(point[1] - positions[2][2] - 1050) < threshold + 40){
    selected[0] = shapes[2];
    colors[0][0] = 47;
    colors[0][1] = 14;
    colors[0][2] = 14;
    colors[1][0] = 70;
    colors[1][1] = 14;
    colors[1][2] = 63;
    colors[5][0] = 0;
    colors[5][1] = 255;
    colors[5][2] = 0;
    colors[6][0] = 100;
    colors[6][1] = 100;
    colors[6][2] = 13;
    colors[7][0] = 100;
    colors[7][1] = 100;
    colors[7][2] = 100;
    colors[8][0] = 140;
    colors[8][1] = 120;
    colors[8][2] = 50;
    lamp.setFill(color(colors[7][0], colors[7][1],colors[7][2]));
    box.setFill(color(colors[8][0], colors[8][1],colors[8][2]));
    door.setFill(color(colors[6][0], colors[6][1],colors[6][2]));
    puff.setFill(color(colors[5][0], colors[5][1],colors[5][2]));
    window.setFill(color(colors[1][0], colors[1][1],colors[1][2]));
    drawer.setFill(color(colors[0][0], colors[0][1],colors[0][2]));
    thresh3=true;
}
        else{
       thresh3=false;
    }
    
        if(abs(point[0] - positions[3][0] + 720) < threshold +30 && abs(point[1] - positions[3][1] + 100 ) < threshold +80){
    selected[0] = shapes[3];
    colors[0][0] = 47;
    colors[0][1] = 14;
    colors[0][2] = 14;
    colors[1][0] = 70;
    colors[1][1] = 14;
    colors[1][2] = 63;
    colors[5][0] = 0;
    colors[5][1] = 125;
    colors[5][2] = 0;
    colors[6][0] = 200;
    colors[6][1] = 200;
    colors[6][2] = 26;
    colors[7][0] = 100;
    colors[7][1] = 100;
    colors[7][2] = 100;
    colors[8][0] = 140;
    colors[8][1] = 120;
    colors[8][2] = 50;
    lamp.setFill(color(colors[7][0], colors[7][1],colors[7][2]));
    box.setFill(color(colors[8][0], colors[8][1],colors[8][2]));
    door.setFill(color(colors[6][0], colors[6][1],colors[6][2]));
    puff.setFill(color(colors[5][0], colors[5][1],colors[5][2]));
    window.setFill(color(colors[1][0], colors[1][1],colors[1][2]));
    drawer.setFill(color(colors[0][0], colors[0][1],colors[0][2]));
    thresh4=true;
    doorGrabValue = point[0] ;
}
        else{
       thresh4=false;
    }
            if(abs(point[0] - positions[4][0] ) < threshold +30 && abs(point[1] - positions[4][1]  ) < threshold +30){
    selected[0] = shapes[5];
    colors[0][0] = 47;
    colors[0][1] = 14;
    colors[0][2] = 14;
    colors[1][0] = 70;
    colors[1][1] = 14;
    colors[1][2] = 63;
    colors[5][0] = 0;
    colors[5][1] = 125;
    colors[5][2] = 0;
    colors[6][0] = 100;
    colors[6][1] = 100;
    colors[6][2] = 13;
    colors[7][0] = 200;
    colors[7][1] = 200;
    colors[7][2] = 200;
    colors[8][0] = 140;
    colors[8][1] = 120;
    colors[8][2] = 50;
    lamp.setFill(color(colors[7][0], colors[7][1],colors[7][2]));
    box.setFill(color(colors[8][0], colors[8][1],colors[8][2]));
    door.setFill(color(colors[6][0], colors[6][1],colors[6][2]));
    puff.setFill(color(colors[5][0], colors[5][1],colors[5][2]));
    window.setFill(color(colors[1][0], colors[1][1],colors[1][2]));
    drawer.setFill(color(colors[0][0], colors[0][1],colors[0][2]));
    thresh5=true;
    doorGrabValue = point[0] ;
}
        else{
       thresh5=false;
    }
            if(abs(point[0] - positions[5][0] ) < threshold +30 && abs(point[1] - positions[5][1]  ) < threshold +30){
    selected[0] = shapes[4];
    colors[0][0] = 47;
    colors[0][1] = 14;
    colors[0][2] = 14;
    colors[1][0] = 70;
    colors[1][1] = 14;
    colors[1][2] = 63;
    colors[5][0] = 0;
    colors[5][1] = 125;
    colors[5][2] = 0;
    colors[6][0] = 100;
    colors[6][1] = 100;
    colors[6][2] = 13;
    colors[7][0] = 100;
    colors[7][1] = 100;
    colors[7][2] = 100;
    colors[8][0] = 255;
    colors[8][1] = 240;
    colors[8][2] = 100;
    lamp.setFill(color(colors[7][0], colors[7][1],colors[7][2]));
    box.setFill(color(colors[8][0], colors[8][1],colors[8][2]));
    door.setFill(color(colors[6][0], colors[6][1],colors[6][2]));
    puff.setFill(color(colors[5][0], colors[5][1],colors[5][2]));
    window.setFill(color(colors[1][0], colors[1][1],colors[1][2]));
    drawer.setFill(color(colors[0][0], colors[0][1],colors[0][2]));
    thresh6=true;
    doorGrabValue = point[0] ;
}
        else{
       thresh6=false;
    }
}}
