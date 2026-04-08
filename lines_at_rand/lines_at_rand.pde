int linesPer = 25;
float lineLenMin = 20;
float lineLenMax = 50;
float lineWeight = 1.0;
boolean mouseWasPressed = false;

void setup() {
  size(1024, 768);
  background(0);
  strokeWeight(lineWeight);
}

void draw() {
  if (mouseWasPressed) {
    background(0);
    mouseWasPressed = false;
  }
  
  for (int i = 0; i < linesPer; i++) {
    float x1 = random(width);
    float y1 = random(height);
    float angle = random(TWO_PI);
    float lineLen = random(lineLenMin, lineLenMax);
    float x2 = x1 + cos(angle)*lineLen;
    float y2 = y1 + sin(angle)*lineLen;
    int col = color(int(random(256)), int(random(256)), int(random(256)));
    stroke(col);
    line(x1, y1, x2, y2);
  }  
}

void mousePressed() {
  mouseWasPressed = true;
}
