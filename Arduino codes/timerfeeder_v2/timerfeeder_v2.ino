unsigned long const INTERVAL = 17000; // Time interval between treats in ms
int const THRESHOLD = 900;
int const SILENCE = 0; // Safe zone after triggering (In ms)
int const PULSE_WIDTH = 50; // In ms
int const IR = 12, FEEDER = 2, TRY = 3, LED1 = 6, LED2 = 7, LED3 = 8, SENSOR = A0; // I/O -pins

String const sRange = String(THRESHOLD, DEC);
unsigned long startTime, currentTime, delayTime, delayStart;
int value1, value2, noise1, noise2, startValue, value;
int toggle = 0;

boolean const DEBUG = false; // 'true' turns serial printing on for debugging

void setup() {

	Serial.begin(9600);
	pinMode(IR,OUTPUT); // IR LED for sensor
	pinMode(FEEDER,OUTPUT); // Feeder pulse and marker for acquisition
	pinMode(TRY,OUTPUT); // "Early try" marker for acquisition
	pinMode(LED1,OUTPUT); // LED -control #1
	pinMode(LED2,OUTPUT); // LED -control #2
	pinMode(LED3,OUTPUT); // LED -control #3

	readSensor(); // For fixing too large initial values
	startValue = readSensor(); // Sensor calibration for neutral state

}

void loop() {

	startTime = millis();
	currentTime = millis();

	//digitalWrite(LED1, HIGH);
	//digitalWrite(LED2, HIGH);
	//digitalWrite(LED3, HIGH);

	// First phase, feeder is armed
	while (!toggle) {

		value = readSensor();

		if (DEBUG) { printStatus("ARMED","NOT TRIGGERED"); };
    
		if (value > THRESHOLD) {  

			startTime = millis();
			currentTime = millis();  

				if (DEBUG) { printStatus("UNARMED","TRIGGERED!"); };

				digitalWrite(FEEDER,HIGH); // Feeder control up!
				digitalWrite(TRY,HIGH);    // 'Noise in the gate' marker up!

				delayStart = millis();
				delayTime = millis();

				// Wait PULSE_WIDTH (e.g. 50ms) for feeder to respond
				while ((delayTime - delayStart) <= PULSE_WIDTH) {

					delayTime = millis();
					if (DEBUG) { printStatus("UNARMED","PULSE OUT!"); };

				}

				digitalWrite(FEEDER,LOW); // Feeder control down!

				// Keeps 'Noise in the gate' marker up long as the nose is in the gate
				while (value > THRESHOLD) {

					value = readSensor();

				}

				digitalWrite(TRY,LOW); // Nose has been removed from the gate, -> marker down

				//delayStart = millis(); // Not neede, because delay used before
				//delayTime = millis();
				// Timer for silence period (can be 0ms)
				while ((delayTime - delayStart) <= SILENCE) {

					delayTime = millis();
					if (DEBUG) { printStatus("UNARMED","DELAY"); };

				}

			toggle = !toggle; // Toggle for moving to the second phase

		}

	}

	// Second phase for waiting (INTERVAL) before rearming the feeder
	while (toggle) {

		currentTime = millis();

		if (DEBUG) { printStatus("UNARMED","INTERVAL"); };

		value = readSensor();

		if (value > THRESHOLD) { 

			if (DEBUG) { printStatus("UNARMED","TRIGGERED, BUT UNARMED!"); };

			digitalWrite(TRY,HIGH); // 'Nose in the gate' marker up!

			delayStart = millis();
			delayTime = millis();

			//while ((delayTime - delayStart) <= PULSE_WIDTH) {
			//  delayTime = millis();
			//  if (DEBUG) { printStatus("UNARMED","PULSE OUT!"); };
			//}

			if (DEBUG) { printStatus("UNARMED","PULSE OUT!"); };

			// Keeps 'Noise in the gate' marker up long as the nose is in the gate
			while (value > THRESHOLD) {

				value = readSensor();

			}

			digitalWrite(TRY,LOW); // Nose has been removed from the gate, -> marker down

			//delayStart = millis(); // Not neede, because delay used before
			//delayTime = millis();
			// Timer for silence period (can be 0ms)
			while ((delayTime - delayStart) <= SILENCE) {

				delayTime = millis();
				if (DEBUG) { printStatus("UNARMED","DELAY"); };

			}

		}

		// Toggle changer. Checks if the nose is not already in the gate and the interval has passed.
		// If the nose is already in the gate after interval has passed -> no reaming before leaving from the gate
		if (value < THRESHOLD && (currentTime - startTime) >= INTERVAL) {

			toggle = !toggle;

			if (DEBUG) { printStatus("REARMED","TIME PASSED!"); };

		}

	}

	//digitalWrite(LED1, LOW);
	//digitalWrite(LED2, LOW);
	//digitalWrite(LED3, LOW);

}

int readSensor() {

	digitalWrite(IR,HIGH); // IR -led ON
	value1 = analogRead(SENSOR); // Analog for sensor is A03
	value2 = analogRead(SENSOR);
	digitalWrite(IR,LOW); // IR -led OFF
	//noise1 = analogRead(SENSOR);
	//noise2 = analogRead(SENSOR);

	//return (((noise1 + noise2) / 2) - ((value1 + value2) / 2));
	return (value1 + value2) / 2;

}

int printStatus(String armed, String trigger) {  

	String sensor = String(readSensor(),DEC);
	String timer = String((currentTime - startTime),DEC);
	Serial.print(String("Threshold: " + sRange + "\tSensor: " + sensor + "/" + startValue + "\tFeeder: " + armed + "\tTrigger: " + trigger + "\tTimer: " + timer + "\n"));

}
