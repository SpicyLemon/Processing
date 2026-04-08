import gifAnimation.*;

GifMaker gifExport;
int gifFrameLimit = 500;
int gifFrameRate = 1000/30;
boolean saveGif = false;

int hCount;
int vCount;
float pathLeft;
float pathTop;
Spot[][] centers;
Tracer[] tracers;
boolean debug = false;
PGraphics background;

color runnerEnd = #FFFFFF;
Palette[] pals = new Palette[]{
  new Palette(16, #FF0000, runnerEnd), // Red to white.
  new Palette(16, #00FF00, runnerEnd), // Green to white.
  new Palette(16, #FF00FF, runnerEnd), // Magenta to white.
  new Palette(16, #00FFFF, runnerEnd), // Cyan to white.
  new Palette(16, #FFFF00, runnerEnd), // Yellow to white.
  new Palette(16, #AA00FF, runnerEnd), // Purple to white.
  new Palette(16, #FFAA00, runnerEnd), // Orange to white.
};
Palette ringPal = new Palette(8, #444444, #000000);
float pathRadius = 75;
float circleOuterRad = 60;
float circleInnerRad = 25;
float speedDiv = 8.0; // must be divisible by 4.
boolean drawRings = false;
boolean drawPaths = false;
float tailLen = 3.0 * TWO_PI;
int runnersPerPal = 3;

void setup() {
  fullScreen();
  setVals();
  setTracers();
  background = createGraphics(width, height);
  background.beginDraw();
  background.background(#000000);
  drawRings(background);
  background.endDraw();
  
    // Set up the gif exporter.
  if (saveGif) {
    gifExport = new GifMaker(this, "ring-runners.gif");
    gifExport.setRepeat(0); // Loop forever.
    gifExport.setDelay(gifFrameRate);
  }
}

void draw() {
  if (drawRings) {
    image(background, 0, 0);
  } else {
    background(#000000);
  }
  noFill();
  for (Tracer tracer : tracers) { 
    tracer.Move();
    tracer.Draw();
  }
  
  if (saveGif) {
    // Add this frame to the gif.
    if (frameCount <= gifFrameLimit) {
      gifExport.addFrame();
    }
    
    // Finish and save.
    if (frameCount == gifFrameLimit) {
      gifExport.finish();
      println("GIF saved!");
      exit();
    }
  }
}

void drawRings(PGraphics layer) {
  int ringPalSize = ringPal.Size();
  float mult = (circleOuterRad - circleInnerRad) / ringPalSize;
  
  // Draw the parts that end up going between the circles.
  layer.noStroke();
  for (int i = ringPalSize-1; i >= 0; i--) {
    // at i = 0, radius = 2 * pathRadius - circleInnerRad
    // at i = max, radius = 2 * pathRadius - circleOuterRad
    // m = (2 * pathRadius - circleInnerRad - ( 2 * pathRadius - circleOuterRad) / ringPalSize
    // m = (2 * pathRadius - circleInnerRad - 2 * pathRadius + circleOuterRad) / ringPalSize
    // m = (circleInnerRad - circleOuterRad)/ ringPalSize = -m
    float radius = 2.0 * pathRadius - circleOuterRad + (i+1)*mult;
    layer.fill(ringPal.Get(i).Value);
    for (Spot[] row : centers) {
      for (Spot c : row) {
        layer.circle(c.X, c.Y, radius);
      }
    }    
  }
  
  // Draw the inner rings
  layer.noStroke();
  for (int i = 0; i < ringPalSize; i++) {
    // at i = 0, radius = circleOuterRad.
    // at i = max, radius = circleInnerRad.
    // m = (circleOuterRad - circleInnerRad) / ringPalSize
    float radius = circleOuterRad - i*mult;
    layer.fill(ringPal.Get(i).Value);
    for (Spot[] row : centers) {
      for (Spot c : row) {
        layer.circle(c.X, c.Y, radius);
      }
    }
  }
  
  // Draw the path rings.
  layer.noFill();
  float pathWidth = pathRadius - circleOuterRad;
  for (int i = 0; i < ringPalSize; i++) {
    layer.strokeWeight(pathWidth - i * (pathWidth)/(ringPalSize+1));
    layer.stroke(ringPal.Get(i).Value);
    for (Spot[] row : centers) {
      for (Spot c : row) {
        layer.circle(c.X, c.Y, pathRadius);
      }
    }
  }

  // Draw the path lines.
  if (drawPaths) {
    layer.noFill();
    layer.strokeWeight(1.0);
    layer.stroke(#FFFFFF);
    for (Spot[] row : centers) {
      for (Spot c : row) {
        layer.circle(c.X, c.Y, pathRadius);
      }
    }
  }
}

void setVals() {
  hCount = (int)(width/pathRadius);
  vCount = (int)(height/pathRadius);
  pathLeft = (width-pathRadius*(hCount))/2;
  pathTop = (height-pathRadius*(vCount))/2;
  centers = new Spot[vCount][hCount];
  for (int x = 0; x < hCount; x++) {
    for (int y = 0; y < vCount; y++) {
      centers[y][x] = new Spot(pathLeft+pathRadius*x+pathRadius/2, pathTop+pathRadius*y+pathRadius/2);
    }
  }
  if (debug) { 
    println("  hCount:", hCount);
    println("  vCount:", vCount);
    println("pathLeft:", pathLeft);
    println(" pathTop:", pathTop);
  }
}

void setTracers() {
  tracers = new Tracer[pals.length*runnersPerPal];
  for (int m = 0; m < runnersPerPal; m++) {
    for (int i = 0; i < pals.length; i++) {
      float speed = PI/speedDiv;
      if (int(random(2)) == 0) {
        speed *= -1;
      }
      tracers[m*pals.length+i] = new Tracer(int(random(hCount)), int(random(vCount)))
                       .WithAngle(HALF_PI*(float)int(random(4)))
                       .WithSpeed(speed)
                       .WithStroke(pathRadius-circleOuterRad)
                       .WithColor(pals[i].Get(0).Value)
                       .WithTail(tailLen, pals[i]);
    }
  }
}
