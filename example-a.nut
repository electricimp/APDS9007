#require "APDS9007.class.nut:2.2.1"

// value of load resistor on ALS
const RLOAD = 47000.0;

// use pin#5 as analog input
analogInputPin <- hardware.pin5;
analogInputPin.configure(ANALOG_IN);

// use pin#7 as enable poin
enablePin <- hardware.pin7;
enablePin.configure(DIGITAL_OUT, 0);

// initialize driver class
lightsensor <- APDS9007(analogInputPin, RLOAD , enablePin);

// enable sensor
lightsensor.enable(true);

// get readout
function readLightLevel() {
    lightsensor.read(function (result) {
        if ("err" in result) {
            server.log("Error Reading APDS9007: " + result.err);
            return;
        }
        server.log("Light level = " + result.brightness + " Lux");
        imp.wakeup(2, readLightLevel); // repeat in 2 seconds
    });
};

// start reading light level every 2 seconds, the first reading will arrive in 5 secs
readLightLevel();
