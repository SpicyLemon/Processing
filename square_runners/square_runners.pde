float xMin, xMax, yMin, yMax;
float xLimMin, xLimMax, yLimMin, yLimMax;
int xRes, yRes, xResMin, xResMax, yResMin, yResMax, perimeter;

Runner[] runners;
Palette dotPal;
color[] dotColors = new color[]{
  #FF0000, // Red
  #FFFF00, // Yellow
  #00FF00, // Green
  #00FFFF, // Cyan
  #0000FF, // Blue
  #FF00FF, // Magenta
};
color runnerEndColor = #000000;
int dotSize = 6;
int dotSpace = 9;
int trailLength = 6;
int changeDirOdds = 5;
boolean drawTheGrid = true;

void setup() {
  size(800, 600);
  frameRate(15);
  xMin = 0;
  xMax = width;
  yMin = 0;
  yMax = height;
  
  xLimMin = xMin + dotSpace/2 + 1;
  xLimMax = xMax - dotSpace/2 - 1;
  while ((xLimMax-xLimMin) % dotSpace != 0) {
    xLimMax--;
  }
  
  yLimMin = yMin + dotSpace/2 + 1;
  yLimMax = yMax - dotSpace/2 - 1;
  while ((yLimMax-yLimMin) % dotSpace != 0) {
    yLimMax--;
  }
  
  xRes = int((xLimMax-xLimMin)/float(dotSpace));
  yRes = int((yLimMax-yLimMin)/float(dotSpace));
  perimeter = xRes*2 + yRes*2;
  xResMin = 0;
  xResMax = xRes;
  yResMin = 0;
  yResMax = yRes;
  
  int colsPerPal = perimeter / dotColors.length;
  int perPalLeftovers = perimeter % dotColors.length;
  int colsInThisPal = colsPerPal;
  if (perPalLeftovers > 0) {
    colsInThisPal++;
    perPalLeftovers--;
  }
  dotPal = new Palette(colsInThisPal, dotColors[0], dotColors[1]);
  for (int i = 1; i < dotColors.length; i++) {
    int j = (i + 1) % dotColors.length;
    colsInThisPal = colsPerPal + 1;
    if (perPalLeftovers > 0) {
      colsInThisPal++;
      perPalLeftovers--;
    }
    if (i == dotColors.length-1) {
      colsInThisPal++;
    }
    dotPal = dotPal.Append(new Palette(colsInThisPal, dotColors[i], dotColors[j]));
  }
  dotPal = dotPal.WithoutLast();
  
  int r = 0;
  int col = 0;
  int runnerCount = perimeter/4 + (perimeter%4 == 0 ? 0 : 1);
  runners = new Runner[runnerCount];
  for (int x = xResMin; x < xResMax; x++) {
    if (col % 4 == 0) {
      runners[r] = new Runner(x, yResMin, dotPal.Get(col).Value, trailLength);
      r++;
    }
    col++;
  }
  for (int y = yResMin; y < yResMax; y++) {
    if (col % 4 == 0) {
      runners[r] = new Runner(xResMax, y, dotPal.Get(col).Value, trailLength);
      r++;
    }
    col++;
  }
  for (int x = xResMax; x > xResMin; x--) {
    if (col % 4 == 0) {
      runners[r] = new Runner(x, yResMax, dotPal.Get(col).Value, trailLength);
      r++;
    }
    col++;
  }
  for (int y = yResMax; y > yResMin; y--) {
    if (col % 4 == 0) {
      runners[r] = new Runner(xResMin, y, dotPal.Get(col).Value, trailLength);
      r++;
    }
    col++;
  }
}

void draw() {
  background(0);
  strokeCap(PROJECT); // Make the points square.
  strokeWeight(dotSize);
  if (drawTheGrid) {
    drawGrid();
  }
  
  for (Runner runner : runners) {
    runner.Move();
  }
  
  for (int i = 1; i < trailLength; i++) {
    for (Runner runner : runners) {
      runner.DrawI(i);
    }
  }
}

void mousePressed() {
  if (mouseButton == LEFT) {
    noLoop();
    redraw();
  } else if (mouseButton == RIGHT) {
    loop();
  }
}

void drawGrid() {
  stroke(#222222);
  for (int x = xResMin; x <= xResMax; x++) {
    for (int y = yResMin; y <= yResMax; y++) {
      point(xLimMin + x*dotSpace, yLimMin + y*dotSpace);
    }
  }
}
