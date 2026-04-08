Point[] points;
boolean mouseWasPressed;
int pointCount = 15;
float lineLenMin = 5;
float lineLenMax = 50;
float lineWidth = 2.0;
float colShiftMax = 5.0;


void setup() {
  fullScreen();
  points = new Point[pointCount];
  for (int i = 0; i < pointCount; i++) {
    points[i] = new Point(random(width), random(height), NewRandomColor());
  }
  strokeWeight(lineWidth);
  mouseWasPressed = true;
}

void draw() {
  if (mouseWasPressed) {
    background(0);
    mouseWasPressed = false;
  }
  
  for (Point point : points) {
    float x1 = point.X;
    float y1 = point.Y;
    float lineLen = random(lineLenMin, lineLenMax);
    float angle = random(TWO_PI);
    float dx = lineLen * cos(angle);
    float dy = lineLen * sin(angle);
    float x2 = x1 + dx;
    if (x2 < 0 || width < x2) {
      x2 = x1 - dx;
    }
    float y2 = y1 + dy;
    if (y2 < 0 || height < y2) {
      y2 = y1 - dx;
    }
    point.X = x2;
    point.Y = y2;
    if (int(random(5)) == 0) {
      point.Col.AddRed(int(random(-colShiftMax, colShiftMax)));
    }
    if (int(random(5)) == 0) {
      point.Col.AddGreen(int(random(-colShiftMax, colShiftMax)));
    }
    if (int(random(5)) == 0) {
      point.Col.AddBlue(int(random(-colShiftMax, colShiftMax)));
    }

    stroke(point.Col.Value);
    line(x1, y1, x2, y2);
  }
}

void mousePressed() {
  mouseWasPressed = true;
}

Color NewRandomColor() {
  return new Color(int(random(256)), int(random(256)), int(random(256)));
}
