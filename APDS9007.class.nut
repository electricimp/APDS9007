/**
 * This file is licensed under the MIT License
 * http://opensource.org/licenses/MIT
 * @copyright (c) 2015 - 2016 Electric Imp
 */

/**
 * Driver for the APDS9007 Analog Ambient Light Sensor
 *
 * @author Cat Haines
 * @author Elizabeth Rhodes <betsy@electricimp.com>
 * @author Mikhail Yurasov <mikhail@electricimp.com>
 * @author Aron Steg <aron@electricimp.com>
 *
 * @version 2.2.0
 */
class APDS9007 {

    static version = [2, 2, 1];

    // For accurate readings time needed to wait after enabled [ms]
    static ENABLE_TIMEOUT = 5000;

    // errors
    static ERR_SENSOR_NOT_READY = "Sensor is not ready.";

    // value of load resistor on ALS (device has current output)
    _rload              = 0.0;
    _input_pin          = null;
    _enable_pin         = null;

    _points_per_read    = 10.0;

    // stores time when sensor will be ready to take an accurate reading
    _ready_at  = null;

    /**
     * @param {Pin} input_pin - analog input pin
     * @param {float} rload - value of load resistor on ALS (device has current output)
     * @param {Pin} enable_pin - enable pin
     */
    constructor(input_pin, rload, enable_pin = null) {
        _input_pin = input_pin;
        _enable_pin = enable_pin;
        _rload = rload;
        // if no enable pin is passed in - enable sensor immediately
        if(enable_pin == null) _ready_at = hardware.millis() + ENABLE_TIMEOUT;
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
        if (_enable_pin && state) /* enabling */ {
            _enable_pin.write(1);
            // set time when sensor will be ready to take a reading
            _ready_at = hardware.millis() + ENABLE_TIMEOUT;
        } else if (_enable_pin && !state) /* disabling */ {
            _enable_pin.write(0);
            _ready_at = null;
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
     * Reads and returns a table with a key brightness
     * containing the ambient light level in Lux or
     * a key err containing an error message.
     *
     * @param {function(result)|null} cb - Callback executed on reading availability. If no callback specified, reading table is returned.
     * @return {null|{brightness}}
     */
    function read(cb = null) {
        local result = {};
        local resultReady = false;

        if(_ready_at == null) /* Sensor not enabled */ {
            result = {"err" : ERR_SENSOR_NOT_ENABLED};
            resultReady = true;
        }  else if (hardware.millis() >= _ready_at )  /* Sensor enabled & ready*/ {
            result = _getBrightness();
            resultReady = true;
        } else  /* Sensor enabled but not ready */ {
            local delay = (_ready_at - hardware.millis() ).tofloat() / 1000;
            if (cb == null) /* We're sync - wait then take reading */ {
                imp.sleep(delay);
                result = _getBrightness();
                resultReady = true;
            } else /* We're async - retry */ {
                imp.wakeup(delay, function() { read(cb); }.bindenv(this));
            }
        }

        if(resultReady) {
            // We're sync - return result
            if (cb == null) return result;
            // We're async - pass result to callback
            imp.wakeup(0, function() { cb(result); }.bindenv(this));
        }
    }

    //  PRIVATE FUNCTIONS
    // --------------------------------------------------------------------------------------------

    /**
     * Get reading
     * Assumes that the sensor is enabled and enable timeout has passed
     * @private
     */
    function _getBrightness() {
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

}
