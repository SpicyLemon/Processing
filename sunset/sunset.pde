import gifAnimation.*;

GifMaker gifExport;
int gifFrameLimit = 500;
int gifFrameRate = 1000/30; // 30 fps
boolean saveGif = false;

float centerX, centerY, sunRadius, sunDiameter, focusY, skyRadius, skyDiameter;
float skyStartLeft, skyStartRight;
ArrayList<Line> lines = new ArrayList<>();
float[] vLines = new float[]{-2, -1, -0.333, 0.0, 0.333, 0.666, 1, 1.333, 2, 3};
Palette sunPal = new Palette(5, #FFFF00, #FF9900)    // Yellow to Orange.
         .Append(new Palette(11, #FF9900, #FF00FF))  // To Magenta.
         .Append(new Palette(12, #FF00FF, #FFFF00))  // To Yellow.
         .WithoutLast();
int framesPerSunPal = 10;
int visibleSunCols = 15;
Palette skyPal = new Palette(50, #009999, #0000AA)    // Teal to Dark Blue.
         .Append(new Palette(101, #0000AA, #AA00AA))  // To Purple.
         .Append(new Palette(102, #AA00AA, #009999))  // To Teal.
         .WithoutLast();
int visibleSkyCols = 150;

void setup() {
  size(600, 600);
  centerX = width/2;
  centerY = height/2;
  focusY = height*0.45;
  sunDiameter = 0.6 * min(width, height);
  sunRadius = sunDiameter / 2;
  skyRadius = mag(centerX, centerY);
  skyDiameter = skyRadius*2;
  skyStartLeft = PI*3/4;
  skyStartRight = TWO_PI+PI/4;
  
  // Set up the gif exporter.
  if (saveGif) {
    gifExport = new GifMaker(this, "sunset.gif");
    gifExport.setRepeat(0); // Loop forever.
    gifExport.setDelay(gifFrameRate);
  }
}

void draw() {
  background(0);
  
  // Rotate the sky palette every frame.
  skyPal.RotateLeft();
  
  // Rotate the sun gradient every few frames.
  if (frameCount % framesPerSunPal == 0) {
    sunPal.RotateLeft();
  }
  
  // Accelerate all the lines a little bit, and move them.
  for (Line line : lines) {
    line.Accelerate(0.05).Move();
  }
  
  // Remove any lines that are too far down now.
  for (int i = lines.size()-1; i >= 0; i--) {
    if (lines.get(i).Y > height) {
      lines.remove(i);
    }
  }
  
  // Add a new line every few frames.
  if (frameCount % 25 == 0) {
    lines.add(new Line(centerY).WithVelocity(0.2));
  }
  
  // Draw the sky (before the sun).
  noStroke();
  float aStop = PI * 3/4;
  for (float a = 0; a < aStop; a += 0.01) {
    int colI = int(map(a, 0, aStop, visibleSkyCols+1, 0));
    fill(skyPal.Get(colI).Value);
    
    arc(centerX, focusY, skyDiameter, skyDiameter, skyStartLeft+a, skyStartLeft+a+0.01);
    arc(centerX, focusY, skyDiameter, skyDiameter, skyStartRight-a-0.01, skyStartRight-a);
  }
  
  // Draw a black square on the bottom half to cut off the lower sky.
  fill(0);
  rect(0, centerY, width, height-centerY);
  
  // Draw the vertical lines. The point will be behind the sun, so we have to do these first.
  noFill();
  stroke(#FFFFFF);
  strokeWeight(2.0);
  for (float pct : vLines) {
    float x = width * pct;
    line(x, height, centerX, focusY);
  }  
  
  // Draw the sun.
  noStroke();
  float yStart = centerY - sunRadius;
  float yStop = centerY;
  for (float y = yStart; y <= yStop; y++) {
    float dy = y - centerY;
    float w = 2 * sqrt(sunRadius*sunRadius - dy*dy);
    
    int colI = int(map(y, yStart, yStop, 0, visibleSunCols) // Main portion of index.
                  +map(y%framesPerSunPal, 0, framesPerSunPal, 0, 1) // Fuzz/blend the colors a little bit.
                  +map(frameCount%framesPerSunPal, 0, framesPerSunPal, 0, 1)); // Smooth out the rotation.
    fill(sunPal.Get(colI).Value);
    
    if (!Float.isNaN(w)) {
      rect(centerX - w/2, y, w, 1);
    }
  }
  
  // Draw the horizon line.
  noFill();
  stroke(#FFFFFF);
  strokeWeight(2.0);
  //arc(centerX, centerY, sunDiameter, sunDiameter, PI, TWO_PI);
  line(0, centerY, width, centerY);
  
  // Draw the advancing horizontal lines.
  for (Line line : lines) {
    line(0, line.Y, width, line.Y);
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
