##PHOSPHOR

<img src="https://pbs.twimg.com/media/C1lj1e2UsAAk71E.jpg" width="640">

PHOSPHOR is a Processing sketch that powers an LED art installation on display at [Amino's](https://www.amino.com) office in San Francisco.  It controls 400 individually addressable LEDs through a variety of procedurally generated patterns.

###Installation:

1. Download [Processing 3](https://processing.org/download/?processing)
2. Install the [FTDI interface for p9813 LEDs](https://github.com/PaintYourDragon/p9813) Processing library (OPTIONAL)
3. Clone this repo into your Processing sketchbook folder

If you aren't going to be using p9813 LEDs - or simply want to see a simulation of the LEDs in action - remove all code referencing the `TotalControl` library. P3LX natively supports a variety of protocols, like [Open Pixel Control](openpixelcontrol.org) and [Fadecandy](https://learn.adafruit.com/led-art-with-fadecandy/intro). If you're starting from scratch, you're very much better off using WS2812 (e.g. [Adafruit NeoPixel](https://learn.adafruit.com/adafruit-neopixel-uberguide/)) or a similarly well-supported chipset. I chose p9813 LEDs for the Amino piece simply because they were freely available at the time. As the old saying goes, "Free LEDs are better than no LEDs."

###Credits:

* [Mark Slee](https://github.com/mcslee/) & [Heron Arts](https://github.com/heronarts/): P3LX Processing 3 harness for LX lighting engine - https://github.com/heronarts/P3LX
* [Phillip Burgess](https://github.com/PaintYourDragon/): FTDI interface for p9813 LEDs - https://github.com/PaintYourDragon/p9813
