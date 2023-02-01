/* FSR testing sketch. 
 
Connect one end of FSR to power, the other end to Analog 0.
Then connect one end of a 10K resistor from Analog 0 to ground 
 
For more information see www.ladyada.net/learn/sensors/fsr.html */

int fsrPin = 0;        // the FSR and 10K pulldown are connected to a0
int fsrReading;        // the analog reading from the FSR resistor divider
int fsrVoltage;        // the analog reading converted to voltage
double fsrResistance;  // The voltage converted to resistance, can be very big so make "long"
double fsrConductance;
double fsrForce;  // Finally, the resistance converted to force

double f0, f1, f2, f3, f4 = 0;

double getForce(int fsrPinNum) {
  fsrReading = analogRead(fsrPinNum);
  // analog voltage reading ranges from about 0 to 1023 which maps to 0V to 5V (= 5000mV)
  fsrVoltage = map(fsrReading, 0, 1023, 0, 5000);

  if (fsrVoltage == 0) {
    // Serial.println(0.00, 9);
    // No Pressure Detected
    return 0.00;
  } else {
    // The voltage = Vcc * R / (R + FSR) where R = 6.8K and Vcc = 5V
    // so FSR = ((Vcc - V) * R) / V
    fsrResistance = 5000 - fsrVoltage;  // fsrVoltage is in millivolts so 5V = 5000mV
    if (fsrPinNum == 2){
      fsrResistance *= 10;
    }
    fsrResistance *= 6800;              // 200K Ohm resistor
    fsrResistance /= fsrVoltage;
    fsrConductance = 1000000;  // we measure in micromhos so
    fsrConductance /= fsrResistance;
    // Use the two FSR guide graphs to approximate the force
    if (fsrConductance <= 1000) {
      fsrForce = fsrConductance / 80;
      return fsrForce;
      //Serial.println(fsrForce, 9);
    } else {
      fsrForce = fsrConductance - 1000;
      fsrForce /= 30;
      //Serial.println(fsrForce, 9);
      return fsrForce;
    }
  }
}

void setup(void) {
  Serial.begin(115200);  // We'll send debugging information via the Serial monitor
}

void loop(void) {
  f0 = getForce(0);
  f1 = getForce(1);
  f2 = getForce(2);
  f3 = getForce(3);
  f4 = getForce(4);

  Serial.print(f0, 9);
  Serial.print(" ");
  Serial.print(f1, 9);
  Serial.print(" ");
  Serial.print(f2, 9);
  Serial.print(" ");
  Serial.print(f3, 9);
  Serial.print(" ");
  Serial.print(f4, 9);
  Serial.println();
}