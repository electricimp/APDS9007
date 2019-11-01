# APDS-9007 Analog Ambient Light Sensor 3.0.0 #

The [APDS-9007](http://www.mouser.com/ds/2/38/V02-0512EN-4985.pdf) is a simple, low-cost ambient light sensor from Avago. This sensor outputs a current that is log-proportional to the absolute brightness in Lux. A load resistor is connected to the output of the sensor and used to generate a voltage which can be read to determine the brightness.

**To include this library in your project, add** `#require "APDS9007.class.nut:3.0.0"` **at the top of your device code**

![Build Status](https://cse-ci.electricimp.com/app/rest/builds/buildType:(id:Apds9007_BuildAndTest)/statusIcon)

## Hardware ##

The APDS9007 should be connected as follows:

![APDS9007 Circuit](./circuit.png)

**Note** Because imps draw a small input current on analog input pins, and because the output current of this part is very low, we recommended that for best accuracy you place a buffer between the load resistor and the imp.

## Class Usage ##

### Constructor: APDS9007(*inputPin, rLoad[, enablePin]*) ###

To instantiate a new APDS9007 object, you need to pass in the configured analog input pin to which the sensor is connected, the value of your chosen load resistor and, optionally, a configured digital output sensor-enable pin.

```squirrel
const RLOAD = 47000.0;

analogInputPin <- hardware.pin5;
analogInputPin.configure(ANALOG_IN);

enablePin <- hardware.pin7;
enablePin.configure(DIGITAL_OUT, 0);

lightsensor <- APDS9007(analogInputPin, RLOAD, enablePin);

// Using an enable pin so must enable sensor
lightsensor.enable(true);
```

## Class Methods ##

### enable(*[state]*) ###

This method enables or disables the APDS-9007.

If an enable pin has been configured, the APDS-9007 **must** be enabled before attempting to read the light level. To get an accurate reading, the sensor must be enabled for at least five seconds before taking a reading. However, the library manages this for you &mdash; see [*read()*](#readcallback), below.

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *state* | Boolean | No | Enable (`true`) or disable (`false`) the sensor. Default: `true` |

#### Return Value ####

Nothing.

#### Example ####

```squirrel
lightsensor.enable(true);
```

### read(*[callback]*) ###

This method returns the ambient light level in [Lux](http://en.wikipedia.org/wiki/Lux).

The sensor **must** be enabled for at least five seconds before a reading is returned. The library manages this for you by delaying the reading until those five seconds have passed. The five-second period is calculated from the moment at which the sensor is enabled. If an enable pin has been provided, this is when `enable(true)` is called; if no enable pin is specified, the sensor is auto-enabled when the class is instantiated.

**Note** Any post-enable delay will extend the time that *read()* blocks if it is called synchronously. If the method is called asynchronously, any delay will simply extend the time before the callback is executed.

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *callback* | Function | No | An optional function that will be called after a reading has been taken |

If a callback is supplied, *read()* will execute asynchronously and a result table (see **Return Value**) will be passed to the callback function. If no callback is supplied, *read()* will execute synchronously and the result table will be returned.

#### Return Value ####

Table or `null` &mdash; If no callback is supplied, the returned table will contain the key *brightness* with the reading in Lux, or the key *err* with an error message. If a callback is supplied, *read()* will return `null`.

#### Asynchronous Example ####

```squirrel
lightsensor.read(function(result) {
    if ("err" in result) {
        server.error("Error Reading APDS-9007: " + result.err);
    } else {
        server.log("Light level = " + result.brightness + " Lux");
    }
});
```

#### Synchronous Example ####

```squirrel
local result = lightsensor.read();
if ("err" in result) {
    server.error("Error Reading APDS-9007: " + result.err);
} else {
    server.log("Light level = " + result.brightness + " Lux");
}
```

### getPointsPerReading() ###

This method gets the number of readings (data points) taken and internally averaged to produce a light-level result. By default, the number of data points per reading is set to ten.

#### Return Value ####

Integer &mdash; The number of data points averaged per reading.

#### Example ####

```squirrel
server.log(lightsensor.getPointsPerReading());
```

### setPointsPerReading(*pointsPerReading*) ##

This method sets the number of readings (data points) taken and internally averaged to produce a light-level result. The points per reading value is returned. By default, the number of data points per reading is set to ten. The higher the value, the more samples are taken and the more precise the reading, but the longer the sensor takes to return the reading. If the *read()* method *(see above)* is called synchronously, it will block until all the samples have been taken and averaged, so we recommend using *read()* asynchronously.

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *pointsPerReading* | Integer | Yes | The new number of data points averaged per reading |

#### Return Value ####

Integer &mdash; The applied number of data points averaged per reading.

#### Example ####

```squirrel
// Set number of readings to be averaged to 15.
// Slower than default, but more precise.
lightsensor.setPointsPerReading(15);
```

## Full Example ##

Example code can be found in the [examples directory](./examples).

## Testing ##

This repository contains [tests](./tests) to be run with [impWorks™ *impt*](https://github.com/electricimp/imp-central-impt) tests. It also includes a test configuration file (`.impt.test`).

Tests can be launched with:

```bash
impt test run
```

To run the tests with your own configuration &mdash; for example, to specify one of your own device groups as the collection of devices which will run the tests &mdash; call:

```bash
impt test update --dg <DEVICE_GROUP_IDENTIFIER>
```

Please see [the *impt* documentation](https://github.com/electricimp/imp-central-impt/blob/master/CommandsManual.md#test-update) for guidance on other changes you can make to `.impt.test`, or to see how to create a new test configuration file.

## License ##

This library is licensed under the [MIT License](./LICENSE).
