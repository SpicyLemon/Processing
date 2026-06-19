import gifAnimation.*;

GifMaker gifExport;
int gifFrameLimit = 1950;
int gifFrameRate = 30; // 30 fps
boolean saveGif = false;

float xMin, xMax, yMin, yMax;
float xLimMin, xLimMax, yLimMin, yLimMax;
Palette[] palettes;

int palettesIndex = 6;
Tracer[] tracers;
boolean mouseWasPressed = false;
int tailLength = 50;
int palCountMult = 1;
float maxStroke = 30.0;
float headSize = 0.0;
float maxSpeed = 20.0;
float minSpeed = 5.0;
float minRadius = 5.0;
float dRadiusMin = 0.25;
float dRadiusMax = 2.5;
float changeDirOdds = 10;

boolean DEBUG = false;

void setup() {
  fullScreen();
  frameRate(30);
  
  xMin = 0.0;
  xMax = width;
  yMin = 0.0;
  yMax = height;
  xLimMax = xMax * 0.95;
  xLimMin = width-xLimMax;
  yLimMax = yMax * 0.95;
  yLimMin = height-yLimMax;
  
  if (DEBUG) {
    println("Width = " + width + " Height = " + height);
    println("X: [" + xLimMin + "," + xLimMax + "] | Y: [" + yLimMin + "," + yLimMax + "]");
  }
  
  // These all need to have exactly 20 total entries.
  palettes = new Palette[]{
    // [0]: Dark-Red to Blue.
    new Palette(20, #AA0000, #0000FF),
    // [1]: Green to teal to magenta.
    new Palette(10, #81FF5F, #04B4BC).Append(new Palette(11, #04B4BC, #EA24DE)),
    // [2]: Red to yellow.
    new Palette(17, #FF0000, #FFFF00).Append(new Palette(4, #FFFF00, #F0FF00)),
    // [3]: Y O R P B.
    new Palette(10, #FFFF00, #FF0000).Append(new Palette(11, #FF0000, #0000FF)),
    // [4]: Forrest.
    new Palette(7, #0FB7A7, #387627).Append(new Palette(8, #387627, #AAAA45))
                                    .Append(new Palette(7, #AAAA45, #93601C)),
    // [5]: Rainbow.                                    
    new Palette(#FF0055, #5500FF,
      #FF0000, #0000FF, #00FF00, #FFFF00, #FF00FF, #00FFFF,
      #AA0000, #0000AA, #00AA00, #AAAA00, #AA00AA, #00AAAA,
      #FFAA00, #AAFF00, #FF00AA, #AA00FF, #00FFAA, #00AAFF),
    // [6]: Pink to Orange to Yellow.
    new Palette(10, #FFAA00, #FF00AA).Append(new Palette(11, #FF00AA, #FFFF00)),
  };
  freshTracers();
  
  // Set up the gif exporter.
  if (saveGif) {
    gifExport = new GifMaker(this, "spiral-tracers.gif");
    gifExport.setRepeat(0); // Loop forever.
    gifExport.setDelay(1000/gifFrameRate);
  }
}

void draw() {
  background(0);
  if (mouseWasPressed) {
    mouseWasPressed = false;
    rotateColors();
  }
  for (Tracer tracer : tracers) {
    tracer.Move(false);
  }
  if (DEBUG) {
    for (int i = 0; i < tracers.length; i++) {
      println("[" + i + "]" + tracers[i].ToString());
    }
  }
  
  for (int i = 0; i < tailLength-1; i++) {
   for (Tracer tracer : tracers) {
      tracer.DrawI(i);
    }
  }
  for (Tracer tracer : tracers) {
    tracer.DrawDot();
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
  
  if (DEBUG) {
    println("--------------------");
  }
}

void mousePressed() {
  mouseWasPressed = true;
}

void freshTracers() {
  Palette colors = palettes[palettesIndex];
  tracers = new Tracer[colors.Size()*palCountMult];
  for (int i = 0; i < colors.Size(); i++) {
    for (int j = 0; j < palCountMult; j++) {
      tracers[i*palCountMult+j] = newRandomTracer(colors.Get(i));
    }
  }
}

Tracer newRandomTracer(Color col) {
  float r = randomRadius();
  float speed = random(minSpeed-maxSpeed, maxSpeed-minSpeed);
  if (speed < 0) {
    speed -= minSpeed;
  } else {
    speed += minSpeed;
  }
  return new Tracer(random(r, width-r), random(r, height-r))
              .WithRadius(r)
              .WithDRadius(randomDRadius())
              .WithSpeed(speed)
              .WithAngle(random(TWO_PI))
              .WithTail(tailLength)
              .WithColor(col.Value)
              .WithStroke(maxStroke)
              .WithSize(headSize);
}

void rotateColors() {
  palettesIndex = (palettesIndex + 1) % palettes.length;
  Palette colors = palettes[palettesIndex];
  for (int i = 0; i < colors.Size(); i++) {
    for (int j = 0; j < palCountMult; j++) {
      tracers[i*palCountMult+j].WithColor(colors.Get(i).Value);
    }
  }
}

float randomRadius() {
  return random(height/2.0-minRadius)+minRadius;
}

float randomDRadius() {
  float rv = random(dRadiusMin, dRadiusMax);
  if (int(random(2)) == 0) {
    return rv;
  }
  return -rv;
}

boolean isInLimits(float x, float y, float r) {
  return x - r >= xLimMin && x + r <= xLimMax
      && y - r >= yLimMin && y + r <= yLimMax;
}
