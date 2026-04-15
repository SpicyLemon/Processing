float xLimMin, xLimMax, yLimMin, yLimMax;
float squareWidth, squareHeight, squareXLeft, squareXRight, squareYTop, squareYBottom;
float maxLineLength;
float offset;
float dOffset = 0.001;
float angleDiv = HALF_PI/20;
float edgeBuffer = 0.1;
color[] colors = new color[]{
  #FFFFFF, // Upper Left.
  #FF0000, // Lower Left.
  #FF00FF, // Lower Right.
  #00FF00, // Upper Right.
};

void setup() {
  size(600, 600);
  xLimMin = width * edgeBuffer;
  xLimMax = width - xLimMin;
  yLimMin = height * edgeBuffer;
  yLimMax = height - yLimMin;
  squareWidth = xLimMin;
  squareHeight = yLimMin;
  squareXLeft = squareWidth / 2.0;
  squareXRight = width - squareWidth * 1.5;
  squareYTop = squareHeight / 2.0;
  squareYBottom = height - squareHeight * 1.5;
  maxLineLength = sqrt(width * width + height * height);
}

void draw() {
  background(0);
  strokeWeight(6);

  offset += dOffset;
  if (offset > angleDiv) {
    offset -= angleDiv;
  }

  float x, y;
  int alpha = 255;
  for (float angle = 0; angle < TWO_PI; angle += angleDiv) {
    alpha = alphaForAngle(angle+offset, PI + QUARTER_PI);

    // Draw the upper left corner lines.
    x = xLimMin + maxLineLength * cos(angle+offset);
    y = yLimMin + maxLineLength * sin(angle+offset);
    stroke(setAlpha(colors[0], alpha));
    line(xLimMin, yLimMin, x, y);
    
    // Draw the lower left corner lines.
    x = xLimMin + maxLineLength * cos(angle-offset);
    y = yLimMax - maxLineLength * sin(angle-offset);
    stroke(setAlpha(colors[1], alpha));
    line(xLimMin, yLimMax, x, y);
    
    // Draw the lower right corner lines.
    x = xLimMax - maxLineLength * cos(angle+offset);
    y = yLimMax - maxLineLength * sin(angle+offset);
    stroke(setAlpha(colors[2], alpha));
    line(xLimMax, yLimMax, x, y);
    
    // Draw the upper right corner lines.
    x = xLimMax - maxLineLength * cos(angle-offset);
    y = yLimMin + maxLineLength * sin(angle-offset);
    stroke(setAlpha(colors[3], alpha));
    line(xLimMax, yLimMin, x, y);
  }

  noStroke();

  fill(colors[0]);
  rect(squareXLeft, squareYTop, squareWidth, squareHeight);

  fill(colors[1]);
  rect(squareXLeft, squareYBottom, squareWidth, squareHeight);

  fill(colors[2]);
  rect(squareXRight, squareYBottom, squareWidth, squareHeight);

  fill(colors[3]);
  rect(squareXRight, squareYTop, squareWidth, squareHeight);
}

color setAlpha(color col, int alpha) {
  return (col & 0x00FFFFFF) | ((alpha & 0xFF) << 24);
}

int alphaForAngle(float angle, float zeroAngle) {
  float dAngle = abs(angle - zeroAngle);
  if (dAngle <= PI) {
    return int(map(dAngle, 0, PI, 0, 255));
  }
  return int(map(dAngle, PI, TWO_PI, 255, 0));
}
