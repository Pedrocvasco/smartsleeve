#include <Wire.h>
#include "Kalman.h" // Source: https://github.com/TKJElectronics/KalmanFilter

// For Gyro
#include "L3G4200D.h"

// For accel
#include "ADXL345.h"

// For mag
#include "HMC5883L.h"

#define MIN_TIME          2000  // MuscleHand minium time

#define RESTRICT_PITCH // Comment out to restrict roll to ±90deg instead - please read: http://www.freescale.com/files/sensors/doc/app_note/AN3461.pdf

// ***** For mag ****
#define MAG0MAX 603     // 603
#define MAG0MIN -578    // -578

#define MAG1MAX 542     // 542
#define MAG1MIN -701    // -701

#define MAG2MAX 547     // 547
#define MAG2MIN -556    // -556
// *******************

Kalman kalmanX; // Create the Kalman instances
Kalman kalmanY;
Kalman kalmanZ;

/* IMU Data */
const int analogInPin = A0;  // Analog input pin that the potentiometer is attached to
const int analogOutPin = 9; // Analog output pin that the LED is attached to

unsigned long int muscleThreshold = 0;
float sensorValue = 0;        // value read from the pot
int outputValue = 0;        // value output to the PWM (analog out)
float alpha = 0.8;
float lastSensorValue;
bool hold = false;
unsigned long time_t;        

                              //fim das variaveis globais muscle hand

                              
double accX, accY, accZ;
double gyroX, gyroY, gyroZ;
double magX, magY, magZ; 
// shadow variables only for compatibility
int16_t accX_u, accY_u, accZ_u;
float gyroX_f, gyroY_f, gyroZ_f;
int16_t magX_u, magY_u, magZ_u;

float magOffset[3] = { (MAG0MAX + MAG0MIN) / 2, (MAG1MAX + MAG1MIN) / 2, (MAG2MAX + MAG2MIN) / 2 };
double magGain[3];

double roll, pitch, yaw;
bool first_flag = false;
double yawNorm, firstYaw;       // Both variables were created to correct singulatirity and offset
                                // of variable yaw

                                
double gyroXangle, gyroYangle, gyroZangle; // Angle calculate using the gyro only
double compAngleX, compAngleY, compAngleZ; // Calculated angle using a complementary filter
double kalAngleX, kalAngleY, kalAngleZ; // Calculated angle using a Kalman filter

uint32_t timer;
//uint8_t i2cData[14]; // Buffer for I2C data

// For accel
ADXL345 accel;

// For gyro
L3G4200D gyro;

// For mag
HMC5883L mag;

//Remove this variables when not remembering anymore. Only for calibration
double magXmax = 0;
double magXmin = 0;
double magYmax = 0;
double magYmin = 0;
double magZmax = 0;
double magZmin = 0;

void initializeGyro() {
  gyro.initialize();
  gyro.setFullScale(250);
  //Serial.println(gyro.testConnection() ? "L3G4200D connection successful" : "L3G4200D connection failed");
}

void initializeAccel() {
  accel.initialize();
  accel.setRange(0);
  accel.setFullResolution(1); // Full resolution mode -> 4mg/LSB
  //Serial.println(accel.testConnection() ? "ADXL345 connection successful" : "ADXL345 connection failed");
}

void initializeMag() {
  mag.initialize();
  //Serial.println(mag.testConnection() ? "HMC5883L connection successful" : "HMC5883L connection failed");

  mag.setMode(0b00);    // Continuous mode
  delay(100);
  
  mag.setSampleAveraging(0b00); // Select number of samples averaged -> 0 = 1 sample(Default)
  mag.setDataRate(0b100); // Rate at which data is written to all three data output registers -> 15 Hz (Default)
  mag.setMeasurementBias(0b01); // Positive bias configuration for X, Y, and Z axes
  delay(100);
  readMag();      // Read positive bias values

  int16_t magPosOff[3] = { magX, magY, magZ };

  mag.setMeasurementBias(0b10); // Negative bias configuration for X, Y, and Z axes
  delay(100);
  readMag();      // Read negative bias values
  
  int16_t magNegOff[3] = { magX, magY, magZ };

  mag.setMeasurementBias(0b00); // Normal measurement configuration (Default)

  magGain[0] = -2500 / float(magNegOff[0] - magPosOff[0]);
  magGain[1] = -2500 / float(magNegOff[1] - magPosOff[1]);
  magGain[2] = -2500 / float(magNegOff[2] - magPosOff[2]);

  #if 0
    Serial.print("Mag cal: ");
    Serial.print(magNegOff[0] - magPosOff[0]);
    Serial.print(",");
    Serial.print(magNegOff[1] - magPosOff[1]);
    Serial.print(",");
    Serial.println(magNegOff[2] - magPosOff[2]);

    Serial.print("Gain: ");
    Serial.print(magGain[0]);
    Serial.print(",");
    Serial.print(magGain[1]);
    Serial.print(",");
    Serial.println(magGain[2]);
  #endif
}

void readGyro() {
  gyro.getAngularVelocityFloat(&gyroX_f, &gyroY_f, &gyroZ_f);
  gyroX = (double) gyroX_f;
  gyroY = (double) gyroY_f;
  gyroZ = (double) gyroZ_f;
}

void readAccel() {
  accel.getAcceleration(&accX_u, &accY_u, &accZ_u);
  accX = (double) accX_u * 0.004;
  accY = (double) accY_u * 0.004;
  accZ = (double) accZ_u * 0.004;
}

void readMag() {
  mag.getHeading(&magX_u, &magY_u, &magZ_u);
  magX = (double) magX_u;
  magY = (double) magY_u;
  magZ = (double) magZ_u;

  
}

void calibrate_muscle(){
  for (int amostra = 0; amostra < 40; amostra++){
    muscleThreshold += analogRead(analogInPin);
    delay(38);
  }

  muscleThreshold /= 40;
}

  
void setup() {
  Serial.begin(115200);
  
  // calibrate musclehand function
  calibrate_muscle();   
  // Set Gyro Full Scale Range to ±250deg/s
  initializeGyro();
  // Set Accelerometer Full Scale Range to ±2g 
  initializeAccel();
  // Set Magnetometer
  initializeMag();
  
  delay(100); // Wait for sensor to stabilize

  // Set kalman and gyro starting angle 
  readAccel();
  readGyro();
  readMag();
  
  updatePitchRoll();
  updateYaw();
  
  kalmanX.setAngle(roll); // Set starting angle
  gyroXangle = roll;
  compAngleX = roll;
  
  kalmanY.setAngle(pitch);
  gyroYangle = pitch;
  compAngleY = pitch;

  kalmanZ.setAngle(yaw);
  gyroZangle = yaw;
  compAngleZ = yaw;
  
  firstYaw = yaw;

  timer = micros();
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
  // Update all the values
  readGyro();
  readAccel();
  readMag();
  
  double dt = (double)(micros() - timer) / 1000000; // Calculate delta time
  timer = micros();

  updatePitchRoll();
  double gyroXrate = gyroX / 131.0; // Convert to deg/s
  double gyroYrate = gyroY / 131.0; // Convert to deg/s

#ifdef RESTRICT_PITCH
  // This fixes the transition problem when the accelerometer angle jumps between -180 and 180 degrees
  if ((roll < -90 && kalAngleX > 90) || (roll > 90 && kalAngleX < -90)) {
    kalmanX.setAngle(roll);
    compAngleX = roll;
    kalAngleX = roll;
    gyroXangle = roll;
  } else
    kalAngleX = kalmanX.getAngle(roll, gyroXrate, dt); // Calculate the angle using a Kalman filter

  if (abs(kalAngleX) > 90)
    gyroYrate = -gyroYrate; // Invert rate, so it fits the restriced accelerometer reading
  kalAngleY = kalmanY.getAngle(pitch, gyroYrate, dt);
#else

  // This fixes the transition problem when the accelerometer angle jumps between -180 and 180 degrees
  if ((pitch < -90 && kalAngleY > 90) || (pitch > 90 && kalAngleY < -90)) {
    kalmanY.setAngle(pitch);
    compAngleY = pitch;
    kalAngleY = pitch;
    gyroYangle = pitch;
  } else
    kalAngleY = kalmanY.getAngle(pitch, gyroYrate, dt); // Calculate the angle using a Kalman filter

  if (abs(kalAngleY) > 90)
    gyroXrate = -gyroXrate; // Invert rate, so it fits the restriced accelerometer reading
  kalAngleX = kalmanX.getAngle(roll, gyroXrate, dt); // Calculate the angle using a Kalman filter
#endif

  updateYaw();
  double gyroZrate = gyroZ / 131.0; // Convert to deg/s
  // This fixes the transition problem when the yaw angle jumps between -180 and 180 degrees
  if ((yaw < -90 && kalAngleZ > 90) || (yaw > 90 && kalAngleZ < -90)) {
    kalmanZ.setAngle(yaw);
    compAngleZ = yaw;
    kalAngleZ = yaw;
    gyroZangle = yaw;
  } else
    kalAngleZ = kalmanZ.getAngle(yaw, gyroZrate, dt); // Calculate the angle using a Kalman filter
  
  gyroXangle += gyroXrate * dt; // Calculate gyro angle without any filter
  gyroYangle += gyroYrate * dt;
  gyroZangle += gyroZrate * dt;
  //gyroXangle += kalmanX.getRate() * dt; // Calculate gyro angle using the unbiased rate
  //gyroYangle += kalmanY.getRate() * dt;
  //gyroZangle += kalmanZ.getRate() * dt;

  compAngleX = 0.93 * (compAngleX + gyroXrate * dt) + 0.07 * roll; // Calculate the angle using a Complimentary filter
  compAngleY = 0.93 * (compAngleY + gyroYrate * dt) + 0.07 * pitch;
  compAngleZ = 0.93 * (compAngleZ + gyroZrate * dt) + 0.07 * yaw;
  
  // Reset the gyro angle when it has drifted too much
  if (gyroXangle < -180 || gyroXangle > 180)
    gyroXangle = kalAngleX;
  if (gyroYangle < -180 || gyroYangle > 180)
    gyroYangle = kalAngleY;
  if (gyroZangle < -180 || gyroZangle > 180)
    gyroZangle = kalAngleZ;

  
  yawNorm = yaw - firstYaw;
  
  /* Print Data */
#if 0 // Set to 1 to activate
  Serial.print("AccX: "); Serial.print(accX); Serial.print("\t");
  Serial.print("AccY: "); Serial.print(accY); Serial.print("\t");
  Serial.print("AccZ: "); Serial.print(accZ); Serial.print("\t");

  Serial.print("GyroX: "); Serial.print(gyroX); Serial.print("\t");a
  Serial.print("GyroY: "); Serial.print(gyroY); Serial.print("\t");
  Serial.print("GyroZ: "); Serial.print(gyroZ); Serial.print("\t"); 

  Serial.print("MagX: "); Serial.print(magX); Serial.print("\t");
  Serial.print("MagY: "); Serial.print(magY); Serial.print("\t");
  Serial.print("MagZ: "); Serial.print(magZ); Serial.print("\t");
#endif

#if 1
  Serial.print(roll); Serial.print(";");
  Serial.print(pitch); Serial.print(";");
  Serial.print(yawNorm); Serial.print(";");
  Serial.print(hold); Serial.print(";");
  Serial.print(sensorValue); Serial.print(";");
  Serial.print(muscleThreshold);
  //Serial.print("FirstYaw: "); Serial.print(firstYaw); Serial.print("\t");
#endif

  Serial.print("\r\n");
  delay(100);
}

void updatePitchRoll() {
  // Source: http://www.freescale.com/files/sensors/doc/app_note/AN3461.pdf eq. 25 and eq. 26
  // atan2 outputs the value of -π to π (radians) - see http://en.wikipedia.org/wiki/Atan2
  // It is then converted from radians to degrees
#ifdef RESTRICT_PITCH // Eq. 25 and 26
  roll = atan2(accY, accZ) * RAD_TO_DEG;
  pitch = atan(-accX / sqrt(accY * accY + accZ * accZ)) * RAD_TO_DEG;
#else // Eq. 28 and 29
  roll = atan(accY / sqrt(accX * accX + accZ * accZ)) * RAD_TO_DEG;
  pitch = atan2(-accX, accZ) * RAD_TO_DEG;
#endif
}

void updateYaw() { // See: http://www.freescale.com/files/sensors/doc/app_note/AN4248.pdf
  magX *= -1; // Invert axis - this it done here, as it should be done after the calibration
  magZ *= -1;

  magX *= magGain[0];
  magY *= magGain[1];
  magZ *= magGain[2];

  magX -= magOffset[0];
  magY -= magOffset[1];
  magZ -= magOffset[2];

  double rollAngle = kalAngleX * DEG_TO_RAD;
  double pitchAngle = kalAngleY * DEG_TO_RAD;

  double Bfy = magZ * sin(rollAngle) - magY * cos(rollAngle);
  double Bfx = magX * cos(pitchAngle) + magY * sin(pitchAngle) * sin(rollAngle) + magZ * sin(pitchAngle) * cos(rollAngle);
  yaw = atan2(-Bfy, Bfx) * RAD_TO_DEG;

  yaw *= -1;
}
