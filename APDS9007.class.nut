/**
 * This file is licensed under the MIT License
 * http://opensource.org/licenses/MIT
 * @copyright (c) 2015 Electric Imp
 */

/**
 * Driver for the APDS9007 Analog Ambient Light Sensor
 * @version 2.0.0
 */
class APDS9007 {

    static version = [2, 0, 0];

    // For accurate readings time needed to wait after enabled
    static ENABLE_TIMEOUT = 5.0;

    // errors
    static ERR_SENSOR_NOT_READY = "Sensor is not ready";
    static ERR_SENSOR_NOT_ENABLED = "Sensor is not enabled. Call enable(true) before reading.";

    // value of load resistor on ALS (device has current output)
    _rload              = 0.0;
    _input_pin          = null;
    _enable_pin         = null;

    _points_per_read    = 10.0;

    // stores time when enable() was last called
    _enabled_at         = null;

    /**
     * @param {Pin} input_pin - analog input pin
     * @param {float} rload - value of load resistor on ALS (device has current output)
     * @param {Pin} enable_pin - enable pin
     */
    constructor(input_pin, rload, enable_pin) {
        _input_pin = input_pin;
        _enable_pin = enable_pin;
        _rload = rload;
    }

    /**
     * Enable/disable sensor
     *
     * To get an accurate reading the sensor must be enabled
     * for 5 seconds before taking a reading.
     *
     * @param {bool} state - sensor enable flag
     * @return {null}
     */
    function enable(state = true) {
        if (state) /* enabling */ {
            // store time enable() was called
            _enabled_at = hardware.millis();
            _enable_pin.write(1);
        } else /* disabling */ {
            _enable_pin.write(0);
            _enabled_at = null;
        }
    }

    /**
     * Returns the number of readings taken and internally
     * averaged to produce a light level result.
     *
     * @return {float} - current points per reading
     */
    function getPointsPerReading() {
        return _points_per_read;
    }

    /**
     * Sets the number of readings taken and internally
     * averaged to produce a light level result.
     *
     * @return {integer|float} - points per reading
     */
    function setPointsPerReading(points) {
        // Force to a float
        _points_per_read = points.tofloat();
        return _points_per_read;
    }

    /**
     * Get reading
     * Assumes that the sensor is enabled and enable timeout has passed
     * @private
     */
    function _read() {
        local Vpin = 0;
        local Vcc = 0;

        // average several readings for improved precision
        for (local i = 0; i < _points_per_read; i++) {
            Vpin += _input_pin.read();
            Vcc += hardware.voltage();
        }

        Vpin = (Vpin * 1.0) / _points_per_read;
        Vcc = (Vcc * 1.0) / _points_per_read;
        Vpin = (Vpin / 65535.0) * Vcc;

        local Iout = (Vpin / _rload) * 1000000.0; // current in µA
        return {"brightness" : math.pow(10.0, (Iout / 10.0))};
    }

    /**
     * Reads and returns a table with a key of brightness
     * containing the ambient light level in Lux.
     *
     * @param {function(result)|null} cb - Callback executed on reading availability. If no callback specified, reading is returned.
     * @return {null|{brightness}}
     */
    function read(cb = null) {

        if (_enabled_at /* sensor is enabled */) {

            local seconds_since_enabled = (hardware.millis() - _enabled_at) / 1000;

            if (cb /* we're async */) {

                if (ENABLE_TIMEOUT <= seconds_since_enabled) {
                    // timeout has passed, we're good to go
                    imp.wakeup(0, function() { cb(_read()); }.bindenv(this));
                } else {
                    // we will be able to read once timeout passes
                    imp.wakeup(
                        ENABLE_TIMEOUT - seconds_since_enabled,
                        (@() read(cb)).bindenv(this)
                    );
                }

            } else /* we're sync */ {

                if (ENABLE_TIMEOUT > seconds_since_enabled) {
                    throw ERR_SENSOR_NOT_READY;
                }

                return _read();
            }

        } else /* sensor is not enabled */ {

            if (cb /* we're async */) {

                // pass error to callback
                imp.wakeup(0, function() { cb({err = ERR_SENSOR_NOT_ENABLED}); }.bindenv(this));

            } else /* we're sync*/ {
                throw ERR_SENSOR_NOT_ENABLED;
            }
        }

    }

}
