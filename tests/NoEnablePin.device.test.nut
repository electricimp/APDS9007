/**
 * APDS9007 Library test cases
 * Configuration without enable pin
 */
 class NoEnablePin_TestCase extends ImpTestCase {

    _lightSensor = null;

    /**
     * Initialize sensor
     */
    function setUp() {
        return Promise(function (ok, err) {
            // use pin#5 as analog input
            local analogInputPin = hardware.pin5;
            analogInputPin.configure(ANALOG_IN);

            // use pin#7 as enable pin
            local enablePin = hardware.pin7;
            enablePin.configure(DIGITAL_OUT, 0);

            // enable sensor
            enablePin.write(1);

            // initialize driver class
            this._lightSensor = APDS9007(analogInputPin, 47000 /* no enable pin*/);

            // wait for warm-up and start tests
            imp.wakeup(APDS9007.ENABLE_TIMEOUT.tofloat() / 1000, function() {
                ok("Sensor initialized");
            }.bindenv(this));

        }.bindenv(this))
    }

    /**
     * Test sensor readout in sync mode without delay
     * Should NOT produce an error
     */
    function test1_Sync_Readout_Without_Timeout() {
        local r = this._lightSensor.read();
        this.assertGreater(r.brightness, 0);
    }

    /**
     * Test sensor readout in async mode
     */
    function test2_Async_Readout() {
        return Promise(function (ok, err) {

            local startMillis = hardware.millis();

            this._lightSensor.read(function (r) {

                if ("err" in r) {
                    err("Error Reading APDS9007: " + r.err);
                    return;
                }

                try {
                    // check that first readout arrives after 0+-300ms
                    this.assertClose(0, hardware.millis() - startMillis, 300);

                    // check that light level reported is meaningful
                    this.assertTrue(r.brightness > 0, "Light level should be greater than zero");
                } catch (e) {
                    err(e);
                    return;
                }

                ok("Light level is " + r.brightness + " Lux");

            }.bindenv(this));

        }.bindenv(this));
    }

 }
