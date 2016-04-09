/**
 * APDS9007 Library test cases
 */
 class APDS9007_TestCase extends ImpTestCase {

    _lightSensor = null;

    /**
     * Initialize sensor
     */
    function setUp() {
        // use pin#5 as analog input
        local analogInputPin = hardware.pin5;
        analogInputPin.configure(ANALOG_IN);

        // use pin#7 as enable poin
        local enablePin = hardware.pin7;
        enablePin.configure(DIGITAL_OUT, 0);

        // initialize driver class
        this._lightSensor = APDS9007(analogInputPin, 47000, enablePin);

        return "Sensor initialized";
    }

    /**
     * Test sensor readout in async mode
     */
    function test_Async_Readout() {
        return Promise(function (ok, err) {

            this._lightSensor.enable(true);
            local startMillis = hardware.millis();

            this._lightSensor.read(function (r) {

                if ("err" in r) {
                    err("Error Reading APDS9007: " + r.err);
                    return;
                }

                try {
                    // check that first readout arrives after [ENABLE_TIMEOUT] (+-250ms)
                    this.assertClose(APDS9007.ENABLE_TIMEOUT.tofloat(), hardware.millis() - startMillis, 250);
                    // check that light level reported is meaningful
                    this.assertTrue(r.brightness > 0, "Light level should be greater than zero");
                } catch (e) {
                    err(e);
                    return;
                }

                ok("Light level is " + r.brightness + " Lux");

            }.bindenv(this));

        }.bindenv(this))

        .then(function (e) {
            this._lightSensor.enable(false);
         }.bindenv(this));
    }

    /**
     * Test sensor readout in sync mode without delay
     * Should produce an error
     */
    function test_Sync_Readout_Without_Timeout() {
        local err;
        this._lightSensor.enable(true);

        // reading before timeout should raise an error
        try {
            local r = this._lightSensor.read();
        } catch (e) {
            err = e;
        }

        this.assertTrue(err == APDS9007.ERR_SENSOR_NOT_READY);
        this._lightSensor.enable(false);
    }

    /**
     * Test sensor readout in sync mode after [ENABLE_TIMEOUT + 0.5s] delay
     * Reading should be successfull
     */
    function test_Sync_Readout_After_Timeout() {
        return Promise(function (ok, err) {

            this._lightSensor.enable(true);

            imp.wakeup(APDS9007.ENABLE_TIMEOUT.tofloat() / 1000 + 0.5, function() {
                try {
                    local r = this._lightSensor.read();
                    this.assertTrue(r.brightness > 0);
                    ok("Light level is " + r.brightness + " Lux");
                } catch (e) {
                    err(e);
                }
            }.bindenv(this));

        }.bindenv(this))

        .then(function (e) {
            this._lightSensor.enable(false);
         }.bindenv(this));
    }

    /**
     * Test sensor readout in async mode after initial delay of [ENABLE_TIMEOUT - 0.25s]
     * Reading should arrive in ~0.25s
     */
    function test_Async_Readout_After_Initial_Delay() {
        return Promise(function (ok, err) {

            this._lightSensor.enable(true);

            imp.wakeup(APDS9007.ENABLE_TIMEOUT.tofloat() / 1000 - 0.25, function () {

                local startMillis = hardware.millis();
                this._lightSensor.read(function (r) {

                    if ("err" in r) {
                        err("Error Reading APDS9007: " + r.err);
                        return;
                    }

                    try {
                        // check that first readout arrives after 250ms (+-100)
                        this.assertClose(250, hardware.millis() - startMillis, 250);
                        // check that light level reported is meaningful
                        this.assertTrue(r.brightness > 0, "Light level should be greater than zero");
                    } catch (e) {
                        err(e);
                        return;
                    }

                    ok("Light level is " + r.brightness + " Lux");

                }.bindenv(this));
            }.bindenv(this));
        }.bindenv(this))

        .then(function (e) {
            this._lightSensor.enable(false);
         }.bindenv(this));
    }

 }
