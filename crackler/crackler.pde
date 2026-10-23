ArrayList<Line> lines;
float xLimMin, xLimMax, yLimMin, yLimMax;
color[] baseColors = new color[]{
  #FF0000, // Red
  #FFFF00, // Yellow
  #00FF00, // Green
  #00FFFF, // Cyan
  #0000FF, // Blue
  #FF00FF, // Magenta
};
color[] colors;
boolean loopBaseColors = true;
int colorsBetweenBases = 1;

float border = 25;
float borderWeight = 2;
color borderColor = #FFFFFF;
float mainDirMin = 100;
float mainDirMax = 400;
float offDirMin = 25;
float offDirMax = 100;
float minLength = 100;
float maxLength = 300;
float minSpeed = 15;
float maxSpeed = 30;
float lineWeight = 8.0;
int maxLines = 100;

int newLineChances = 5;
float newLineOdds = 10;

boolean DEBUG = false;

void setup() {
  size(1024, 768);
  xLimMin = border;
  yLimMin = border;
  xLimMax = width-border;
  yLimMax = height-border;
  
  lines = new ArrayList<>();
  
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
}

void draw() {
  background(0);
  
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
  
  // drawBorder();
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
