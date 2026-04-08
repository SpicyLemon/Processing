PGraphics pg;
float xLimMin, xLimMax, yLimMin, yLimMax;
Cross[] crosses;
int palLen = 16;
color[] crossCols = new color[]{
  #FF00AA, // Pink
  #FF0000, // Red
  #00FF00, // Green
  #AA00FF, // Purple
  #FFFF00, // Yellow
};

float edgeLim = 0.05;
float centerMaxD = 2.5;
float otherMaxD = 5;

void setup() {
  size(1024, 768);
  pg = createGraphics(width, height);
  xLimMin = width*edgeLim;
  xLimMax = width*(1-edgeLim);
  yLimMin = height*edgeLim;
  yLimMax = height*(1-edgeLim);
  crosses = new Cross[crossCols.length];
  for (int i = 0; i < crosses.length; i++) {
    crosses[i] = new Cross(random(xLimMin, xLimMax), random(yLimMin, yLimMax), 
                           random(xLimMin, xLimMax), random(yLimMin, yLimMax))
                 .WithColor(crossCols[i], palLen);
  }
}

void draw() {
  background(#000000);
  for (Cross cross : crosses) {
    cross.Accelerate().Move();
  }
  for (int i = 0; i < palLen; i++) {
    for (Cross cross : crosses) {
      cross.DrawHist(i);
    }
  }
}
