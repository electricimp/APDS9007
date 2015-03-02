Driver for the APDS9007 Analog Ambient Light Sensor
===================================

Author: [Tom Byrne](https://github.com/ersatzavian/)

The [APDS9007](http://www.mouser.com/ds/2/38/V02-0512EN-4985.pdf) is a simple, low-cost ambient light sensor from Avago. This sensor outputs a current that is log-proportional to the absolute brightness in Lux. A load resistor is connected to the output of the sensor and used to generate a voltage which can be read to determine the brightness.

Because the imp draws a small input current on analog input pins, and because the output current of this part is very low, a buffer is recommended between the load resistor and the imp for best accuracy.

# Hardware

The APDS9007 should be connected as follows:

![APDS9007 Circuit](./circuit.png)

# Class Usage

## Constructor

To instantiate a new APDS9007 object, you need to pass in the configured analog input pin the sensor is connected to, the value of the load resistor, and an optional configured digital output enable pin.

```squirrel
const RLOAD = 47000.0;

analog_input_pin <- hardware.pin5;
enable_pin <- hardware.pin7;

analog_input_pin.configure(ANALOG_IN);
enable_pin.configure(DIGITAL_OUT,0);

lightsensor <- APDS9007(analog_input_pin, RLOAD, enable_pin);
```

## Reading the Sensor

The class’ **.read()** function returns the ambient light level in [Lux](http://en.wikipedia.org/wiki/Lux):

```squirrel
server.log(format("Light Level = %0.2f Lux",lightsensor.read());
```

# License

The APDS9007 library is licensed under the [MIT License](./LICENSE).
