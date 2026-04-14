int circleMaxDiameter, squareMax;
int spacing = 100;
int offset = -1;

void setup() {
  size(600, 600);
  squareMax = max(width, height);
  circleMaxDiameter = int(2.0*sqrt(squareMax*squareMax/2));
}

void draw() {
  background(0);
  translate(width/2, height/2);
  rectMode(CENTER);
  noFill();
  strokeWeight(10.0);
  
  offset++;
  if (offset >= spacing) {
    offset = 0;
  }
  
  stroke(#FFAAFF);
  drawLinesCCW(PI/8);

  stroke(#0000FF);
  drawSquaresGrowing(0);

  stroke(#FF00FF);
  drawLinesCW(0);
  
  stroke(#FF0000);
  drawCirclesShrinking(-spacing/4);
  
  stroke(#5555FF);
  drawSquaresGrowing(-spacing/2);

  stroke(#FFAAAA);
  drawCirclesShrinking(-spacing*3/4);
}

void drawSquaresGrowing(int start) {
  for (int i = start; i < squareMax+spacing; i += spacing) {
    int w = i + offset;
    if (w > 0 && w < squareMax) {
      square(0, 0, w);
    }
  }
}

void drawSquaresShrinking(int start) {
  for (int i = start; i < squareMax+spacing; i += spacing) {
    int w = i - offset;
    if (w > 0 && w < squareMax) {
      square(0, 0, w);
    }
  }
}

void drawCirclesGrowing(int start) {
  for (int i = start; i < circleMaxDiameter+spacing; i += spacing) {
    int r = i + offset;
    if (r > 0 && r < circleMaxDiameter) {
      circle(0, 0, r);
    }
  }
}

void drawCirclesShrinking(int start) {
  for (int i = start; i < circleMaxDiameter+spacing; i += spacing) {
    int r = i - offset;
    if (r > 0 && r < circleMaxDiameter) {
      circle(0, 0, r);
    }
  }
}

void drawLinesCW(float start) {
  for (float i = start; i < HALF_PI; i += PI/4) {
    float a = i + map(offset, 0, spacing-1, 0, HALF_PI);
    float x = circleMaxDiameter * cos(a);
    float y = circleMaxDiameter * sin(a);
    line(-x, -y, x, y);
    x = circleMaxDiameter * cos(a+HALF_PI);
    y = circleMaxDiameter * sin(a+HALF_PI);
    line(-x, -y, x, y);
  }
}

void drawLinesCCW(float start) {
  for (float i = start; i < HALF_PI; i += PI/4) {
    float a = i + map(offset, 0, spacing-1, HALF_PI, 0);
    float x = circleMaxDiameter * cos(a);
    float y = circleMaxDiameter * sin(a);
    line(-x, -y, x, y);
    x = circleMaxDiameter * cos(a+HALF_PI);
    y = circleMaxDiameter * sin(a+HALF_PI);
    line(-x, -y, x, y);
  }
}
