int hCount;
int vCount;
float pathLeft;
float pathTop;
Spot[][] centers;
Tracer[] tracers;
boolean debug = false;
PGraphics background;
Palette[] pals = new Palette[]{
  new Palette(16, #FF0000, #FFFFFF), // Red to white.
  new Palette(16, #00FF00, #FFFFFF), // Green to white.
  new Palette(16, #FF00FF, #FFFFFF), // Magenta to white.
  new Palette(16, #00FFFF, #FFFFFF), // Cyan to white.
  new Palette(16, #FFFF00, #FFFFFF), // Yellow to white.
  new Palette(16, #AA00FF, #FFFFFF), // Purple to white.
  new Palette(16, #FFAA00, #FFFFFF), // Orange to white.
};
Palette ringPal = new Palette(8, #555555, #000000);
float pathRadius = 165;
float circleOuterRad = 150;
float circleInnerRad = 100;
float speedDiv = 16.0; // must be divisible by 4.
boolean drawPaths = false;

void setup() {
  fullScreen();
  setVals();
  setTracers();
  background = createGraphics(width, height);
  background.beginDraw();
  background.background(#000000);
  drawRings(background);
  background.endDraw();
}

void draw() {
  image(background, 0, 0);
  noFill();
  for (Tracer tracer : tracers) { 
    tracer.Move();
    tracer.Draw();
  }
}

void drawRings(PGraphics layer) {
  int ringPalSize = ringPal.Size();
  float mult = (circleOuterRad - circleInnerRad) / ringPalSize;
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
  tracers = new Tracer[pals.length];
  for (int i = 0; i < pals.length; i++) {
    float speed = PI/speedDiv;
    if (int(random(2)) == 0) {
      speed *= -1;
    }
    tracers[i] = new Tracer(int(random(hCount)), int(random(vCount)))
                     .WithAngle(HALF_PI*(float)int(random(4)))
                     .WithSpeed(speed)
                     .WithStroke(pathRadius-circleOuterRad)
                     .WithColor(pals[i].Get(0).Value)
                     .WithTail(2*TWO_PI, pals[i]);
  }
}
