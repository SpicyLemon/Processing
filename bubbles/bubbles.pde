Spot[][] centers;
float sqrt34;
float offsetX, offsetY;
int hCount;
int vCount;

boolean drawCircles = false;
float radius = 50;
float maxDRadius = 1;
color[] colors = new color[]{
  #FF0000, // Red 
  #00FF00, // Green
  #FF00FF, // Magenta
  #00FFFF, // Cyan
  #FFFF00, // Yellow
  #AA00FF, // Purple
  #FFAA00, // Orange
};
int changeOdds = 10;

void setup() {
  size(600, 600);
  // sqrt(3/4) is important here because:
  // 1. A hex can be thought of as six equaliateral triangles.
  // 2. An equilateral triangle cut in half is a 30-60-90 triangle.
  // 3. A 30-60-90 triangle has sides 1, 1/2, and sqrt(3/4).
  // So each row of circles is 2*sqrt(3/4) * radius above the next row.
  // At the same time, each circle in each row is 2 * radius to the left of the next.
  sqrt34 = sqrt(3.0/4.0);
  
  // Taking 10 out of the width and height to ensure that there's at least some padding.
  hCount = int((width-10)/(radius*2));
  vCount = int((height-2*radius-10)/(sqrt34*radius*2))+1;
  centers = new Spot[vCount][hCount];
  for (int v = 0; v < vCount; v++) {
    // The y for this row is radius + 2*sqrt(3/4)*radius*<row number>.
    float y = radius + 2 * sqrt34 * radius * v;
    // The zeroth row starts at x = radius.
    // The next row starts at x = 2 * radius (half a circle over).
    // The next row is back to starting at x = radius.
    float s = (v % 2 == 0) ? radius : 2 * radius;
    for (int h = 0; h < hCount; h++) {
      // The x for this circle is <start> + 2 * radius * <circle number>.
      centers[v][h] = new Spot(s + 2 * radius * h, y);
    }
  }
  
  // Calculate the full width and height of the space that the circles occupy.
  // Each circle is 2 * radius to the left of the next.
  // Same in the row below which is offset by the radius.
  // So horizontally, we occupy <num circles> * radius * 2 + radius.
  float fullWidth = hCount*radius*2 + radius;
  // Each row is 2*sqrt(3/4) * radius above the next.
  // There's 1 * radius on both the top and bottom of that.
  // And since we've accounted for 1/2 a circle on top and 1/2 a circle on bottom,
  // we remove one from the row count.
  // So vertically, we occupy 2*radius + (<num circles>-1)*sqrt(3/4)*radius*2.
  float fullHeight = 2 * radius + (vCount-1)*sqrt34*radius*2;
  offsetX = (width - fullWidth) / 2;
  offsetY = (height - fullHeight) / 2;
  
  // Set up the rest of the spot properties.
  for (Spot[] spots : centers) {
    for (Spot spot : spots) {
      spot.WithRadius(radius, random(maxDRadius))
          .WithColor(randomFadedColor());
    }
  }
}

void draw() {
  background(0);
  translate(offsetX, offsetY);
  
  if (drawCircles) {
    noFill();
    stroke(#FFFFFF);
    strokeWeight(2.0);
    for (Spot[] spots : centers) {
      for (Spot spot : spots) {
        if (spot != null) {
          circle(spot.X, spot.Y, radius*2);
        }
      }
    }
  }
  
  for (Spot[] spots : centers) {
    for (Spot spot : spots) {
      spot.Move();
    }
  }
  
  for (Spot[] spots : centers) {
    for (Spot spot : spots) {
      spot.Draw();
    }
  }
}

color randomColor() {
  return colors[int(random(colors.length))];
}

color setAlpha(color col, int alpha) {
  return (col & 0x00FFFFFF) | ((alpha & 0xFF) << 24);
}

color randomFadedColor() {
  return setAlpha(randomColor(), max(int(255.0/radius), 1));
}
