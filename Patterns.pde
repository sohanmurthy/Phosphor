/*************************

Amino Logo

A sharp corporate logo
set against sparkly stars

**************************/
class AminoLogo extends LXPattern{
    
  class Amino extends LXLayer {
 
  PImage img;
  int xPos = (int) model.xRange;
  int yPos = (int) model.yRange;
  
  
  Amino(LX lx){
    super(lx);
    img = loadImage("img/amino.png");
  }
  
  public void run(double deltaMs){
    int yMax = 20;
    int xMax = 20;
    for(int y = 0; y < yMax; y++){
      for(int x = 0; x < xMax; x++){
         blendColor(y + (yMax*x), img.get(x, (yMax-1)-y), LXColor.Blend.LERP);
       } 
     }
   }
  }
  
  class StarLayer extends LXLayer {

    private final TriangleLFO maxBright = new TriangleLFO(0, 100, random(2000, 8000));
    private final SinLFO brightness = new SinLFO(-1, maxBright, random(3000, 9000)); 

    private int index = 0;

    private StarLayer(LX lx) { 
      super(lx);
      addModulator(maxBright).start();
      addModulator(brightness).start();
      pickStar();
    }

    private void pickStar() {
      index = (int) random(0, model.size-1);
    }

    public void run(double deltaMs) {
      if (brightness.getValuef() <= 0) {
        pickStar();
      } else {
               blendColor(index,
        LXColor.hsb(0, 0, brightness.getValuef()),
        LXColor.Blend.LIGHTEST
        );
      }
    }
  }
  
  AminoLogo(LX lx){
    super(lx);
    for (int i = 0; i < 245; ++i) {
      addLayer(new StarLayer(lx));
    }
    addLayer(new Amino(lx));
    
  }
  
  public void run(double deltaMs){
   setColors(#000000); 

  }
 
}

/**************************

Squares


****************************/

class Squares extends LXPattern {
  
 
  private final SinLFO speed = new SinLFO(7500, 9500, 16000);
  private final SawLFO move = new SawLFO(TWO_PI, 0, speed);
  private final SinLFO tight = new SinLFO(9.7, 10.4, 18000);
  private final SinLFO hr = new SinLFO(90, 300, 25000);
  
  
  Squares(LX lx) {
    super(lx);
    addModulator(hr).start();
    addModulator(tight).start();
    addModulator(speed).start();
    addModulator(move).start();

  }
  
  public void run(double deltaMs) {
    for (LXPoint p : model.points) {
     
      //Squares
      float dx = abs(p.x - model.cx);
      float dy = abs(p.y - model.cy);
      
      //"+" or "-" before move function changes direction
      //float b = 50 + 50 * sin(dx * tight + move.getValuef());
      
      float b = 50 + 50 * sin(max(dx, dy) * tight.getValuef() + move.getValuef());

      
      colors[p.index] = LXColor.hsb(
      (lx.getBaseHuef() + max(abs(p.x - model.cx), abs(p.y - model.cy)) / model.xRange * hr.getValuef()) % 360,
      65,
      b);

    }
    
  lx.cycleBaseHue(6*MINUTES);
    
  }
}


/******************

ColorWaves


********************/

class ColorWaves extends LXPattern {
 
  class ColorWave extends LXLayer {

  private final SinLFO hr = new SinLFO(45, 120, 34000);

  private final SinLFO speed = new SinLFO(7500, 9000, 27000);
  private final SawLFO move = new SawLFO(TWO_PI, 0, speed);
  private final SinLFO tight = new SinLFO(5, 7, 22000);
  
  private int xPos;
  private int hOffset;
  private float slope;
  private int brightness;
  
  ColorWave(LX lx, float s, int x, int o, int b) {
    super(lx);
    brightness = b;
    slope = s;
    xPos = x;
    hOffset = o;
    addModulator(hr).start();
    addModulator(speed).start();
    addModulator(move).start();
    addModulator(tight).start();
  }

  public void run(double deltaMs) {
    for (LXPoint p : model.points) {
      
      float dx = (abs(p.x - (model.cx + xPos*FEET)) - slope * abs(p.y - (model.cy + 16*FEET))) / model.yRange;
      float b = brightness+brightness*sin(dx * tight.getValuef() + move.getValuef());

      blendColor(p.index, LXColor.hsb(
        (lx.getBaseHuef() + hOffset + abs(p.y - model.cy) / model.yRange * hr.getValuef() + abs(p.x - model.xMin) / model.xRange * hr.getValuef()) % 360, 
        65, 
        b
        ), LXColor.Blend.LIGHTEST);
    }
  }
}


ColorWaves(LX lx) {
  super(lx);
    addLayer(new ColorWave(lx, 0.8 , 8, 0, 50));
    addLayer(new ColorWave(lx, 1.5, -8, 120, 50));
}
 
  public void run(double deltaMs) {
    setColors(#000000);
  }
  
}


/*************************

Quilt

**************************/
class Quilt extends LXPattern {

  final SinLFO[] positions = new SinLFO[80];
  final SinLFO[] widths = new SinLFO[30];

  Quilt(LX lx) {
    super(lx);
    for (int i = 0; i < positions.length; ++i) {
      SinLFO rate = new SinLFO(18000, 25000, 19000);
      addModulator(rate.randomBasis()).start();
      addModulator(positions[i] = new SinLFO(0, 5, rate));
      positions[i].randomBasis().start();
    }
    for (int i = 0; i < widths.length; ++i) {
      SinLFO rate = new SinLFO(18000, 25000, 19000);
      addModulator(rate.randomBasis()).start();
      addModulator(widths[i] = new SinLFO(6*INCHES, 2*FEET, rate));
      widths[i].randomBasis().start();
    }
  }

  public void run(double deltaMs) {
    for (LXPoint p : model.points) {
      float w1 = widths[(int) (p.y % widths.length)].getValuef();
      float w2 = widths[(int) (p.x % widths.length)].getValuef();
      colors[p.index] = LXColor.hsb(
        (lx.getBaseHuef() + max(abs(p.x - model.cx), abs(p.y - model.cy)) / model.xRange * 360) % 360, 
        65, 
        max(0, 100 - 100 / w1 * model.xRange * abs(p.x/model.xRange - positions[(int) (p.y % positions.length)].getValuef()))
        );
      addColor(p.index, LXColor.hsb(
      (lx.getBaseHuef() + max(abs(p.x - model.cx), abs(p.y - model.cy)) / model.xRange * 360) % 360,
        65,
        max(0, 100 - 100 / w2 * model.yRange * abs(p.y/model.yRange - positions[(int) (p.x % positions.length)].getValuef()))
        ));
    }
    lx.cycleBaseHue(6*MINUTES);
  }
}