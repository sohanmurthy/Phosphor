/********************************************************

PHOSPHOR
by Sohan Murthy

PHOSPHOR is a Processing sketch that powers an LED art
installation at Amino's (www.amino.com) office in
San Francisco. It controls 400 individually addressable
LEDs through a variety of procedurally generated
patterns.

Credits:

Mark Slee & Heron Arts:
P3LX Processing 3 harness for LX lighting engine
https://github.com/heronarts/P3LX
 

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
    
    new AminoLogo(lx),
    new Bubbles(lx),
    new ColorWaves(lx),
    new Joiners(lx),
    new DiamondDroplets(lx),
    new Balls(lx),
    new Runners(lx),
    new Graph(lx),
    new StarryNight(lx),
    new Pinwheel(lx, false),
    new GameOfLife(lx),
    new StarDroplets(lx),
    new FunkyWave(lx),
    new DepthsOfSpace(lx),
    new Warp(lx),
    new Scatters(lx),
    new Rain(lx),
    new RoundDroplets(lx),
    new Quilt(lx),
    new Swarm(lx),
    new Swings(lx)

  });
  
  //Sets the transition type ("multiply" is highly preferred!) 
  final LXTransition multiply = new MultiplyTransition(lx).setDuration(15*SECONDS);
  for (LXPattern p : lx.getPatterns()) {
    p.setTransition(multiply);
  }
  //Auto transitions patterns after a set period of time
  lx.enableAutoTransition(3*MINUTES);
  
  //send data to leds
  output = buildOutput();
  
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
  
  
}


void draw() {
  background(#292929);
}