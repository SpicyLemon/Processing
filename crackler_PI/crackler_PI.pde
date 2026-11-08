import gifAnimation.*;

GifMaker gifExport;
int gifFrameRate = 20; // fps
boolean saveGif = false;

PGraphics pg;
ArrayList<Line> lines;
ArrayList<Splitter> splitters;
ArrayList<Pinwheel> pinwheels;
ArrayList<Puddle> puddles;
ArrayList<Zapper> zappers;
float xLimMin, xLimMax, yLimMin, yLimMax;
float offsetHighlightMid, offsetHighlightMain;
color[] baseColors = new color[]{
  #FF0000, // Red
  #FFFF00, // Yellow
  #00FF00, // Green
  #00FFFF, // Cyan
  #0000FF, // Blue
  #FF00FF, // Magenta
  #FFAA00, // Orange
  #FF0000, // Red
  #AA00FF, // Purple
  #FF00FF, // Magenta
};
color[] colors;
color[] colorHighlights;
color[][] splitterColors;
color[][] pinwheelColors;
color[] pinwheelHighlights;
HashMap<Integer, Integer> colorIndex;
boolean loopBaseColors = true;
int colorsBetweenBases = 5;

PVector[][] pinwheelCorners;

float border = 25;
float borderWeight = 2;
color borderColor = #FFFFFF;
float offscreenDist = 20;

float mainDirMin = 200;
float mainDirMax = 500;
float offDirMin = 25;
float offDirMax = 100;
float minLength = 200;
float maxLength = 400;
float minSpeed = 15;
float maxSpeed = 25;
float lineWeight = 10.0;
float lineHighlightMidWeight = 4.0;
float lineHighlightMainWeight = 1.0;
color lineHighlightColor = #FFFFFF;
int maxLines = 1;
int newLineChances = 5;
float newLineOdds = 30;

float splitterStartLen = 35;
float splitterStartWeight = 4.0;
float splitterStartAngleMax = PI/5;
int newSplitterChances = 10;
float newSplitterOdds = 4;
int maxSplitters = 500;

float pinwheelSize = 40;
color pinwheelHighlightColor = #FFFFFF;

float zapperAngleMax = PI/6;
float zapperLengthMin = 5;
float zapperLengthMax = 15;

color backgroundColor = #000000; //#14041C;

boolean DEBUG = false;
boolean showFPS = false;

static float PI_3_2 = HALF_PI + PI;
int lineCount = 0;
int starts = 0;

void setup() {
  fullScreen(P2D);
  frameRate(20);
  pg = createGraphics(width, height, P2D);

  // Set up the gif exporter.
  if (saveGif) {
    gifExport = new GifMaker(this, "crackler.gif");
    gifExport.setRepeat(0); // Loop forever.
    gifExport.setDelay(1000/gifFrameRate);
  }

  lines = new ArrayList<>();
  splitters = new ArrayList<>();
  pinwheels = new ArrayList<>();
  puddles = new ArrayList<>();
  zappers = new ArrayList<>();
  
  xLimMin = border;
  yLimMin = border;
  xLimMax = pg.width-border;
  yLimMax = pg.height-border;
  
  offsetHighlightMain = max(lineWeight/2-1, 1);
  offsetHighlightMid = max(lineWeight/2-2, 2);
  if (offsetHighlightMain == offsetHighlightMid) {
    offsetHighlightMid++;
  }
  
  if (loopBaseColors) {
    colors = new color[baseColors.length*(colorsBetweenBases + 1)];
    int idx = 0;
    for (int c = 0; c < baseColors.length; c++) {
      color c1 = baseColors[c];
      color c2 = baseColors[(c+1) % baseColors.length];
      colors[idx++] = c1;
      for (int n = 1; n <= colorsBetweenBases; n++) {
        colors[idx++] = lerpColor(c1, c2, (float)n / (colorsBetweenBases+1));
      }
    }
  } else {
    colors = new color[baseColors.length+(baseColors.length-1)*colorsBetweenBases];
    int idx = 0;
    for (int c = 0; c < baseColors.length - 1; c++) {
      color c1 = baseColors[c];
      color c2 = baseColors[c+1];
      colors[idx++] = c1;
      for (int n = 1; n <= colorsBetweenBases; n++) {
        colors[idx++] = lerpColor(c1, c2, (float)n/(colorsBetweenBases+1));
      }
    }
    colors[idx] = baseColors[baseColors.length-1];
  }
  
  colorIndex = new HashMap<>();
  for (int i = 0; i < colors.length; i++) {
    colorIndex.put(colors[i], i);
  }
  
  colorHighlights = new color[colors.length];
  for (int i = 0; i < colors.length; i++) {
    colorHighlights[i] = lerpColor(colors[i], lineHighlightColor, 0.5);
  }
  
  splitterColors = new color[colors.length][8];
  for (int i = 0; i < colors.length; i++) {
    for (int j = 0; j < splitterColors[0].length; j++) {
      // Using j+1 so that the zeroth color is slightly darker.
      // using /...+1 so that the last color isn't just black.
      float p = float(j+1)/float(splitterColors[0].length+1);
      color c = lerpColor(colors[i], backgroundColor, p);
      int a = int(255 - 205.0 * j / float(splitterColors[0].length+1));
      splitterColors[i][j] = setAlpha(c, a);
    }
  }
  
  int pinwheelColorCount = 6;
  pinwheelColors = new color[colors.length][pinwheelColorCount];
  for (int i = 0; i < colors.length; i++) {
    for (int j = 0; j < pinwheelColorCount; j++) {
      float p = float(j)/float(pinwheelColorCount);
      color c = lerpColor(colors[i], backgroundColor, p);
      // a = 255 at j = 0, and 50 at j = max.
      int a = int(255 - 205.0 * j / (pinwheelColorCount - 1));
      pinwheelColors[i][j] = setAlpha(c, a);
    }
  }
  
  pinwheelHighlights = new color[pinwheelColorCount];
  for (int j = 0; j < pinwheelHighlights.length; j++) {
    float p = float(j)/float(pinwheelHighlights.length);
    color c = lerpColor(pinwheelHighlightColor, backgroundColor, p);
    int a = int(255 - 205.0 * j / (pinwheelHighlights.length - 1));
    pinwheelHighlights[j] = setAlpha(c, a);
  }
  
  pinwheelCorners = new PVector[4][pinwheelColorCount];
  for (int i = 0; i < pinwheelColorCount; i++) {
    float s = map(i, 0, pinwheelColorCount+1, pinwheelSize, 0);
    pinwheelCorners[0][i] = new PVector(-s, -s);
    pinwheelCorners[1][i] = new PVector(s, -s);
    pinwheelCorners[2][i] = new PVector(s, s);
    pinwheelCorners[3][i] = new PVector(-s, s);
  }
  
  starts = 1;
}

void draw() {
  pg.beginDraw();
  pg.background(backgroundColor);
  
  switch (lineCount) {
    case 0:
    case 1: maxLines = 1; break;
    case 2: 
    case 3: maxLines = 2; break;
    case 4:
    case 5: maxLines = 3; break;
    case 6: 
    case 7: 
    case 8:
    case 9:
    case 10:
    case 11: maxLines = 5; break;
    case 12: 
    case 13: 
    case 14:
    case 15: 
    case 16:
    case 17:
    case 18:
    case 19:
    default: maxLines = 8; break;
  }
  
  if (lineCount >= 25) {
    lineCount = 0;
    maxLines = 1;
    starts++;
  }
  if (saveGif && starts >= 2) {
    maxLines = 0;
  }
  
  for (Line line : lines) {
    line.Move();
  }
  
  for (int i = lines.size()-1; i >= 0; i--) {
    if (lines.get(i).IsDead()) {
      lines.remove(i);
    }
  }
  
  for (int i = 1; i <= newLineChances && lines.size() < maxLines; i++) {
    if (int(random(newLineOdds)) == 0) {
      lines.add(newLine());
      lineCount++;
    }
  }
  if (lines.size() == 0 && maxLines > 0) {
    lines.add(newLine());
    lineCount++;
  }
  
  for (Puddle puddle : puddles) {
    puddle.Move();
  }
  
  for (int i = puddles.size()-1; i >= 0; i--) {
    if (puddles.get(i).IsDead()) {
      puddles.remove(i);
    }
  }
  
  for (Pinwheel pinwheel : pinwheels) {
    if (pinwheel.LeavingCenter()) {
      puddles.add(new Puddle(pinwheel.Corners, pinwheel.Pal));
    }
  }
  
  for (Zapper zapper : zappers) {
    zapper.Move();
  }
  
  for (int i = zappers.size()-1; i >= 0; i--) {
    if (zappers.get(i).IsDead()) {
      zappers.remove(i);
    }
  }
  
  for (Pinwheel pinwheel : pinwheels) {
    if (pinwheel.ReachedEdge()) {
      for (Zapper zapper : newZappers(pinwheel)) {
        zappers.add(zapper);
      }
    }
  }
  
  for (Pinwheel pinwheel : pinwheels) {
    pinwheel.Move();
  }
  
  for (int i = pinwheels.size()-1; i >= 0; i--) {
    if (pinwheels.get(i).IsDead()) {
      pinwheels.remove(i);
    } 
  }
  
  for (Splitter splitter : splitters) {
    if (splitter.Age == 3) {
      for (Pinwheel pinwheel : newPinwheels(splitter)) {
        pinwheels.add(pinwheel);
      }
    }
  }
  
  for (Splitter splitter : splitters) {
    splitter.Move();
  }
  
  for (int i = splitters.size()-1; i >= 0; i--) {
    if (splitters.get(i).IsDead()) {
      splitters.remove(i);
    }
  }
  
  for (int i = 1; i <= (newSplitterChances + lines.size()) && splitters.size() < maxSplitters; i++) {
    if (int(random(newSplitterOdds)) == 0 && lines.size() > 0) {
      for (Splitter splitter : newSplitters()) {
        splitters.add(splitter);
      }
    }
  }
  
  // drawBorder();
  
  for (Puddle puddle : puddles) {
    puddle.Draw();
  }
  
  for (Zapper zapper : zappers) {
    zapper.Draw();
  }
  
  for (Pinwheel pinwheel : pinwheels) {
    pinwheel.Draw();
  }
  
  //for (Splitter splitter : splitters) {
  //  splitter.Draw();
  //}

  for (Line line : lines) {
    line.DrawShort();
  }

  if (saveGif) {
    // Add this frame to the gif.
    gifExport.addFrame();

    // Finish and save.
    if (starts >= 2 && lines.size() == 0 && pinwheels.size() == 0 && zappers.size() == 0 && puddles.size() == 0) {
      gifExport.finish();
      println("GIF saved!");
      exit();
    }
  }

  if (showFPS) {
    drawFPS();
  }
  if (DEBUG) {
    println(getFPSText());
  }
  
  pg.endDraw();
  image(pg, 0, 0, width, height);
}

void keyPressed() {
  if (key == 'f' || key == 'F') {
    showFPS = !showFPS;
  }
}

void mousePressed() {
  if (mouseButton == LEFT) {
    noLoop();
    DEBUG = true;
    redraw();
  } else if (mouseButton == RIGHT) {
    DEBUG = false;
    loop();
  }
}

void drawFPS() {
  String txt = getFPSText();
  pg.textSize(16);
  float pad = 4;
  float w = pg.textWidth(txt) + 2*pad;
  float h = pg.textAscent() + pg.textDescent() + 2*pad;
  pg.noStroke();
  pg.fill(0, 160);
  pg.rect(0, pg.height - h, w, h);
  pg.fill(255);
  pg.textAlign(LEFT, BOTTOM);
  pg.text(txt, pad, pg.height - pad);
}

String getFPSText() {
  return nf(frameRate, 0, 1) + " fps: " + lines.size() + "/" + maxLines + " = " + lineCount;
}

void drawBorder() {
  pg.strokeWeight(borderWeight);
  pg.stroke(borderColor);
  pg.line(xLimMin, yLimMin, xLimMin, yLimMax);
  pg.line(xLimMin, yLimMax, xLimMax, yLimMax);
  pg.line(xLimMax, yLimMax, xLimMax, yLimMin);
  pg.line(xLimMax, yLimMin, xLimMin, yLimMin);
}

color randomColor() {
  return colors[(int) random(colors.length)];
}

Line newLine() {
  Direction mainDir = randomDirection();
  float x = 0;
  float y = 0;
  switch (mainDir) {
    case Up:
      x = random(xLimMin, xLimMax);
      y = pg.height + offscreenDist;
      break;
    case Down:
      x = random(xLimMin, xLimMax);
      y = -offscreenDist;
      break;
    case Left:
      x = pg.width + offscreenDist;
      y = random(yLimMin, yLimMax);
      break;
    case Right:
      x = -offscreenDist;
      y = random(yLimMin, yLimMax);
      break;
  }

  Line rv = new Line(randomColor(), x, y)
            .WithLength(random(minLength, maxLength))
            .WithSpeed(random(minSpeed, maxSpeed));
  rv = rv.Go(mainDir, random(mainDirMin, mainDirMax));

  PVector cur = rv.Last();
  while (IsInBorder(cur)) {
    Direction nextDir = randomPerpendicular(mainDir);
    float nextDirMax = min(offDirMax, DistanceToLimit(cur, nextDir));
    if (nextDirMax <= offDirMin) {
      nextDir = nextDir.Opposite();
      nextDirMax = min(offDirMax, DistanceToLimit(cur, nextDir));
    }
    rv = rv.Go(nextDir, random(offDirMin, nextDirMax));
    rv = rv.Go(mainDir, random(mainDirMin, mainDirMax));
    cur = rv.Last();
  }

  switch (mainDir) {
    case Up:
      rv.SetLast(cur.x, -offscreenDist);
      break;
    case Down:
      rv.SetLast(cur.x, pg.height+offscreenDist);
      break;
    case Left:
      rv.SetLast(-offscreenDist, cur.y);
      break;
    case Right:
      rv.SetLast(pg.width+offscreenDist, cur.y);
      break;
  }

  return rv;
}

Splitter[] newSplitters() {
  Line parent = lines.get(int(random(lines.size())));
  float d = parent.Head - random(parent.Head - parent.Tail)/2;
  PVector start = parent.GetPoint(d);
  Direction lineDir = parent.GetDir(d);
  Direction dir1 = lineDir.TurnCW();
  Direction dir2 = lineDir.TurnCCW();
  return new Splitter[]{
    new Splitter(start, dir1, parent),
    new Splitter(start, dir2, parent),
  };
}

Pinwheel[] newPinwheels(Splitter s) {
  color[] pal = pinwheelColors[colorIndex.get(s.Parent.Col)];
  return new Pinwheel[]{
    new Pinwheel(s.LastSplit1, pal, 0),
    new Pinwheel(s.Split, pal, 0),
    //new Pinwheel(s.Path1B[s.Path1B.length-1], pal, 0),
    //new Pinwheel(s.Path2A[s.Path2A.length-1], pal, 0),
    new Pinwheel(s.LastSplit2, pal, 0),
  };
}

float[] zapperMainDirs = new float[]{
  5 * PI / 4, // Upper Left,
  7 * PI / 4, // Upper Right,
  PI / 4,     // Lower Right,
  3 * PI / 4, // Lower Left,
};

Zapper[] newZappers(Pinwheel pinwheel) {
  Zapper[] rv = new Zapper[4];
  for (int i = 0; i < 4; i++) {
    rv[i] = new Zapper(pinwheel.Corners[i][0], zapperMainDirs[i], 7, pinwheel.Pal[0]);
  }
  return rv;
}

float DistanceToLimit(PVector cur, Direction dir) {
  switch (dir) {
    case Up: return cur.y - yLimMin;
    case Down: return yLimMax - cur.y;
    case Left: return cur.x - xLimMin;
    case Right: return xLimMax - cur.x;
  }
  return 0.0;
}

boolean IsInBorder(PVector p) {
  return xLimMin <= p.x && p.x <= xLimMax && yLimMin <= p.y && p.y <= yLimMax;
}

color setAlpha(color col, int alpha) {
  return (col & 0x00FFFFFF) | ((alpha & 0xFF) << 24);
}

boolean roughlyEqual(float a, float b) {
  return abs(a - b) < 0.001;
}

boolean lineContains(PVector p1, PVector p2, PVector toCheck) {
  float dx = p2.x - p1.x;
  float dy = p2.y - p1.y;

  // Degenerate case: p1 and p2 are the same point.
  if (roughlyEqual(dx, 0.0) && roughlyEqual(dy, 0.0)) {
    return roughlyEqual(toCheck.x, p1.x) && roughlyEqual(toCheck.y, p1.y);
  }

  // Walk along the larger axis to find t, then confirm the other
  // coordinate lands where it should (this is the collinearity check).
  float t;
  if (abs(dx) >= abs(dy)) {
    t = (toCheck.x - p1.x) / dx;
    if (!roughlyEqual(toCheck.y, p1.y + t * dy)) return false;
  } else {
    t = (toCheck.y - p1.y) / dy;
    if (!roughlyEqual(toCheck.x, p1.x + t * dx)) return false;
  }

  // t within [0, 1] means toCheck falls between the endpoints.
  return t >= 0.0 && t <= 1.0;
}
