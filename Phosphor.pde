/********************************************************

PHOSPHOR
by Sohan Murthy

PHOSPHOR is a Processing sketch that powers an LED art
installation at Amino's (www.amino.com) office in
San Francisco. It controls 400 individually addressable
LEDs through a variety of patterns procedurally generated
via LX Studio.
 
*********************************************************/

import ddf.minim.*;

//Add some units! inches, feet, seconds, minutes
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
    new Squares(lx),
    new ColorWaves(lx),
    new Quilt(lx),
    new AminoLogo(lx),
   

  });
  
  //sets transition type 
  final LXTransition multiply = new MultiplyTransition(lx).setDuration(15*SECONDS);
  for (LXPattern p : lx.getPatterns()) {
    p.setTransition(multiply);
  }
  //Auto transitions patterns after a set period of time
  lx.enableAutoTransition(5*MINUTES);
  
  //output to LEDs
  output = buildOutput();
  
  // Adds UI elements for simulation -- COMMENT all of this out if running on Linux in a headless environment
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