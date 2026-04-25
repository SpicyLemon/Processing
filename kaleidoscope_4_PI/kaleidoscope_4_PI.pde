boolean logTimes = false;

// Value initialized in setup().
PGraphics pg;
float xMin, xMax, yMin, yMax;
float xLimMin, xLimMax, yLimMin, yLimMax;
float backOvalWidth, backOvalHeight;
float backOvalOffsetX, backOvalOffsetY;
Palette backPal;
Palette tracerPal;
Tracer[] tracers;
Spot[] runnerSpots;
int runnerI;

// Boring global variables (no need to change what these start as).
float offset = 0.0;
float dOffset = 0.0;
float backPalI = 0.0;
float dBackOvalOffsetX = 0.0;
float dBackOvalOffsetY = 0.0;
float backOvalRot = 0.0;
float dBackOvalRot = 0.0;
boolean mouseWasPressed = false;

// Define the key colors used to rotate through.
color[] backColors = new color[]{
  #FF0000, // Red
  #FFFF00, // Yellow
  #00FF00, // Green
  #00FFFF, // Cyan
  #0000FF, // Blue
  #FF00FF, // Magenta
};
float dBackPalI = 0.1;
int entriesPerBackPal = 25;

// Values governing the background ovals.
int divs = 9;
float dOffsetMax = 0.02;
float ddOffsetMax = 0.0001;
float backOvalBorder = 2.0;
float backOvalOffsetMax = 100;
float dBackOvalOffsetMax = 2.0;
float ddBackOvalOffsetMax = 0.2;
float dBackOvalRotMax = 0.04;
float ddBackOvalRotMax = 0.002;

// Values governing the tracers.
int tailLength = 20;
float maxStroke = 10.0;
float headSize = 0.0;
float maxSpeed = 8.0;
float minSpeed = 4.0;
float minRadius = 15.0;
// This dictates a) how many tracers there are, and b) how far forward (positive) 
// or backwards (negative) in the palette (from the background) that the color is.
int[] tracerShift = new int[]{
  -entriesPerBackPal/3,  entriesPerBackPal/3,
};

// Values governing the runners.
int spotCount = 150;
int runnerLength = 25;
color runnerColor = #FFFFFF;
float runnerSize = 10;

void setup() {
  fullScreen(P2D);
  pg = createGraphics(width/2, height/2);
  
  // Calculate some screen bounds.
  xMax = pg.width/2;
  xMin = -xMax;
  yMax = pg.height/2;
  yMin = -yMax;
  xLimMin = xMin * 0.95;
  xLimMax = xMax * 0.95;
  yLimMin = yMin * 0.95;
  yLimMax = yMax * 0.95;
 
  backOvalWidth = xMax * 0.6;
  backOvalHeight = yMax * 0.35;
  backOvalOffsetX = random(-backOvalOffsetMax, backOvalOffsetMax);
  backOvalOffsetY = random(-backOvalOffsetMax, backOvalOffsetMax);

  // Create the palette that will be used to make the squares rotate through colors.
  color[] colors = new color[backColors.length];
  for (int i = 0; i < backColors.length; i++) {
    colors[i] = lerpColor(backColors[i], #000000, 0.2);
  }
  backPal = NewCircularPalette(entriesPerBackPal, colors);
  backPal = backPal.SetAlpha(100);
  tracerPal = NewCircularPalette(entriesPerBackPal, backColors);
  
  // Create the tracers
  tracers = new Tracer[tracerShift.length];
  for (int i = 0; i < tracerShift.length; i++) {
    tracers[i] = newRandomTracer(tracerColor(tracerShift[i]));
  }
  
  // Calculate all the points that will be used for the runners.
  runnerSpots = new Spot[spotCount];
  for (int i = 0; i < spotCount; i++) {
    float angle = map(i, 0, spotCount, 0, TWO_PI);
    float x = backOvalWidth/2*cos(angle);
    float y = backOvalHeight/2*sin(angle);
    runnerSpots[i] = new Spot(x, y);
  }
}

void draw() {
  int t1 = millis();
  pg.beginDraw();
  pg.background(0);
  pg.translate(xMax, yMax);
  
  // Shift the background to the next color.
  backPalI += dBackPalI;
  if (int(backPalI) >= backPal.Size()) {
    backPalI = 0.0;
  }
  
  // Adjust the overall rotational offset (makes the whole thing spin at random).
  dOffset = adjustSpeed(dOffset, dOffsetMax, ddOffsetMax);
  offset += dOffset;
  if (offset >= TWO_PI) {
    offset -= TWO_PI;
  } else if (offset <= 0) {
    offset += TWO_PI;
  }
  pg.rotate(offset);
  
  // Adjust the angle of the background ovals.
  dBackOvalRot = adjustSpeed(dBackOvalRot, dBackOvalRotMax, ddBackOvalRotMax);
  backOvalRot += dBackOvalRot;
  if (backOvalRot >= TWO_PI) {
    backOvalRot -= TWO_PI;
  } else if (backOvalRot <= 0) {
    backOvalRot += TWO_PI;
  }
  
  // Adjust the placement of the background ovals.
  dBackOvalOffsetX = adjustSpeed(dBackOvalOffsetX, dBackOvalOffsetMax, ddBackOvalOffsetMax);
  backOvalOffsetX += dBackOvalOffsetX;
  if (backOvalOffsetX >= backOvalOffsetMax && dBackOvalOffsetX > 0) {
    dBackOvalOffsetX /= 2;
  } else if (backOvalOffsetX <= -backOvalOffsetMax && dBackOvalOffsetX < 0) {
    dBackOvalOffsetX /= 2;
  }
    
  dBackOvalOffsetY = adjustSpeed(dBackOvalOffsetY, dBackOvalOffsetMax, ddBackOvalOffsetMax);
  backOvalOffsetY += dBackOvalOffsetY;
  if (backOvalOffsetY >= backOvalOffsetMax && dBackOvalOffsetY > 0) {
    dBackOvalOffsetY /= 2;
  } else if (backOvalOffsetY <= -backOvalOffsetMax && dBackOvalOffsetY < 0) {
    dBackOvalOffsetY /= 2;
  }
  
  // Move the runners.
  runnerI += 1;
  if (runnerI >= runnerSpots.length) {
    runnerI = 0;
  }
  
  // Adjust the colors of the tracers
  for (int i = 0; i < tracers.length; i++) {
    tracers[i].WithColor(tracerColor(tracerShift[i]));
  }
  
  // Move the tracers.
  boolean forceDirChange = false;
  if (mouseWasPressed) {
    mouseWasPressed = false;
    forceDirChange = true;
  }
  for (Tracer tracer : tracers) {
    tracer.Move(forceDirChange);
  }
  
  int t2 = millis();
  
  // Draw the background ovals.
  for (int d = 0; d < divs; d++) {
    drawBack();
    pg.rotate(TWO_PI/divs);
  }
  
  // Draw the runners.
  for (int d = 0; d < divs; d++) {
    drawRunner();
    pg.rotate(TWO_PI/divs);
  }
  
  // Draw the background oval borders.
  for (int d = 0; d < divs; d++) {
    drawBackLines();
    pg.rotate(TWO_PI/divs);
  }
  
  // Draw the tracers
  for (int i = 0; i < tailLength-1; i++) {
    for (int d = 0; d < divs; d++) {
      for (Tracer tracer : tracers) {
        tracer.DrawI(i);
      }
      pg.rotate(TWO_PI/divs);
    }
  }
  for (int d = 0; d < divs; d++) {
    for (Tracer tracer : tracers) {
      tracer.DrawDot();
    }
    pg.rotate(TWO_PI/divs);
  }
  
  pg.endDraw();
  
  int t3 = millis();
  image(pg, 0, 0, width, height);
  int t4 = millis();
  
  if (logTimes) {
    println("Move: " + (t2-t1) + "ms, Draw: " + (t3-t2) + "ms, Scale: " + (t4-t3) + "ms, Total: " + (t4-t1) + "ms, FPS: " + frameRate);
  }
}

void mousePressed() {
  mouseWasPressed = true;
}

void drawBack() {
  pg.noStroke();
  pg.fill(backPal.Get(int(backPalI)).Value);
  drawBackOval();
}

void drawBackLines() {
  pg.noFill();
  pg.stroke(backLineColor(0));
  pg.strokeWeight(backOvalBorder);
  drawBackOval();
}

void drawBackOval() {
  pg.translate(backOvalOffsetX, backOvalOffsetX);
  pg.rotate(backOvalRot);
  pg.ellipse(0, 0, backOvalWidth, backOvalHeight);
  pg.rotate(-backOvalRot);
  pg.translate(-backOvalOffsetX, -backOvalOffsetX);
}

void drawRunner() {
  pg.translate(backOvalOffsetX, backOvalOffsetX);
  pg.rotate(backOvalRot);
  for (int i = runnerLength-2; i >= 0; i--) {
    int j = (runnerI + i) % runnerSpots.length;
    int k = (j + 1) % runnerSpots.length;
    pg.strokeWeight(map(i, 0, runnerLength-1, runnerSize, backOvalBorder));
    pg.stroke(lerpColor(runnerColor, backLineColor(0), float(i)/float(runnerLength)));
    pg.line(runnerSpots[j].X, runnerSpots[j].Y, runnerSpots[k].X, runnerSpots[k].Y);
  }
  pg.rotate(-backOvalRot);
  pg.translate(-backOvalOffsetX, -backOvalOffsetX);
}

Tracer newRandomTracer(color col) {
  float r = randomRadius();
  float speed = random(minSpeed-maxSpeed, maxSpeed-minSpeed);
  if (speed < 0) {
    speed -= minSpeed;
  } else {
    speed += minSpeed;
  }
  return new Tracer(random(xLimMin+r, xLimMax-r), random(yLimMin+r, yLimMax-r))
             .WithRadius(r)
             .WithSpeed(speed)
             .WithAngle(random(TWO_PI))
             .WithTail(tailLength)
             .WithColor(col)
             .WithStroke(maxStroke)
             .WithSize(headSize);
}

color backLineColor(int shift) {
  int i = int(backPalI) + shift;
  if (i >= backPal.Size()) {
    i -= backPal.Size();
  } else if (i < 0) {
    i += backPal.Size();
  }
  return backPal.Get(i).Copy().SetAlpha(255).Value;
}

color tracerColor(int shift) {
  int i = int(backPalI) + shift;
  if (i >= tracerPal.Size()) {
    i -= tracerPal.Size();
  } else if (i < 0) {
    i += tracerPal.Size();
  }
  return tracerPal.Get(i).Value;
}

float adjustSpeed(float cur, float dMax, float ddMax) {
  return min(max(cur + random(-ddMax, ddMax), -dMax), dMax);
}

float randomRadius() {
  return random(pg.height/2.0-minRadius)+minRadius;
}
