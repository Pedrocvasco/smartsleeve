
#define MIN_TIME          2000



// These constants won't change.  They're used to give names
// to the pins used:
const int analogInPin = A0;  // Analog input pin that the potentiometer is attached to
const int analogOutPin = 9; // Analog output pin that the LED is attached to

unsigned long int muscleThreshold = 0;
float sensorValue = 0;        // value read from the pot
int outputValue = 0;        // value output to the PWM (analog out)
float alpha = 0.8;
float lastSensorValue;
bool hold = false;
unsigned long time_t;

void setup() {
  // initialize serial communications at 9600 bps:
  Serial.begin(9600);
  calibrate_muscle();
}

void calibrate_muscle(){
  for (int amostra = 0; amostra < 40; amostra++){
    muscleThreshold += analogRead(analogInPin);
    delay(38);
  }
//  Serial.print("muscleThreshold = ");
//  Serial.print(muscleThreshold);
  
  muscleThreshold /= 40;
  
}
void loop() {
  // read the analog in value:
  lastSensorValue = sensorValue;
  
  sensorValue = analogRead(analogInPin);
  sensorValue = alpha * sensorValue + (1-alpha) * lastSensorValue;  
  if ( (sensorValue > 1.5 * muscleThreshold) && (millis() - time_t  > MIN_TIME) ){
    hold = !hold; 
    time_t = millis();
  }
 

  // print the results to the serial monitor:
  Serial.print("sensor = ");
  Serial.print(sensorValue);
  Serial.print(" hold = ");
  Serial.print(hold);
  Serial.print(" muscleThreshold = ");
  Serial.print(muscleThreshold);

  Serial.println();
  // wait 2 milliseconds before the next loop
  // for the analog-to-digital converter to settle
  // after the last reading:
  delay(2);
}
