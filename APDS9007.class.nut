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

    static version = [2,0,0];

    // For accurate readings time needed to wait after enabled
    static ENABLE_TIMEOUT = 5.0;

    // value of load resistor on ALS (device has current output)
    _rload              = 0.0;
    _als_pin            = null;

    constructor(als_pin, rload, als_en = null) {
    _als_en             = false;

    _points_per_read    = 0.0;
    _enable_flag        = false;
    _enabled            = false;
        _als_pin = als_pin;
        _als_en = als_en;
        _rload = rload;

        _enabled = _als_en ? false : true;
        _points_per_read = 10.0;
    }

    // enable/disable sensor
    function enable(state = true) {
        if (_als_en && state) {
            _als_en.write(1);
            _enable_flag = true;
            imp.wakeup(ENABLE_TIMEOUT, function() {
                _enabled = true;
                _enable_flag = false;
            }.bindenv(this))
        }
        if (_als_en && !state) {
            _als_en.write(0);
            _enabled = false;
        }
    }

    function getPointsPerReading() {
        return _points_per_read
    }

    function setPointsPerReading(points) {
        // Force to a float
        if (typeof points == "integer" || typeof points == "float") {
            _points_per_read = points * 1.0;
        }
        return _points_per_read;
    }

    // read the ALS
    function read(cb = null) {
        local result = {};

        if(_enabled) {
            local Vpin = 0;
            local Vcc = 0;

            // average several readings for improved precision
            for (local i = 0; i < _points_per_read; i++) {
                Vpin += _als_pin.read();
                Vcc += hardware.voltage();
            }

            Vpin = (Vpin * 1.0) / _points_per_read;
            Vcc = (Vcc * 1.0) / _points_per_read;
            Vpin = (Vpin / 65535.0) * Vcc;

            local Iout = (Vpin / _rload) * 1000000.0; // current in µA
            result = {"brightness" : math.pow(10.0,(Iout/10.0))};

            // Return table if no callback was passed
            if (cb == null) { return result; }

            // Invoke the callback if one was passed
            imp.wakeup(0, function() { cb(result); });
        } else {
            // Loop if in enable timeout
            if(_enable_flag) {
                imp.wakeup(1, function() {
                    read(cb);
                }.bindenv(this));
            } else {
                result = {"err" : "Sensor Not Enabled"};

                // Return table if no callback was passed
                if (cb == null) { return result; }

                // Invoke the callback if one was passed
                imp.wakeup(0, function() { cb(result); }.bindenv(this));
            }
        }

    }

}
