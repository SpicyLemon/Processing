ArrayList<Line> lines;
ArrayList<Splitter> splitters;
float xLimMin, xLimMax, yLimMin, yLimMax;
float offsetHighlightMid, offsetHighlightMain;
color[] baseColors = new color[]{
  #FF00FF, // Magenta
  #FFAA00, // Orange
  #FF0000, // Red
  #AA00FF, // Purple
  //#FF0000, // Red
  //#FFFF00, // Yellow
  //#00FF00, // Green
  //#00FFFF, // Cyan
  //#0000FF, // Blue
  //#FF00FF, // Magenta
};
color[] colors;
color[] colorHighlights;
color[][] splitterColors;
HashMap<Integer, Integer> colorIndex;
boolean loopBaseColors = true;
int colorsBetweenBases = 5;

float border = 25;
float borderWeight = 2;
color borderColor = #FFFFFF;

float mainDirMin = 100;
float mainDirMax = 400;
float offDirMin = 25;
float offDirMax = 100;
float minLength = 200;
float maxLength = 400;
float minSpeed = 5;
float maxSpeed = 25;
float lineWeight = 10.0;
float lineHighlightMidWeight = 4.0;
float lineHighlightMainWeight = 1.0;
color lineHighlightColor = #FFFFFF;
int maxLines = 100;
int newLineChances = 5;
float newLineOdds = 8;

float splitterStartLen = 25;
float splitterStartWeight = 4.0;
float splitterSecondLen = 13;
float splitterSecondWeight = 2.0;
float splitterThirdLen = 20;
float splitterThirdWeight = 3.0;
float splitterThirdAngleMax = PI/3;
int newSplitterChances = 10;
float newSplitterOdds = 4;
int maxSplitters = 500;

color backgroundColor = #14041C;

boolean DEBUG = false;

static float PI_3_2 = HALF_PI + PI;

void setup() {
  fullScreen();

  lines = new ArrayList<>();
  splitters = new ArrayList<>();
  
  xLimMin = border;
  yLimMin = border;
  xLimMax = width-border;
  yLimMax = height-border;
  
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
  
  splitterColors = new color[colors.length][7];
  for (int i = 0; i < colors.length; i++) {
    for (int j = 0; j < splitterColors[0].length; j++) {
      // Using j+1 so that the zeroth color is slightly darker.
      // using /...+1 so that the last color isn't just black.
      splitterColors[i][j] = lerpColor(colors[i], backgroundColor, float(j+1)/float(splitterColors[0].length+1));
    }
  }
}

void draw() {
  background(backgroundColor);
  
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
    }
  }
  if (lines.size() == 0) {
    lines.add(newLine());
  }
  
  for (Splitter splitter : splitters) {
    splitter.Move();
  }
  
  for (int i = splitters.size()-1; i >= 0; i--) {
    if (splitters.get(i).IsDead()) {
      splitters.remove(i);
    }
  }
  
  for (int i = 1; i <= newSplitterChances && splitters.size() < maxSplitters; i++) {
    if (int(random(newSplitterOdds)) == 0) {
      Splitter[] ns = newSplitters();
      splitters.add(ns[0]);
      splitters.add(ns[1]);
    }
  }
  
  // drawBorder();
  
  for (Splitter splitter: splitters) {
    splitter.Draw();
  }

  for (Line line : lines) {
    line.DrawShort();
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

void drawBorder() {
  strokeWeight(borderWeight);
  stroke(borderColor);
  line(xLimMin, yLimMin, xLimMin, yLimMax);
  line(xLimMin, yLimMax, xLimMax, yLimMax);
  line(xLimMax, yLimMax, xLimMax, yLimMin);
  line(xLimMax, yLimMin, xLimMin, yLimMin);
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
      y = height + 5;
      break;
    case Down:
      x = random(xLimMin, xLimMax);
      y = -5;
      break;
    case Left:
      x = width + 5;
      y = random(yLimMin, yLimMax);
      break;
    case Right:
      x = -5;
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
      rv.SetLast(cur.x, -5);
      break;
    case Down:
      rv.SetLast(cur.x, height+5);
      break;
    case Left:
      rv.SetLast(-5, cur.y);
      break;
    case Right:
      rv.SetLast(width+5, cur.y);
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
