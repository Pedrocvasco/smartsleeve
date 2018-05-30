/*
ADXL335
note:vcc-->5v ,but ADXL335 Vs is 3.3V
The circuit:
      5V: VCC
analog 1: x-axis
analog 2: y-axis
analog 3: z-axis
*/
const int xpin = 0;                  // x-axis of the accelerometer
const int ypin = 1;                  // y-axis
const int zpin = 2;                  // z-axis (only on 3-axis models)
const int mpin = 3;                 // m-muscle
const int ipin = 4;                  //distancia IR

int x, y, z ,ir;
int a = 1;
float nx, ny, nz, nm;
int handD;
int Sel;

void setup()
{
   // intialize the serial communications:
   Serial.begin(9600);
}

void loop()
{
   x = analogRead(xpin);  //read from xpin
   
   y = analogRead(ypin);  //read from ypin
   
   z = analogRead(zpin);  //read from zpin
  
   nm = analogRead(mpin); //read from mpin
  
   ir = analogRead(ipin);  //read from ipin
   
  float zero_G = 512.0; //ADC is 0~1023  the zero g output equal to Vs/2
                        //ADXL335 power supply by Vs 3.3V
  float scale = 102.3;  //ADXL335330 Sensitivity is 330mv/g
                         //330 * 1024/3.3/1000  

  nx = ((float)x - 331.5)/65*9.8;
  ny = ((float)y - 329.5)/68.5*9.8;
  nz = ((float)z - 340)/68*9.8;
  handD = handDirection();
  handDistance();
  
  Serial.print(Sel);
  Serial.print( ";" );
  Serial.println(handD);
  delay(20);
}

void printAll(){
  Serial.print(nm);  //print m value on serial monitor
  Serial.print("\t");
  Serial.print(nx);  //print x value on serial monitor
  Serial.print("\t");
  Serial.print(ny);  //print y value on serial monitor
  Serial.print("\t");
  Serial.print(nz);  //print z value on serial monitor
  Serial.print("\n");
}

