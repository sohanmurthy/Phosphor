
/*************************

Funky Wave

A pair of sinusoidal waves
dance around each other

**************************/
class FunkyWave extends LXPattern {
  class Wave extends LXLayer {

    final private SinLFO rate1 = new SinLFO(210000, 330000, 17000);
    final private SinLFO off1 = new SinLFO(-4*TWO_PI, 4*TWO_PI, rate1);
    final private SinLFO wth1 = new SinLFO(60, 180, 17000);

    final private SinLFO rate2 = new SinLFO(180000, 360000, 17000);
    final private SinLFO off2 = new SinLFO(-4*TWO_PI, 4*TWO_PI, rate2);
    final private SinLFO wth2 = new SinLFO(25, 110, 21000);

    final private SinLFO rate3 = new SinLFO(160000, 300000, 15000);
    final private SinLFO off3 = new SinLFO(-4*TWO_PI, 4*TWO_PI, rate3);
    final private SinLFO wth3 = new SinLFO(70, 140, 24000);

    final private float hOffset;

    Wave(LX lx, int i) {
      super(lx);
      hOffset = i*120;
      addModulator(rate1.randomBasis()).start();
      addModulator(rate2.randomBasis()).start();
      addModulator(rate3.randomBasis()).start();
      addModulator(off1.randomBasis()).start();
      addModulator(off2.randomBasis()).start();
      addModulator(off3.randomBasis()).start();
      addModulator(wth1.randomBasis()).start();
      addModulator(wth2.randomBasis()).start();
      addModulator(wth3.randomBasis()).start();
    }

    public void run(double deltaMs) {
      for (LXPoint p : model.points) {
        float vy1 = model.yRange/3 * sin(off1.getValuef() + (p.x - model.cx) / wth1.getValuef());
        float vy2 = model.yRange/3 * sin(off2.getValuef() + (p.x - model.cx) / wth2.getValuef());
        float vy = model.ay + vy1 + vy2;
        float thickness = 2*FEET + 1*FEET * sin(off3.getValuef() + (p.x - model.cx) / wth3.getValuef());
        addColor(p.index, LXColor.hsb(
          (lx.getBaseHuef() + hOffset + dist(p.x, p.y, model.ax, model.ay) /model.xRange * 180) % 360, 
          100, 
          max(0, 100 - (100/thickness)*abs(p.y - vy))
          ));
      }
    }
  }

  FunkyWave(LX lx) {
    super(lx);
    for (int i = 0; i < 2; ++i) {
      addLayer(new Wave(lx, i));
    }
  }

  public void run(double deltaMs) {
    setColors(#000000);
  }
}


/*************************

Starry Night

Soothing pulsating lights
that mimic a starfield

**************************/
class StarryNight extends LXPattern {

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
        addColor(index, LXColor.hsb(lx.getBaseHuef(), 50, brightness.getValuef()));
      }
    }
  }

  StarryNight(LX lx) {
    super(lx);
    for (int i = 0; i < 200; ++i) {
      addLayer(new StarLayer(lx));
    }
  }

  public void run(double deltaMs) {
    setColors(#000000);
  }
}


/*************************

Quilt

"Rainbow laser beams"
according to Carrie.
Pew pew pew!

**************************/
class Quilt extends LXPattern {

  final SinLFO[] positions = new SinLFO[80];
  final SinLFO[] widths = new SinLFO[30];

  Quilt(LX lx) {
    super(lx);
    for (int i = 0; i < positions.length; ++i) {
      SinLFO rate = new SinLFO(10000, 20000, 19000);
      addModulator(rate.randomBasis()).start();
      addModulator(positions[i] = new SinLFO(0, 5, rate));
      positions[i].randomBasis().start();
    }
    for (int i = 0; i < widths.length; ++i) {
      SinLFO rate = new SinLFO(10000, 20000, 19000);
      addModulator(rate.randomBasis()).start();
      addModulator(widths[i] = new SinLFO(2*FEET, 5*FEET, rate));
      widths[i].randomBasis().start();
    }
  }

  public void run(double deltaMs) {
    for (LXPoint p : model.points) {
      float w1 = widths[(int) (p.y % widths.length)].getValuef();
      float w2 = widths[(int) (p.x % widths.length)].getValuef();
      colors[p.index] = LXColor.hsb(
        (lx.getBaseHuef() + abs(p.y - model.cy) / model.yRange * 180 + abs(p.x - model.cx) / model.xRange * 180) % 360, 
        100, 
        max(0, 100 - 100 / w1 * model.xRange * abs(p.x/model.xRange - positions[(int) (p.y % positions.length)].getValuef()))
        );
      addColor(p.index, LXColor.hsb(
        (lx.getBaseHuef() + abs(p.y - model.cy) / model.yRange * 180 + abs(p.x - model.cx) / model.xRange * 180) % 360, 
        100, 
        max(0, 100 - 100 / w2 * model.yRange * abs(p.y/model.yRange - positions[(int) (p.x % positions.length)].getValuef()))
        ));
    }
  }
}


/*************************

Scatters

A group of spheres all try
to avoid each other

**************************/
class Scatters extends LXPattern {

  class Scatter extends LXLayer {

    private final Click click = new Click(random(2800, 4200));
    private final QuadraticEnvelope px = new QuadraticEnvelope(0, 0, 0).setEase(QuadraticEnvelope.Ease.BOTH);
    private final QuadraticEnvelope py = new QuadraticEnvelope(0, 0, 0).setEase(QuadraticEnvelope.Ease.BOTH);
    ;  
    private final SinLFO size = new SinLFO(1*FEET, 2.5*FEET, random(3000, 9000));
    private final SinLFO sat = new SinLFO(45, 140, random(6000, 17000));

    Scatter(LX lx) {
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
        float b = 100 - (100/size.getValuef()) * dist(p.x, p.y, px.getValuef(), py.getValuef());
        if (b > 0) {
          addColor(p.index, LXColor.hsb(
            (lx.getBaseHuef() + abs(p.x - model.cx) / model.xRange * 180 + abs(p.y - model.cy) / model.yRange * 180) % 360, 
            min(100, sat.getValuef()), 
            b)
            );
        }
      }
    }

    private void init() {
      px.setRangeFromHereTo(random(model.xMin, model.xMax)).setPeriod(random(900, 1500)).start();
      py.setRangeFromHereTo(random(model.xMin, model.xMax)).setPeriod(random(900, 1500)).start();
    }
  }

  Scatters(LX lx) {
    super(lx);
    for (int i = 0; i < 5; ++i) {
      addLayer(new Scatter(lx));
    }
  }

  public void run(double deltaMs) {
    setColors(#000000);
  }
}


/*************************

Pinwheel

Please tell me you know
what a pinwheel looks like

**************************/
class Pinwheel extends LXPattern {

  private final SinLFO rate = new SinLFO(12000, 18000, 22000);
  private final SawLFO theta = new SawLFO(TWO_PI, 0, rate);
  private final SinLFO xc = new SinLFO(model.xRange*.1, model.xRange * .75, 19000);
  private final SinLFO yc = new SinLFO(model.yRange*.1, model.cy, 29000);
  private final SawLFO dOff = new SawLFO(0, TWO_PI, 11000);
  private final SinLFO wth = new SinLFO(2.2, 4.8, 17000);
  private final SinLFO bend = new SinLFO(-2, 2, 28000);

  private final boolean forward;

  Pinwheel(LX lx, boolean forward) {
    super(lx);
    this.forward = forward;
    addModulator(xc).start();
    addModulator(yc).start();
    addModulator(rate).start();
    addModulator(theta).start();
    addModulator(dOff).start();
    addModulator(wth).start();
    addModulator(bend).start();
  }

  public void run(double deltaMs) {
    for (LXPoint p : model.points) {
      float th = atan2(p.y - yc.getValuef(), p.x - xc.getValuef());
      float d = dist(p.x, p.y, xc.getValuef(), yc.getValuef());
      th += bend.getValuef() * d/250.;
      colors[p.index] = LXColor.hsb(
        (lx.getBaseHuef() + abs(p.x - model.cx) / model.xRange * 180 + abs(p.y - model.cy) / model.yRange * 180) % 360, 
        min(100, 110 + 50*sin(-dOff.getValuef() + d/20)), 
        max(0, 100 - wth.getValuef()*d*LXUtils.wrapdistf(th % HALF_PI, (forward ? theta.getValuef() : (TWO_PI - theta.getValuef())) % HALF_PI, HALF_PI))
        );
    }
  }
}



/*************************

Round Droplets
Diamond Droplets
Star Droplets

Expanding circles,
diamonds, and stars that
look like ripples on the
surface of a pond

**************************/
abstract class Droplets extends LXPattern {

  class Droplet extends LXLayer {

    private final Accelerator xPos = new Accelerator(0, 0, 0);
    private final Accelerator yPos = new Accelerator(0, 0, 0);
    private final Accelerator radius = new Accelerator(0, 0, 15);

    Droplet(LX lx) {
      super(lx);
      addModulator(xPos).start();
      addModulator(yPos).start();
      addModulator(radius).start();
      init();
      radius.setValue(random(0, model.xRange));
    }

    public void run(double deltaMs) {
      boolean touched = false;
      float falloff = falloff();
      for (LXPoint p : model.points) {
        float d = distance(p, xPos.getValuef(), yPos.getValuef(), radius.getValuef());
        float b = 100 - falloff*d;
        if (b > 0) {
          touched = true;
          addColor(p.index, LXColor.hsb(
            (lx.getBaseHuef() + radius.getValuef() / model.xRange * 80 + abs(p.x - model.cx) + abs(p.y - model.cy)) % 360, 
            100, 
            b));
        }
      }
      if (!touched) {
        init();
      }
    }

    private void init() {
      xPos.setValue(random(model.xMin, model.xMax));
      xPos.setVelocity(random(-2*FEET, 2*FEET));
      yPos.setValue(random(model.yMin, model.yMax));
      yPos.setVelocity(random(-2*FEET, 2*FEET));
      radius.setAcceleration(random(5, 15)).setVelocity(0).setValue(0);
    }
  }

  Droplets(LX lx) {
    super(lx);
    for (int i = 0; i < 4; ++i) {
      addLayer(new Droplet(lx));
    }
  }

  public void run(double deltaMs) {
    setColors(#000000);
  }

  abstract protected float distance(LXPoint p, float x, float y, float r);

  protected float falloff() {
    return 7;
  }
}


class RoundDroplets extends Droplets {
  RoundDroplets(LX lx) {
    super(lx);
  }

  protected float distance(LXPoint p, float x, float y, float r) {
    return abs(r - dist(p.x, p.y, x, y));
  }
}


class DiamondDroplets extends Droplets {
  DiamondDroplets(LX lx) {
    super(lx);
  }

  protected float distance(LXPoint p, float x, float y, float r) {
    return abs(r - (abs(p.x - x) + abs(p.y - y)) / 2);
  }

  protected float falloff() {
    return 18;
  }
}

class StarDroplets extends Droplets {
  StarDroplets(LX lx) {
    super(lx);
  }

  protected float distance(LXPoint p, float x, float y, float r) {
    float dx = abs(p.x - x);
    float dy = abs(p.y - y);
    return abs(r - (max(dx, dy) + 2*min(dx, dy)));
  }

  protected float falloff() {
    return 5;
  }
}


/*************************

Rain

A multi-colored, soothing
rain pattern

**************************/
class Rain extends LXPattern {

  private Accelerator[] drops = new Accelerator[38];
  private SinLFO[] sizes = new SinLFO[drops.length]; 

  final static float GRAVITY = -60 * .6;

  Rain(LX lx) {
    super(lx);
    for (int i = 0; i < drops.length; ++i) {
      drops[i] = new Accelerator(random(-15*FEET, model.yMax + 8*FEET), random(GRAVITY, 0), GRAVITY);
      addModulator(drops[i]).start();
      sizes[i] = new SinLFO(1*FEET, 3*FEET, random(3000, 17000));
      addModulator(sizes[i].randomBasis()).start();
    }
  }

  public void run(double deltaMs) {
    for (Accelerator a : drops) {
      if (a.getValuef() < -5*FEET) {
        a.setVelocity(random(GRAVITY/4, 0)).setValue(model.yMax + random(5, 11)*FEET);
      }
    }
    for (LXPoint p : model.points) {
      float dy1 = drops[(int) (p.x % drops.length)].getValuef();
      float dy2 = drops[(int) ((p.x*5 + 437) % drops.length)].getValuef();
      float sz = sizes[(int) (p.x % sizes.length)].getValuef();
      colors[p.index] = LXColor.hsb(
        (lx.getBaseHuef() + dist(p.x, p.y, model.ax, model.ay) / model.xRange *  180) % 360, 
        100, 
        max(0, 100 - 100 / sz * min(abs(p.y - dy1), abs(p.y - dy2)))
        );
    }
  }
}


/*************************

Runners

Ribbons of light meander
left & right while slowly
shifting color

**************************/
class Runners extends LXPattern {

  final SinLFO position[] = new SinLFO[13];
  final SinLFO size[] = new SinLFO[13];
  final SinLFO colorAngle = new SinLFO(-1, 1, 8000);

  final BoundedParameter width = new BoundedParameter("WIDTH", 0.05); 
  final BoundedParameter speed = new BoundedParameter("SPEED", 13000, 18000, 1000);

  final FunctionalParameter lowSpeed = new FunctionalParameter() {
    double getValue() {
      return speed.getValue() * .5;
    }
  };

  Runners(LX lx) {
    super(lx);
    for (int i = 0; i < position.length; ++i) {
      SinLFO rate = new SinLFO(lowSpeed, speed, 5000 + (2355 + 8523*i) % 5000);
      addModulator(rate).start();
      SinLFO start = new SinLFO(0, model.xMax * .25, 3000 + (5000 + i*854) % 8000);
      addModulator(start).start();
      SinLFO end = new SinLFO(model.xMax, model.xMax * .75, 3000 + (5000 + i*342) % 8000);
      addModulator(end).start();

      addModulator((position[i] = new SinLFO(start, end, rate)).randomBasis()).start();
      addModulator((size[i] = new SinLFO(1*FEET, 2.2*FEET, 8000)).randomBasis()).start();
    }
    addModulator(colorAngle).start();
    addParameter(speed);
    addParameter(width);
  }

  public void run(double deltaMs) {
    for (LXPoint p : model.points) {
      float x = position[(int) (p.y % position.length)].getValuef();
      float f = 100 / (20*(width.getValuef() * width.getValuef()) + size[(int) (p.y % position.length)].getValuef());

      colors[p.index] = LXColor.hsb(
        (lx.getBaseHuef() + dist(p.x, p.y/2, model.ax, model.ay/3) / model.xRange *  90) % 360, 
        100, 
        max(0, 100 - f*abs(p.x - x))
        );
    }
  }
}


/*************************

Warp

Pulsating columns, waves,
and chevrons move around
the wall

**************************/
class Warp extends LXPattern {

  private final SinLFO hr = new SinLFO(45, 120, 34000);

  private final SinLFO sr = new SinLFO(9000, 37000, 41000);
  private final SinLFO slope = new SinLFO(0.5, 1.8, sr); 

  private final SinLFO speed = new SinLFO(2500, 4200, 27000);
  private final SawLFO move = new SawLFO(TWO_PI, 0, speed);
  private final SinLFO tight = new SinLFO(9, 12, 12000);

  private final SinLFO cs = new SinLFO(20000, 31000, 11000);
  private final SinLFO csy = new SinLFO(40000, 60000, 25000);
  private final SinLFO cx = new SinLFO(model.cx - 8*FEET, model.cx + 8*FEET, cs);
  private final SinLFO cy = new SinLFO(model.cy - 16*FEET, model.cy + 16*FEET, csy);

  Warp(LX lx) {
    super(lx);
    addModulator(hr).start();
    addModulator(sr).start();
    addModulator(slope).start();
    addModulator(speed).start();
    addModulator(move).start();
    addModulator(tight).start();
    addModulator(cs).start();
    addModulator(csy).start();
    addModulator(cx).start();
    addModulator(cy).start();
  }

  public void run(double deltaMs) {
    for (LXPoint p : model.points) {
      //float dx = (abs(p.x - cx.getValuef()) - slope.getValuef() * abs(p.y - (model.cy/2))) / model.xRange;
      float dx = (abs(p.x - cx.getValuef()) - slope.getValuef() * abs(p.y - cy.getValuef())) / model.yRange;
      float b = 50 + 50*sin(dx * tight.getValuef() + move.getValuef());

      colors[p.index] = LXColor.hsb(
        (lx.getBaseHuef() + + abs(p.y - model.cy) / model.yRange * hr.getValuef() + abs(p.x - cx.getValuef()) / model.xRange * hr.getValuef()) % 360, 
        100, 
        b
        );
    }
  }
}



/*************************

Swings

Three static columns swing
at random intervals

**************************/
class Swings extends LXPattern {

  private final int NUM_SWINGS = 3;

  class Swing extends LXLayer {

    private final SinLFO pos = new SinLFO(-1.5, 1.5, 3000);
    private final QuadraticEnvelope mag = new QuadraticEnvelope(1, 0, 6000).setEase(QuadraticEnvelope.Ease.OUT);
    private final Click click = new Click(random(7000, 8000));
    private float xp;

    Swing(LX lx, int i) {
      super(lx);
      xp = model.xMin + (model.xRange / (NUM_SWINGS)) * (i+.5);
      addModulator(click).start();
      addModulator(pos).start();
      addModulator(mag).start();
      init();
    }

    private void init() {
      pos.setValue(0);
      mag.setPeriod(random(5000, 7000)).trigger();
      click.setPeriod(mag.getPeriod() + random(400, 2000));
    }

    public void run(double deltaMs) {
      if (click.click()) {
        init();
      }
      for (LXPoint p : model.points) {
        float dy = (model.yMax - p.y) / model.yRange;
        float dx = (dy + dy*dy) / 2 * model.yRange * pos.getValuef() * mag.getValuef();
        float sx = xp + dx;
        float thick = 1*FEET + dy * abs(pos.getValuef() * mag.getValuef()) * 1.2*FEET;
        float b = 100 - 100 / thick * abs(p.x - sx);
        if (b > 0) {
          addColor(p.index, LXColor.hsb(
            (lx.getBaseHuef() + abs(p.x - model.cx) / model.xRange * 360 + 1080 - abs(model.yMax - p.y) / model.yRange * 90) % 360, 
            min(100, 20 + 200*abs(mag.getBasisf() - (model.yMax - p.y) / model.yRange)), 
            b)
            );
        }
      }
    }
  }

  Swings(LX lx) {
    super(lx);
    for (int i = 0; i < NUM_SWINGS; ++i) {
      addLayer(new Swing(lx, i));
    }
  }

  public void run(double deltMs) {
    setColors(#000000);
  }
}


/*************************

Balls

BOUNCY BALLS!!

**************************/

class Balls extends LXPattern {

  class Ball extends LXLayer {

    final static float GRAVITY = -100;
    final float VMAX = sqrt(-2 * model.yMax * GRAVITY);

    private final Accelerator yp = new Accelerator(0, 0, GRAVITY);
    private final Accelerator xp = new Accelerator(0, 0, 0);

    Ball(LX lx) {
      super(lx);
      addModulator(yp.setValue(random(0, model.yMax))).start();
      addModulator(xp.setVelocity(random(-5*FEET, 5*FEET)).setValue(random(0, model.xMax))).start();
    }

    public void run(double deltaMs) {
      if (yp.getValue() < 0) {
        yp.setValue(abs(yp.getValuef()));
        float velf = abs(yp.getVelocityf()) * random(.6, .9);        
        if (velf < 10) {
          velf = random(.8, 1.15) * VMAX;
        } 
        yp.setVelocity(velf);
        xp.setVelocity(constrain(xp.getVelocityf() + random(-3*FEET, 3*FEET), -8*FEET, 8*FEET));
      }
      if (xp.getValue() < model.xMin) {
        xp.setValue(2 * model.xMin - xp.getValue());
        xp.setVelocity(-xp.getVelocity());
      } else if (xp.getValue() > model.xMax) {
        xp.setValue(2*model.xMax - xp.getValue());
        xp.setVelocity(-xp.getVelocity());
      }
      float size = max(1*FEET, 3*FEET - 2.5*FEET * yp.getValuef() / model.yMax);
      for (LXPoint p : model.points) {
        float b = 100 - (100 / size)*dist(p.x, p.y, xp.getValuef(), yp.getValuef());
        if (b > 0) {
          addColor(p.index, LXColor.hsb(
            (lx.getBaseHuef() + abs(p.x - model.cx)/ model.xRange * 30 + p.y / model.yMax * 180) % 360, 
            100, 
            b
            ));
        }
      }
    }
  }

  Balls(LX lx) {
    super(lx);
    for (int i = 0; i < 4; ++i) {
      addLayer(new Ball(lx));
    }
  }

  public void run(double deltaMs) {
    setColors(#000000);
  }
}


/*************************

Joiners

A group of spheres disperse
and regroup while creating
different hues

**************************/

class Joiners extends LXPattern {

  private final SinLFO rate = new SinLFO(1200, 1900, 23000);
  private final Click click = new Click(rate);
  private boolean even = true;
  private float dx;
  private float dy;

  class Joiner extends LXLayer {

    private final SinLFO size = new SinLFO(1*FEET, 3*FEET, random(5000, 11000));
    private final QuadraticEnvelope px = new QuadraticEnvelope(0, 0, 0).setEase(QuadraticEnvelope.Ease.OUT);
    private final QuadraticEnvelope py = new QuadraticEnvelope(0, 0, 0).setEase(QuadraticEnvelope.Ease.OUT);
    final private float hOffset;

    Joiner(LX lx, int i) {
      super(lx);
      hOffset = i*180;
      addModulator(px).start();
      addModulator(py).start();
      addModulator(size.randomBasis()).start();
    }

    public void run(double deltaMs) {
      if (click.click()) {
        init();
      }
      for (LXPoint p : model.points) {
        float b = 100 - 100/size.getValuef() * dist(p.x, p.y, px.getValuef(), py.getValuef());
        if (b > 0) {
          addColor(p.index, LXColor.hsb(
            (lx.getBaseHuef() + hOffset + dist(p.x, p.y, model.ax, model.ay) / model.xRange * 360) % 360, 
            100, 
            b)
            );
        }
      }
    }

    private void init() {
      px.setRangeFromHereTo(even ? dx : random(model.xMin, model.xMax)).setPeriod(click.getPeriod() * random(.5, 2)).start();
      py.setRangeFromHereTo(even ? dy : random(model.yMin, model.yMax)).setPeriod(click.getPeriod() * random(.5, 2)).start();
    }
  }

  Joiners(LX lx) {
    super(lx);
    addModulator(rate).start();
    addModulator(click).start();
    dx = random(model.xMin, model.xMax);
    dy = random(model.yMin, model.yMax);
    for (int i = 0; i < 5; ++i) {
      addLayer(new Joiner(lx, i));
    }
  }

  public void run(double deltaMs) {
    setColors(#000000);
    if (click.click()) {
      even = !even;
      dx = random(model.xMin, model.xMax);
      dy = random(model.yMin, model.yMax);
    }
  }
}


/*************************

Color Waves

Pulsating waves of colors
move from bottom to top

**************************/
class ColorWaves extends LXPattern {
 
  class ColorWave extends LXLayer {

  private final SinLFO hr = new SinLFO(45, 120, 34000);

  private final SinLFO speed = new SinLFO(3800, 5500, 27000);
  private final SawLFO move = new SawLFO(TWO_PI, 0, speed);
  private final SinLFO tight = new SinLFO(5, 9, 12000);
  
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

      addColor(p.index, LXColor.hsb(
        (lx.getBaseHuef() + hOffset + abs(p.y - model.cy) / model.yRange * hr.getValuef() + abs(p.x - model.xMin) / model.xRange * hr.getValuef()) % 360, 
        100, 
        b
        ));
    }
  }
}


ColorWaves(LX lx) {
  super(lx);
    addLayer(new ColorWave(lx, 0.8 , 8, 0, 9));
    addLayer(new ColorWave(lx, 1.5, -8, 120, 22));
}
 
  public void run(double deltaMs) {
    setColors(#000000);
  }
  
}

/**************************

Depths of Space

Streams of light zip across
a star field!

***************************/
class DepthsOfSpace extends LXPattern {
  
  class WarpField extends LXLayer {

      private Accelerator[] drops = new Accelerator[78];
      private SinLFO[] sizes = new SinLFO[drops.length]; 
    
      final static float VELOCITY = -300;
    
      WarpField(LX lx) {
        super(lx);
        for (int i = 0; i < drops.length; ++i) {
          drops[i] = new Accelerator(random(-15*FEET, model.xMax + 8*FEET), random(VELOCITY, 0), -2);
          addModulator(drops[i]).start();
          sizes[i] = new SinLFO(1*FEET, 2*FEET, random(3000, 17000));
          addModulator(sizes[i].randomBasis()).start();
        }
      }
    
      public void run(double deltaMs) {
        for (Accelerator a : drops) {
          if (a.getValuef() < -5*FEET) {
            a.setVelocity(random(VELOCITY/2, 0)).setValue(model.xMax + random(5, 11)*FEET);
          }
        }
        for (LXPoint p : model.points) {
          float dy1 = drops[(int) (p.y % drops.length)].getValuef();
          float dy2 = drops[(int) ((p.y*5 + 437) % drops.length)].getValuef();
          float sz = sizes[(int) (p.y % sizes.length)].getValuef();
          addColor(p.index, LXColor.hsb(
            (lx.getBaseHuef() + dist(p.x, p.y, model.ax, model.yMax) / model.xRange *  90) % 360, 
            100, 
            max(0, 55 - 55 / sz * min(abs(p.x - dy1), abs(p.x - dy2)))
            ));
        }
      }
      
    }
    
    class StarLayer extends LXLayer {

    private final TriangleLFO maxBright = new TriangleLFO(0, 45, random(2000, 8000));
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
        addColor(index, LXColor.hsb(0, 0, brightness.getValuef()));
      }
    }
  }
  
  DepthsOfSpace(LX lx){
    super(lx);
    addLayer(new WarpField(lx));
        for (int i = 0; i < 100; ++i) {
      addLayer(new StarLayer(lx));
    }
  }
  
  public void run(double deltaMs) {
    setColors(#000000);
 }
  
}


/*************************

Swarm

Little flecks of color
orbit the center of the
wall

**************************/
class Swarm extends LXPattern {
  
  class SwarmLayer extends LXLayer {
    
    final SawLFO theta = new SawLFO(0, TWO_PI, random(3000, 9000));
    final SinLFO radius = new SinLFO(0, model.yRange/2, random(5000, 11000));
    final SinLFO size = new SinLFO(4, 6, random(13000, 19000));
    
    SwarmLayer(LX lx) {
      super(lx);
      addModulator(theta.randomBasis()).start();
      addModulator(radius.randomBasis()).start();
      addModulator(size.randomBasis()).start();
    }
    
    public void run(double deltaMs) {
      float x = radius.getValuef() * cos(theta.getValuef());
      float y = radius.getValuef() * sin(theta.getValuef());
      for (LXPoint p : model.points) {
        float b = 50 - 50/size.getValuef() * dist(x+model.cx, y+model.cy, p.x, p.y);
        if (b > 0) {
         addColor(p.index, LXColor.hsb(
          (lx.getBaseHuef() + abs(p.y - model.cy) / model.yRange * 180 + abs(p.x - model.cx) / model.xRange * 180) % 360,
            100,
            b));
        } 
      }
   
    }
    
  }
  
  Swarm(LX lx) {
    super(lx);
    for (int i = 0; i < 24; ++i) {
      addLayer(new SwarmLayer(lx));
    }
  }
  
  public void run(double deltaMs) {
    LXColor.scaleBrightness(colors, max(0, (float) (1 - deltaMs / 600.f)), null);
  }
}


/*************************

Amino Logo

A sharp corporate logo
set against sparkly stars

**************************/
class AminoLogo extends LXPattern{
  
  final SinLFO logoBrightness = new SinLFO(0.4, 1, 10000);
  
  class Amino extends LXLayer {
 
  PImage img;
  int xPos = (int) model.xRange;
  int yPos = (int) model.yRange;
  
  
  Amino(LX lx){
    super(lx);
    img = loadImage("img/amino.png");
    addModulator(logoBrightness).start();
  }
  
  public void run(double deltaMs){
    int yMax = 20;
    int xMax = 20;
    for(int y = 0; y < yMax; y++){
      for(int x = 0; x < xMax; x++){
         addColor(y + (yMax*x), img.get(x, (yMax-1)-y));
       } 
     }
    LXColor.scaleBrightness(colors, logoBrightness.getValuef() , null);
   }
  }
  
  class StarLayer extends LXLayer {

    private final TriangleLFO maxBright = new TriangleLFO(0, 45, random(2000, 8000));
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
        addColor(index, LXColor.hsb(0, 0, brightness.getValuef()));
      }
    }
  }
  
  AminoLogo(LX lx){
    super(lx);
    for (int i = 0; i < 150; ++i) {
      addLayer(new StarLayer(lx));
    }
    addLayer(new Amino(lx));
    
  }
  
  public void run(double deltaMs){
   setColors(#000000); 
   
  } 
}


/********************************

Graph

Blobs of light appear, grow,
shoot a message to a neighboring
blob, shrink, and disappear.

*********************************/
class Graph extends LXPattern {

  final Node[] nodes = new Node[6];
  
  public Graph(LX lx) {
    super(lx);
    for (int i = 0; i < nodes.length; ++i) {
      nodes[i] = new Node(i);
    }
  }

  class Node {
    
    float x, y, r, xVel, yVel;
    QuadraticEnvelope sz;
    QuadraticEnvelope cLength;
    int semaphore = 0;
    
    int state;
    
    final int modelSize = 20;
    final int GROWING = 1;
    final int CONNECTING = 2;
    final int SENDING = 3;
    final int DISCONNECTING = 4;
    final int SHRINKING = 5;
    
    final int index;
    Node target;
    
    Node(int idx) {
      index = idx;
      addModulator(sz = new QuadraticEnvelope(0, 1, 0));
      addModulator(cLength = new QuadraticEnvelope(0, 1, 5000).setEase(QuadraticEnvelope.Ease.BOTH));
      grow();
    }
    
    boolean available() {
      return
        (state == CONNECTING) ||
        (state == SENDING);      
    }
    
    void grow() {
      state = GROWING;
      xVel = random(-3, 3);
      yVel = random(-3, 3);
      x = random(0, modelSize);
      y = random(0, modelSize);
      r = random(2, 4);
      sz.setRange(0, 1, random(1000, 2000)).trigger();
    }
    
    void connect() {
      state = CONNECTING;
      target = null;
    }
    
    void send() {
      state = SENDING;
      cLength.setRange(0, 1, dist(x, y, target.x, target.y) * random(60, 150)).trigger();
    }
        
    void disconnect() {
      state = DISCONNECTING;
      --target.semaphore;
      target = null;
    }
    
    void shrink() {
      state = SHRINKING;
      sz.setRange(1, 0, random(1000, 2000)).trigger();
    }
    
    
    void drawNode() {
      for (int xv = floor(x - r); xv < ceil(x + r); ++xv) {
        for (int yv = floor(y - r); yv < ceil(y + r); ++yv) {
          if (xv >= 0 && xv < modelSize && yv >= 0 && yv < modelSize) {
            float d = dist(x, y, xv, yv);
            addColor(yv + (modelSize*xv), modelSize-yv, color(
              (lx.getBaseHuef() + x*.5 + y + d*15) % 360,
              100,
              constrain(sz.getValuef() * 200 - d*(200 / r), 0, 75)
            ));
          }
        }
      }

    }

    void drawConnection() {
      float xp = lerp(x, target.x, cLength.getValuef());
      float yp = lerp(y, target.y, cLength.getValuef());
      for (int xv = floor(xp - 3); xv < ceil(xp + 3); ++xv) {
        for (int yv = floor(yp - 3); yv < ceil(yp + 3); ++yv) {
          if (xv >= 0 && xv < modelSize && yv >= 0 && yv < modelSize) {
            float maxB = constrain(1000 - abs(cLength.getValuef() - 0.5) * 2000, 0, 100);
            addColor(yv + (modelSize*xv), (modelSize-1)-yv, color(
              0,
              0,
              constrain(maxB - dist(xv, yv, xp, yp) * (50 + 50 * abs(cLength.getValuef() - 0.5)), 0, 75)
            ));
          }
        }
      }   
    }      
    
    public void run(double deltaMs) {
      x += xVel * deltaMs / 1000.;
      y += yVel * deltaMs / 1000.;
      drawNode();
      if (state == SENDING) {
        drawConnection();
      }
    }
        
    public void transition() {
      switch (state) {
      case GROWING:
        if (!sz.isRunning()) {
          connect();
        }
        break;
      case CONNECTING:
        Node candidate = nodes[(index + int(random(1, nodes.length))) % nodes.length];
        if (candidate.available()) {
          target = candidate;
          ++target.semaphore;
          send();
        }
        break;
      case SENDING:
        if (!cLength.isRunning()) {
          disconnect();
        }
        break;
      case DISCONNECTING:
        if (semaphore == 0) {
          shrink();
        }
        break;
      case SHRINKING:
        if (!sz.isRunning()) {
          grow();
        }
        break;
      }
    }
  }
  
  public void run(double deltaMs) {
    setColors(0);
    for (Node n : nodes) {
      n.run(deltaMs);
    }
    for (Node n : nodes) {
      n.transition();
    }
  }
}


/****************

Bubbles

blub, blub, blub

*****************/
class Bubbles extends LXPattern {
 
  class Bubble extends LXLayer {
    
    private final Accelerator xPos = new Accelerator(0, 0, 0);
    private final Accelerator yPos = new Accelerator(0, 0, 12);
    private final float radius;
    private final int hOffset;

    Bubble(LX lx, int o) {
      super(lx);
      addModulator(xPos).start();
      addModulator(yPos).start();
      init();
      radius = random(0.8*FEET,2.4*FEET);
      hOffset = o;
    }

    public void run(double deltaMs) {
      boolean touched = false;
      float falloff = 14;
      for (LXPoint p : model.points) {
        float d = abs(radius - dist(p.x, p.y, xPos.getValuef(), yPos.getValuef()));
        float b = 100 - falloff*d;
        if (b > 0) {
          touched = true;
          addColor(p.index, LXColor.hsb(
            (lx.getBaseHuef() + hOffset + radius / model.xRange * 80 + abs(p.x - model.cx) + abs(p.y - model.cy)) % 360, 
            100, 
            b));
        }
      }
      if (!touched) {
        init();
      }
    }

    private void init() {
      xPos.setValue(random(model.xMin-(3*FEET), model.xMax-(1*FEET)));
      yPos.setValue(random(model.yMin-(2.4*FEET), model.yMin-(3.3*FEET)));
      
      xPos.setVelocity(random(1*FEET, 1.5*FEET));
      yPos.setVelocity(random(2*FEET, 4*FEET));
    }
  }
  
    protected float distance(LXPoint p, float x, float y, float r) {
    return abs(r - dist(p.x, p.y, x, y));
  }

  Bubbles(LX lx) {
    super(lx);
    for (int i = 0; i < 6; ++i) {
      addLayer(new Bubble(lx, i*16));
    }
  }

  public void run(double deltaMs) {
    setColors(#000000);
    LXColor.scaleBrightness(colors, 0.80);
  }
    
  
}