float maxLineLength;
float offset;
float dOffset = 0.001;
float angleDiv = HALF_PI/5;

void setup() {
  size(600, 600);
  maxLineLength = sqrt(width * width + height * height);
}

void draw() {
  background(0);
  noFill();
  stroke(#FFFFFF);
  offset += dOffset;
  if (offset > angleDiv) {
    offset -= angleDiv;
  }
  for (float angle = 0; angle <= HALF_PI; angle += angleDiv) {
    float x = maxLineLength * cos(angle+offset);
    float y = maxLineLength * sin(angle+offset);
    line(0, 0, x, y);
    line(width, height, width-x, height-y);
    x = maxLineLength * cos(angle-offset);
    y = maxLineLength * sin(angle-offset);
    line(0, height, x, height - y);
    line(width, 0, width-x, y);
  }
}
