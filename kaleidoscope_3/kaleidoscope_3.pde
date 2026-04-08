import gifAnimation.*;

GifMaker gifExport;
int gifFrameLimit = 3000;
int gifFrameRate = 1000/30; // 30 fps
boolean saveGif = false;

float xMin, xMax, yMin, yMax;
float xLimMin, xLimMax, yLimMin, yLimMax;
float backOvalWidth, backOvalHeight;
float backOvalOffsetX, backOvalOffsetY;
Tracer[] tracers;

float offset = 0.0;
float dOffset = 0.0;
Palette backPal;
float backPalI = 0.0;
float dBackOvalOffsetX = 0.0;
float dBackOvalOffsetY = 0.0;
float backOvalRot = 0.0;
float dBackOvalRot = 0.0;
boolean mouseWasPressed = false;

color[] backColors = new color[]{
  #FF0000, // Red
  #FFFF00, // Yellow
  #00FF00, // Green
  #00FFFF, // Cyan
  #0000FF, // Blue
  #FF00FF, // Magenta
};
float dBackPalI = 0.1;
int entriesPerBackPal = 50;

int divs = 8;
float dOffsetMax = 0.05;
float ddOffsetMax = 0.0005;
float backOvalBorder = 3.0;
float backOvalOffsetMax = 100;
float dBackOvalOffsetMax = 5.0;
float ddBackOvalOffsetMax = 0.5;
float dBackOvalRotMax = 0.08;
float ddBackOvalRotMax = 0.005;

int tailLength = 25;
float maxStroke = 25.0;
float headSize = 0.0;
float maxSpeed = 12.0;
float minSpeed = 3.0;
float minRadius = 5.0;

void setup() {
  fullScreen();
  
  // Calculate some screen bounds.
  xMax = width/2;
  xMin = -xMax;
  yMax = height/2;
  yMin = -yMax;
  xLimMin = xMin * 0.95;
  xLimMax = xMax * 0.95;
  yLimMin = yMin * 0.95;
  yLimMax = yMax * 0.95;
 
  backOvalWidth = xMax * 0.8;
  backOvalHeight = yMax * 0.4;
  backOvalOffsetX = random(-backOvalOffsetMax, backOvalOffsetMax);
  backOvalOffsetY = random(-backOvalOffsetMax, backOvalOffsetMax);

  // Create the palette that will be used to make the squares rotate through colors.
  color[] colors = new color[backColors.length];
  for (int i = 0; i < backColors.length; i++) {
    colors[i] = lerpColor(backColors[i], #000000, 0.2);
  }
  backPal = new Palette(entriesPerBackPal, colors[0], colors[1]);
  for (int i = 1; i < colors.length; i++) {
    int j = (i + 1) % colors.length;
    backPal = backPal.Append(new Palette(entriesPerBackPal+1, colors[i], colors[j]));
  }
  backPal = backPal.SetAlpha(100);
  
  // Create the tracers
  tracers = new Tracer[2];
  tracers[0] = newRandomTracer(backLineColor(-entriesPerBackPal/2));
  tracers[1] = newRandomTracer(backLineColor(entriesPerBackPal/2));
  
  // Set up the gif exporter.
  if (saveGif) {
    gifExport = new GifMaker(this, "kaleidoscope3.gif");
    gifExport.setRepeat(0); // Loop forever.
    gifExport.setDelay(gifFrameRate);
  }
}

void draw() {
  background(0);
  translate(xMax, yMax);
  
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
  rotate(offset);
  
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
  
  // Adjust the colors of the tracers
  tracers[0].WithColor(backLineColor(-entriesPerBackPal/2));
  tracers[1].WithColor(backLineColor(entriesPerBackPal/2));
  
  // Move the tracers.
  for (Tracer tracer : tracers) {
    tracer.Move();
  }
  
  // Draw the background ovals.
  for (int d = 0; d < divs; d++) {
    drawBack();
    rotate(TWO_PI/divs);
  }
  
  // Draw the background oval borders.
  for (int d = 0; d < divs; d++) {
    drawBackLines();
    rotate(TWO_PI/divs);
  }
  
  // Draw the tracers
  for (int d = 0; d < divs; d++) {
    for (Tracer tracer : tracers) {
      tracer.Draw();
    }
    rotate(TWO_PI/divs);
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

void mousePressed() {
  mouseWasPressed = true;
}

void drawBack() {
  noStroke();
  fill(backPal.Get(int(backPalI)).Value);
  drawBackOval();
}

void drawBackLines() {
  noFill();
  stroke(backLineColor(0));
  strokeWeight(backOvalBorder);
  drawBackOval();
}

void drawBackOval() {
  translate(backOvalOffsetX, backOvalOffsetX);
  rotate(backOvalRot);
  ellipse(0, 0, backOvalWidth, backOvalHeight);
  rotate(-backOvalRot);
  translate(-backOvalOffsetX, -backOvalOffsetX);
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

float adjustSpeed(float cur, float dMax, float ddMax) {
  return min(max(cur + random(-ddMax, ddMax), -dMax), dMax);
}

float randomRadius() {
  return random(height/2.0-minRadius)+minRadius;
}
