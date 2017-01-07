/********************************************************

PHOSPHOR
by Sohan Murthy

PHOSPHOR is a software package that powers an LED art
installation at Amino's (www.amino.com) office in
San Francisco. It controls 400 individually addressable
LEDs through a variety of procedurally generated
patterns.

Credits:

  Mark Slee & Heron Arts:
  P3LX Processing 3 harness for LX lighting engine
  https://github.com/heronarts/P3LX
  
  and

  Phillip Burgess:
  FTDI interface for p9813 LEDs
  https://github.com/PaintYourDragon/p9813

*********************************************************/

import TotalControl.*;
import ddf.minim.*;

//Add some units! inches, feet, seconds, minutes
final static int INCHES = 1;
final static int FEET = 12*INCHES;
final static int SECONDS = 1000;
final static int MINUTES = 60*SECONDS;

Model model;
P3LX lx;
UI3dComponent pointCloud;
TotalControl tc;

//create an array to store physical order of LEDs on the strand 
int remap[] = new int[400];
int i = 0;

void setup() {
  
  // Create the model, which describes where the light points are
  model = new Model();
  
  // Create the P3LX engine
  lx = new P3LX(this, model);
  
  // Set the patterns
  lx.setPatterns(new LXPattern[] {
    
    new Graph(lx),
    new Bubbles(lx),
    new AminoLogo(lx),
    new Swarm(lx),
    new DepthsOfSpace(lx),
    new ColorWaves(lx),
    new Joiners(lx),
    new DiamondDroplets(lx),
    new Balls(lx),
    new Swings(lx),
    new Warp(lx),
    new Runners(lx),
    new Scatters(lx),
    new Rain(lx),
    new RoundDroplets(lx),
    new StarryNight(lx),
    new Pinwheel(lx,false),
    new Quilt(lx),
    new StarDroplets(lx),
    new FunkyWave(lx),

  });
  
  //Sets the transition type ("multiply" is highly preferred!) 
  final LXTransition multiply = new MultiplyTransition(lx).setDuration(15*SECONDS);
  for (LXPattern p : lx.getPatterns()) {
    p.setTransition(multiply);
  }
  //Auto transitions patterns after a set period of time
  lx.enableAutoTransition(3*MINUTES);
  
  // Adds UI elements -- COMMENT all of this out if running on Linux in a headless environment
  size(800, 600, P3D);
  lx.ui.addLayer(
    new UI3dContext(lx.ui) 
    .setCenter(model.cx, model.cy, model.cz)
    .setRadius(16*FEET)
    .setTheta(PI/9)
    .setPhi(PI/24)    
    .addComponent(pointCloud = new UIPointCloud(lx, model).setPointSize(4))
  );
  
  
  //Initializes TotalControl library and remaps LX points to physical arrangement of P9813 LEDs
  //If you only want to run the UI, comment out all TotalControl related stuff.
  p9813Output();
  
}


void draw() {
  background(#292929);
  //Sends P3LX model color values to LEDs! Party time!
  tc.refresh(lx.getColors(), remap);
}