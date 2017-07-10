/***************************************************************

PHOSPHOR
Sohan Murthy
2017

PHOSPHOR is an LED art installation at Amino's
(www.amino.com) headquarters in San Francisco. This
program controls 400 individually addressable LEDs
through a variety of procedurally generated patterns,
each designed to accent the workspace by their curious
nature.

The system consists of a Raspberry Pi 3, FadeCandy controller,
and WS2811 LEDs.

Special thanks to Mark Slee and Heron Arts for developing
LX Studio and the P3LX library, which powers PHOSPHOR.

****************************************************************/

import ddf.minim.*;

final static int INCHES = 1;
final static int FEET = 12*INCHES;
final static int SECONDS = 1000;
final static int MINUTES = 60*SECONDS;

Model model;
LXOutput output;
P3LX lx;
UI3dComponent pointCloud;


void setup() {
  
  // Create the model, which describes where the light points are
  model = new Model();
  
  // Create the P3LX engine
  lx = new P3LX(this, model);
  
  // Set the patterns
  lx.setPatterns(new LXPattern[] {
    
    new Shuffle(lx),    
    new Quilt(lx),
    new Squares(lx),
    new Fountain(lx),
    new ColorWaves(lx),
    new AminoLogo(lx)
    
  });
  
  //Sets transition type 
  final LXTransition multiply = new MultiplyTransition(lx).setDuration(1*MINUTES);
  for (LXPattern p : lx.getPatterns()) {
    p.setTransition(multiply);
  }
  //Auto transitions patterns after a set period of time
  lx.enableAutoTransition(10*MINUTES);
  
  //Output to LEDs
  output = buildOutput();
  
  //Adds UI elements for simulation
  //COMMENT out when running locally on a Raspberry Pi
  size(800, 600, P3D);
  lx.ui.addLayer(
    new UI3dContext(lx.ui) 
    .setCenter(model.cx, model.cy, model.cz)
    .setRadius(5*FEET)
    .setTheta(PI/9)
    .setPhi(PI/24)    
    .addComponent(pointCloud = new UIPointCloud(lx, model).setPointSize(4))
  );

}


void draw() {
  background(#292929);
}