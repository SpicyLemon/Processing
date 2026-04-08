float xMin, xMax, yMin, yMax;
float xLimMin, xLimMax, yLimMin, yLimMax;
Trail[] trails;
int pointIndex;
float dOffset = 0.0;
Palette squarePal;
float squarePalI = 0.0;

int divs = 8;
float offset = 0.0;
float dOffsetMax = 0.05;
float ddOffsetMax = 0.005;
int pointCount = 50;
float dMax = 20.0;
float ddMax = 2.0;
float lineSize = 12.0;
color[] colors = new color[]{
  #9600B4, // Purple 
  #0000FF, // Blue
  #FF0000, // Red
  #560167, // Dark purple
  #00ADB2, // Teal
  #550000, // Dark-red  
};
float dSquarePalI = 0.1;
int entriesPerSquarePal = 50;

void setup() {
  // size(800, 800);
  fullScreen();
  
  xMax = width/2;
  xMin = -xMax;
  yMax = height/2;
  yMin = -yMax;
  xLimMin = xMin * 0.7;
  xLimMax = xMax * 0.7;
  yLimMin = yMin * 0.7;
  yLimMax = yMax * 0.7;
  
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
  
  trails = new Trail[colors.length];
  for (int i = 0; i < colors.length; i++) {
    trails[i] = new Trail(pointCount, colors[i]);
  }
  pointIndex = pointCount - 1;
}

void draw() {
  background(0);
  translate(width/2, height/2); // Move (0,0) to the center.
  
  // Move the squares to the next color
  squarePalI += dSquarePalI;
  if (int(squarePalI) >= squarePal.Size()) {
    squarePalI = 0.0;
  }
  
  // Adjust the overall offset (makes the whole thing spin).
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

  // Draw the background squares.
  for (int i = 0; i < divs; i++) {
    drawBack();
    rotate(TWO_PI/divs);
  }
  
  // Draw all the trails.
  for (int i = 0; i < divs; i++) {
    for (Trail trail : trails) {
      stroke(trail.Col);
      drawLines(trail.Points);
    }
    rotate(TWO_PI/divs);
  }
}

void drawBack() {
  noStroke();
  fill(squarePal.Get(int(squarePalI)).Value);
  square(0, -10, yMax*0.8);
}

void drawLines(Point[] points) {
  for (int i = 0; i < pointCount-1; i++) {
    strokeWeight(map(i, 0, pointCount-1, lineSize, 0));
    Point p1 = points[(pointIndex + i + 1) % pointCount];
    Point p2 = points[(pointIndex + i + 2) % pointCount];
    line(p1.X, p1.Y, p2.X, p2.Y);
  }
}

Point[] newPoints() {
  Point[] rv = new Point[pointCount];
  rv[0] = new Point(random(xLimMax), random(yLimMax))
         .WithVelocity(random(dMax), random(dMax));
  for (int i = 1; i < pointCount; i++) {
    rv[i] = rv[i-1]
           .Copy()
           .Accelerate(random(-ddMax, ddMax), random(-ddMax, ddMax), dMax)
           .Move();
  }
  return rv;
}
