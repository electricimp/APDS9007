Driver for the APDS9007 Analog Ambient Light Sensor
===================================

The [APDS9007](http://www.mouser.com/ds/2/38/V02-0512EN-4985.pdf) is a simple, low-cost ambient light sensor from Avago. This sensor outputs a current that is log-proportional to the absolute brightness in Lux. A load resistor is connected to the output of the sensor and used to generate a voltage which can be read to determine the brightness.

Because the imp draws a small input current on analog input pins, and because the output current of this part is very low, a buffer is recommended between the load resistor and the imp for best accuracy.

**To add this library to your project, add** `#require "APDS9007.class.nut:2.0.0"` **to the top of your device code**

## Hardware

The APDS9007 should be connected as follows:

![APDS9007 Circuit](./circuit.png)

## Class Usage

### Constructor

To instantiate a new APDS9007 object, you need to pass in the configured analog input pin the sensor is connected to, the value of the load resistor, and an optional configured digital output enable pin.

```squirrel
const RLOAD = 47000.0

analogInputPin <- hardware.pin5
analogInputPin.configure(ANALOG_IN)

enablePin <- hardware.pin7
enablePin.configure(DIGITAL_OUT, 0)

lightsensor <- APDS9007(analogInputPin, RLOAD, enablePin)
```

### Class Methods

### enable([state])

Enable (state = true) or disable (state = false) the APDS9007. By default the state is set to true. If an enable pin is configured the device must be enabled before attempting to read the light level.  To get an accurate reading the sensor must be enabled for 5 seconds before taking a reading.

```squirrel
lightsensor.enable(true);
```

### getPointsPerReading()

The **getPointsPerReading()** function returns the number of readings taken and internally averaged to produce a light level result. By default points per reading is set to 10.

```squirrel
server.log( lightsensor.getPointsPerReading() );
```

### setPointsPerReading(pointsPerReading)

The **setPointsPerReading()** function sets the number of readings taken and internally averaged to produce a light level result.  The points per reading value is returned.  By default points per reading is set to 10.

```squirrel
// Set number of readings to be averaged to 15.  Slower than default, but more precise.
lightsensor.setPointsPerReading(15);
```

### read([callback])

The **read()** function reads and returns a table with a key of *brightness* containing the ambient light level in [Lux](http://en.wikipedia.org/wiki/Lux). If a callback is supplied, the read will execute asynchronously and the result table  will be passed to the callback function – if no callback is supplied, the read will execute synchronously and a table containing the sensor data will be returned.

```squirrel
lightsensor.read(function(result) {
    if ("err" in result) {
        server.log("Error Reading APDS9007: " + result.err);
        return;
    }
    server.log("Light level = " + result.brightness + " Lux");
});
```

Note If an error occured during the read, an err key will be present in the data – you should always check for the existance of the err key before using the results.

## Example

```squirrel
#require "APDS9007.class.nut:2.0.0"

// value of load resistor on ALS
const RLOAD = 47000.0

// use pin#5 as analog in
analogInputPin <- hardware.pin5
analogInputPin.configure(ANALOG_IN)

// use pin#7 as digital out
enablePin <- hardware.pin7
enablePin.configure(DIGITAL_OUT, 0)

// initialize driver class
lightsensor <- APDS9007(analogInputPin  RLOAD  enablePin)

// enable sensor
lightsensor.enable(true);

// get readout
readLightLevel <- @() lightsensor.read(function(result) {
    if ("err" in result) {
        server.log("Error Reading APDS9007: " + result.err);
        return;
    }
    server.log("Light level = " + result.brightness + " Lux");
    imp.wakeup(2, readLightLevel); // repeat in 2 seconds
});

// start reading light level every 2 seconds
readLightLevel();
```

## License

The APDS9007 library is licensed under the [MIT License](./LICENSE).

## Development

This repository uses [git-flow](http://jeffkreeftmeijer.com/2010/why-arent-you-using-git-flow/).
Please make your pull requests to the __develop__ branch.
