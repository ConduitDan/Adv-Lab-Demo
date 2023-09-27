
// Reads voltage from voltage divider with thermistor as one leg. Averages numMeasurements times.
// Thermistor is in leg next to ground and the voltage is read by "tempIn"
// The thermistor is a Epcos, R/T 1008 with R_25 = 2000 ohms. B-parameter equation given in code.
// A trim pot sets the voltage between 0 - 5V and used to set the PWM of the H-bridge
// Outputs temperature (C), elapsed time (s) and PWM (0-255)
// Example serial line output:
//              Temperature (C): 27.73, Time (s): 645.06, PWM: 127

// Matlab reads and plots the results in a stripchart: StripChartTempTime.m

const int tempIn = A0;  // Analog input pin
const int pwmIn = A1;  // Analog input pin
const int numMeasurements = 5000;  // Number of measurements

// power
#define pwmOut1 9
#define pwmOut2 10


// Fixed resistor value in ohms
const float fixedResistance = 4670.0; // my board
//const float fixedResistance = 2195.0; // board in 39 lab

// Thermistor parameters
const float beta = 3560.0;
const float R25 = 2000.0;
const float T0 = 298.15;  // 25°C in Kelvin

void setup() {
  Serial.begin(9600);  // Initialize serial communication
  while (!Serial) {
    ;  // Wait for serial port to connect
  }
}
unsigned long startTime = millis();  // Get the starting time

void loop() {
  

  // Perform measurements and calculate average
float total = 0;
  for (int i = 0; i < numMeasurements; i++) {
    int sensorValue = analogRead(tempIn);
    total = total + sensorValue;
  }
float average = total / (float)numMeasurements;

    // Convert the analog value to voltage
    float voltage = average * (5.0 / 1023.0);  // Assuming 5V reference voltage

    // Calculate the resistance of the thermistor
    float thermistorResistance = (fixedResistance * voltage) / (5.0 - voltage);

    // Calculate the temperature using the Steinhart-Hart equation. See Wiki Thermistor entry.
    float steinhart = log(thermistorResistance / R25);
    steinhart /= beta;
    steinhart += 1.0 / T0;
    float temperature = 1.0 / steinhart - 273.15;  // temperature in Centigrade
   
    int pwmAnalogInput = analogRead(pwmIn)/4;  // voltage divider sets pwm input
    analogWrite(pwmOut1,pwmAnalogInput); // one of the two possible directions (heat/cool)
    analogWrite(pwmOut2,0);

  // Print average temperature and time in seconds
  unsigned long currentTime = millis();
  float elapsedTime = (currentTime - startTime) / 1000.0;
  Serial.print("Temperature (C): ");
  Serial.print(temperature);
  Serial.print(", Time (s): ");
  Serial.print(elapsedTime);
  Serial.print(", PWM: ");
  Serial.println(pwmAnalogInput);
}