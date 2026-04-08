import gifAnimation.*;

GifMaker gifExport;
int gifFrameLimit = 1500;
int gifFrameRate = 1000/30; // 30 fps
boolean saveGif = false;

float xMin, xMax, yMin, yMax;
float xLimMin, xLimMax, yLimMin, yLimMax;
Trail[] trails;
Point[] runnerPoints;
int runnerI;
int pointIndex;
float dOffset = 0.0;
Palette squarePal;
float squarePalI = 0.0;
float squareSize;

int divs = 7;
float offset = 0.0;
float dOffsetMax = 0.05;
float ddOffsetMax = 0.005;

int pointCount = 50;
float dMax = 20.0;
float ddMax = 2.0;
float lineSize = 15.0;
color[] colors = new color[]{
  #9600B4, // Purple 
  #0000FF, // Blue
  #FF0000, // Red
  #560167, // Dark purple
  #00ADB2, // Teal
  #550000, // Dark-red  
};

float dSquarePalI = 0.1;
int entriesPerSquarePal = 25;
float squareOffsetX = 25;
float squareOffsetY = -50;
float squareLineWidth = 3.0;

int pointsPerEdge = 25;
int runnerLength = 35;
color runnerColor = #FFFFFF;
float runnerSize = 15.0;

void setup() {
  fullScreen();
  
  // Set up the gif exporter.
  if (saveGif) {
    gifExport = new GifMaker(this, "kaleidoscope2.gif");
    gifExport.setRepeat(0); // Loop forever.
    gifExport.setDelay(gifFrameRate);
  }
  
  // Calculate some screen bounds.  
  xMax = width/2;
  xMin = -xMax;
  yMax = height/2;
  yMin = -yMax;
  xLimMin = xMin * 0.7;
  xLimMax = xMax * 0.7;
  yLimMin = yMin * 0.7;
  yLimMax = yMax * 0.7;
  squareSize = yMax * 0.8;
  
  // Create the palette that will be used to make the squares rotate through colors.
  color[] squareColors = new color[colors.length];
  for (int i = 0; i < colors.length; i++) {
    squareColors[i] = lerpColor(colors[i], #000000, 0.2);
  }
  squarePal = new Palette(entriesPerSquarePal, squareColors[0], squareColors[1]);
  for (int i = 1; i < colors.length; i++) {
    int j = (i + 1) % colors.length;
    squarePal = squarePal.Append(new Palette(entriesPerSquarePal+1, squareColors[i], squareColors[j]));
  }
  squarePal = squarePal.SetAlpha(100);
  
  // Calculate all the points that will be used for the runners.
  runnerPoints = new Point[pointsPerEdge * 4];
  float sqXMin = squareOffsetX;
  float sqXMax = sqXMin + squareSize;
  float sqYMin = squareOffsetY;
  float sqYMax = sqYMin + squareSize;
  for (int i = 0; i < pointsPerEdge; i++) {
    runnerPoints[i] = new Point(map(i, 0, pointsPerEdge, sqXMin, sqXMax), sqYMax);
    runnerPoints[pointsPerEdge+i] = new Point(sqXMax, map(i, 0, pointsPerEdge, sqYMax, sqYMin));
    runnerPoints[pointsPerEdge*2+i] = new Point(map(i, 0, pointsPerEdge, sqXMax, sqXMin), sqYMin);
    runnerPoints[pointsPerEdge*3+i] = new Point(sqXMin, map(i, 0, pointsPerEdge, sqYMin, sqYMax));
  }

  // Initialize all the trails.
  trails = new Trail[colors.length];
  for (int i = 0; i < colors.length; i++) {
    trails[i] = new Trail(pointCount, colors[i]);
  }
  pointIndex = pointCount - 1;
}

void draw() {
  background(0);
  translate(width/2, height/2); // Move (0,0) to the center.
  
  // Shift the squares to the next color
  squarePalI += dSquarePalI;
  if (int(squarePalI) >= squarePal.Size()) {
    squarePalI = 0.0;
  }
  
  // Adjust the overall rotational offset (makes the whole thing spin at random).
  dOffset = min(max(dOffset + random(-ddOffsetMax, ddOffsetMax), -dOffsetMax), dOffsetMax);
  offset += dOffset;
  if (offset >= TWO_PI) {
    offset -= TWO_PI;
  } else if (offset <= 0) {
    offset += TWO_PI;
  }
  rotate(offset);

  // Advance all the trails.
  int oldI = pointIndex;
  pointIndex = (pointIndex + 1) % pointCount;
  for (Trail trail : trails) {
    trail.Points[pointIndex] = trail.Points[oldI]
                              .Copy()
                              .Accelerate(random(-ddMax, ddMax), random(-ddMax, ddMax), dMax)
                              .Move();
  }
  
  // Move the runners.
  runnerI -= 1;
  if (runnerI < 0) {
    runnerI = runnerPoints.length-1;
  }

  // Draw the background squares.
  for (int d = 0; d < divs; d++) {
    drawBack();
    rotate(TWO_PI/divs);
  }
  
  // Draw the runners.
  for (int d = 0; d < divs; d++) {
    for (int i = runnerLength-2; i >= 0; i--) {
      int j = (runnerI + i) % runnerPoints.length;
      int k = (j + 1) % runnerPoints.length;
      strokeWeight(map(i, 0, runnerLength-1, runnerSize, squareLineWidth));
      stroke(lerpColor(runnerColor, backLineColor(), float(i)/float(runnerLength)));
      line(runnerPoints[j].X, runnerPoints[j].Y, runnerPoints[k].X, runnerPoints[k].Y);
    }
    rotate(TWO_PI/divs);
  }
  
  // Draw the square borders.
  for (int d = 0; d < divs; d++) {
    drawBackLines();
    rotate(TWO_PI/divs);
  }

  // Draw all the trails.
  for (int d = 0; d < divs; d++) {
    for (Trail trail : trails) {
      stroke(trail.Col);
      drawLines(trail.Points);
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

void drawBack() {
  noStroke();
  fill(squarePal.Get(int(squarePalI)).Value);
  square(squareOffsetX, squareOffsetY, squareSize);
}

void drawBackLines() {
  noFill();
  stroke(backLineColor());
  strokeWeight(5.0);
  square(squareOffsetX, squareOffsetY, squareSize);
}

color backLineColor() {
  return squarePal.Get(int(squarePalI)).Copy().SetAlpha(255).Value;
}

void drawLines(Point[] points) {
  for (int i = 0; i < pointCount-1; i++) {
    strokeWeight(map(i, 0, pointCount-1, lineSize, 0));
    Point p1 = points[(pointIndex + i + 1) % pointCount];
    Point p2 = points[(pointIndex + i + 2) % pointCount];
    line(p1.X, p1.Y, p2.X, p2.Y);
  }
}
