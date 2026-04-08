import gifAnimation.*;

GifMaker gifExport;
int gifFrameLimit = 500;
int gifFrameRate = 1000/30; // 30 fps
boolean saveGif = false;

float xLimMin, xLimMax, yLimMin, yLimMax;
Cross[] crosses;
int palLen = 16;
Palette[] crossPals = new Palette[]{
  new Palette(palLen, #FF00AA, #000000), // Pink
  new Palette(palLen, #FF0000, #000000), // Red
  new Palette(palLen, #00FF00, #000000), // Green
  new Palette(palLen, #AA00FF, #000000), // Purple
  new Palette(palLen, #FFFF00, #000000), // Yellow
};

float edgeLim = 0.05;
float centerMaxD = 2.5;
float otherMaxD = 5;

void setup() {
  fullScreen(); // size(600, 600);
  xLimMin = width*edgeLim;
  xLimMax = width*(1-edgeLim);
  yLimMin = height*edgeLim;
  yLimMax = height*(1-edgeLim);
  crosses = new Cross[crossPals.length];
  for (int i = 0; i < crosses.length; i++) {
    crosses[i] = new Cross(random(xLimMin, xLimMax), random(yLimMin, yLimMax), 
                           random(xLimMin, xLimMax), random(yLimMin, yLimMax))
                 .WithPalette(crossPals[i]);
  }
  
  // Set up the gif exporter.
  if (saveGif) {
    gifExport = new GifMaker(this, "crosses.gif");
    gifExport.setRepeat(0); // Loop forever.
    gifExport.setDelay(gifFrameRate);
  }
}

void draw() {
  background(#000000);
  for (Cross cross : crosses) {
    cross.Accelerate().Move();
  }
  for (int i = 0; i < palLen; i++) {
    for (Cross cross : crosses) {
      cross.DrawHist(i);
    }
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
