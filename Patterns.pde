/*************************

Amino Logo

**************************/
class AminoLogo extends LXPattern{
    
  class Amino extends LXLayer {
 
  PImage img;
  
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

***************************/

class Squares extends LXPattern {
  
 
  private final SinLFO speed = new SinLFO(7500, 9500, 16000);
  private final SawLFO move = new SawLFO(TWO_PI, 0, speed);
  private final SinLFO tight = new SinLFO(10.3, 10.8, 18000);
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

*******************/

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
    lx.cycleBaseHue(5*MINUTES);
  }
}


class Shuffle extends LXPattern {

  class Shuff extends LXLayer {

    private final Click click = new Click(random(7000, 13000));
    private final QuadraticEnvelope px = new QuadraticEnvelope(0, 0, 0).setEase(QuadraticEnvelope.Ease.BOTH);
    private final QuadraticEnvelope py = new QuadraticEnvelope(0, 0, 0).setEase(QuadraticEnvelope.Ease.BOTH);
    ;  
    private final SinLFO size = new SinLFO(5*INCHES, 10*INCHES, random(3000, 9000));
    private final SinLFO sat = new SinLFO(45, 140, random(6000, 17000));

    Shuff(LX lx) {
      super(lx);
      addModulator(click).start();
      addModulator(px);
      addModulator(py);
      addModulator(size).start();
      addModulator(sat).start();
      init();
    }

    public void run(double deltaMs) {
      if (click.click()) {
        init();
      }
      for (LXPoint p : model.points) {
        
        //Squares
      float dx = abs(p.x - px.getValuef());
      float dy = abs(p.y - py.getValuef());
      float b = 100 - (100/size.getValuef()) * max(dx, dy);
      
        if (b > 0) {
          blendColor(p.index, LXColor.hsb(
            (lx.getBaseHuef() + abs(p.x - model.cx) / model.xRange * 180 + abs(p.y - model.cy) / model.yRange * 180) % 360, 
            min(100, sat.getValuef()), 
            b), LXColor.Blend.LIGHTEST
            );
        }
      }
      lx.cycleBaseHue(8*MINUTES);
    }

    private void init() {
      px.setRangeFromHereTo(random(model.xMin, model.xMax)).setPeriod(random(3800, 6000)).start();
      py.setRangeFromHereTo(random(model.xMin, model.xMax)).setPeriod(random(3800, 6000)).start();
    }
  }

  Shuffle(LX lx) {
    super(lx);
    for (int i = 0; i < 8; ++i) {
      addLayer(new Shuff(lx));
    }
  }

  public void run(double deltaMs) {
    setColors(#000000);
  }
}




class Popups extends LXPattern {
 
  class Popup extends LXLayer {
    
    private final Accelerator xPos = new Accelerator(0, 0, 0);
    private final Accelerator yPos = new Accelerator(0, 10, 2);
    private final float expand;
    private final int hOffset;

    Popup(LX lx, int o) {
      super(lx);
      addModulator(xPos).start();
      addModulator(yPos).start();
      init();
      expand = random(5,45);
      hOffset = o;
    }

    public void run(double deltaMs) {
      boolean touched = false;
      for (LXPoint p : model.points) {
          float dx = abs(p.x/2 - xPos.getValuef());
          float dy = abs(p.y*1.4 - yPos.getValuef());
          float b = 100 - (100/constrain(((int) yPos.getValue()-expand), 6,12)) * max(dx, dy);
        if (b > 0) {
          touched = true;
          blendColor(p.index, LXColor.hsb(
            (lx.getBaseHuef() + hOffset) % 360, 
            35, 
            b), LXColor.Blend.LIGHTEST);
        }
      }
      if (!touched) {
        init();
      }
    }

    private void init() {
      xPos.setValue(random(1, 19));
      yPos.setValue(random(model.yMin-5, model.yMin-10));      
      yPos.setVelocity(random(2, 8));
      //yPos.setAcceleration(random(4,6));
    }
  }
 

  Popups(LX lx) {
    super(lx);
    for (int i = 0; i < 5; ++i) {
      addLayer(new Popup(lx, i*23));
    }
  }

  public void run(double deltaMs) {
    setColors(#000000);
  }
    
  
}