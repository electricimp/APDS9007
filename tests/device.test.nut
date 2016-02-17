/**
 * APDS9007 Library test cases
 */

 class TestCase1 extends ImpTestCase {

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

        // enable sensor
        this._lightSensor.enable(true);
    }

    /**
     * Test sensor readout in async mode
     */
    function testAsyncReadout() {
        return Promise(function (ok, err) {

            local startMillis = hardware.millis();

            this._lightSensor.read(function (result) {

                if ("err" in result) {
                    err("Error Reading APDS9007: " + result.err);
                    return;
                }

                try {
                    // check that first readout arrives after 5s (+-200ms)
                    this.assertClose(5000, hardware.millis() - startMillis, 200);
                    // check that light level reported is meaningful
                    this.assertTrue(result.brightness > 0, "Light level should be greater than zero");
                } catch (e) {
                    err(e);
                    return;
                }

                // success
                ok("Light level is " + result.brightness + " Lux");

            }.bindenv(this));

        }.bindenv(this));
    }

    /**
     * Disable sensor
     */
    function tearDown() {
        this._lightSensor.enable(false);
    }
 }
