/* 
 *     Project: Rodent autofeeder controller version 1.4
 *      Author: Lauri Kantola
 *     Created: 11.1.2017
 * Arduino IDE: 1.6.12
 *     Website: http://www.laurikantola.info
 * Description: Sensor automated controller for rodent pellet feeder.
 * ------------------------------------------------------------------
 * Wiring:
 * 
 *  
 */

//*NOTE!* Relay 1 = pin 2, R2 = pin 3, R3 = pin 4, R4 = pin 5
int const RELAY_PINS[] = {2, 3, 4, 5}; 

int const RELAYS_SIZE = sizeof(RELAY_PINS)/sizeof(int);
int const INDICATOR = 13;

//*NOTE!* Gate 1 = A0, G2 = A1, G3 = A2, G4 = A3
int const SENSOR_PINS[] = {A0, A1, A2, A3}; 

int const SENSORS_SIZE = sizeof(SENSOR_PINS)/sizeof(int);
int const THRESHOLD = 1000; //Port triggering threshold limit
int const SAMPLE = 20;  //sample size (N) for value average
int const CHANCE = 4; // 1/n chance for treat e.g. 1/4
boolean const CHANCE_ENABLED = false; //enable or disable chance

int values = 0;
int average = 0;
int randomValue = 0;

boolean triggered = false;

void setup() {

  pinMode(INDICATOR, OUTPUT);
  digitalWrite(INDICATOR, LOW);
  
  for (int i = 0; i < RELAYS_SIZE; i++){
    pinMode(RELAY_PINS[i], OUTPUT);
    digitalWrite(RELAY_PINS[i], HIGH); //Turn relays OFF
  }  
  Serial.begin(9600);         // Serial monitor for debuging.
}

void loop() {
  
  for (int i = 0; i < SENSORS_SIZE; i++){
    
    while (!triggered) {      
      readSensor(SENSOR_PINS[i], RELAY_PINS[i]);
    }
    triggered = !triggered; // Toggle trigger value    
  }
}

int readSensor(int currentSensor, int currentRelay){
  
  for (int i = 0; i < SAMPLE; i++) {
    values = values + analogRead(currentSensor);
  }

  average = values / SAMPLE;

  Serial.print(currentSensor-13);
  Serial.print(" Sensor value is ");
  Serial.println(average);

  if (average > THRESHOLD)
    {
      triggered = !triggered;            // Toggle trigger value

      if (CHANCE_ENABLED) {
        randomValue = random(CHANCE);
        Serial.print("Lucky number ");
        Serial.println(randomValue);
        if (randomValue = 0) {
          digitalWrite(INDICATOR, HIGH);     // Turn indicator ON.
          digitalWrite(currentRelay,LOW);    // Turn relay ON
          Serial.print(currentSensor-13);
          Serial.println(" Feeding...");
          delay(100);
          digitalWrite(currentRelay,HIGH);   // Turn relay OFF.
          digitalWrite(INDICATOR, LOW);      // Turn indicator OFF.
          Serial.println("Feeding stop.");
        } else {
            Serial.println("Tough luck!");
        }
      }

      else {          
        digitalWrite(INDICATOR, HIGH);     // Turn indicator ON.
        digitalWrite(currentRelay,LOW);    // Turn relay ON
        Serial.print(currentSensor-13);
        Serial.println(" Feeding...");
        delay(100);
        digitalWrite(currentRelay,HIGH);   // Turn relay OFF.
        digitalWrite(INDICATOR, LOW);      // Turn indicator OFF.
        Serial.println("Feeding stop.");
      }
      
      delay(1000);
    } 
      values = 0;
    
}
