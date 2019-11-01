// Include the APDS-9007 library
#require "APDS9007.class.nut:3.0.0"

// Value of load resistor on ALS
const RLOAD = 47000.0;

// Use imp001 pin 5 as the analog input
// NOTE Change the pin to use this code with other imps
analogInputPin <- hardware.pin5;
analogInputPin.configure(ANALOG_IN);

// Use imp001 pin7 as the enable pin
// NOTE Change the pin to use this code with other imps
enablePin <- hardware.pin7;
enablePin.configure(DIGITAL_OUT, 0);

// Initialize the driver class
lightsensor <- APDS9007(analogInputPin, RLOAD , enablePin);

// Enable the sensor
lightsensor.enable(true);

// Get a reading
function readLightLevel() {
    // Get the reading asynchronously
    lightsensor.read(function (result) {
        if ("err" in result) {
            server.log("Error Reading APDS-9007: " + result.err);
            return;
        }

        server.log("Light level: " + result.brightness + " Lux");

        // Repeat in 2 seconds
        imp.wakeup(2, readLightLevel);
    });
};

// Start reading the light level every two seconds,
// but note that the first reading will arrive in five seconds' time
readLightLevel();
