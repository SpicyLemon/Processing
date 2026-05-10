import java.util.Collections;

Spot[][] centers;
SparseGrid<Spot> vertexSpots;
Vertex[][] vertexGrid;
float sqrt34, sqrt3;
float offsetX, offsetY;
int hCount, vCount;
float xLimMin, xLimMax, yLimMin, yLimMax;

// Angles corresponding to where the circles intersect to form the corners
// of the primary hexes that make up the grid.
// Directly right is just 0.0.
static float PI_1_3 = PI / 3;     // top right
static float PI_2_3 = PI * 2 / 3; // top left
// Directly left is just PI.
static float PI_4_3 = PI * 4 / 3; // bottom left
static float PI_5_3 = PI * 5 / 3; // bpttom right

// Angles corresponding to hex corners when the hex is rotated 90 degrees
// to the primary hexes that make up the grid.
static float PI_1_6 = PI / 6.0;         // bottom right corner
// The bottom is just HALF_PI.
static float PI_5_6 = PI * 5.0 / 6.0;   // bottom left corner
static float PI_7_6 = PI * 7.0 / 6.0;   // top left corner
static float PI_3_2 = PI + HALF_PI;     // top
static float PI_11_6 = PI * 11.0 / 6.0; // top right corner

boolean DEBUG = true;
boolean drawCircles = true;
boolean drawVertices = true;
float radius = 70;

void setup() {
  size(800, 600);
  frameRate(30);
  // sqrt(3/4) is important here because:
  // 1. A hex can be thought of as six equaliateral triangles.
  // 2. An equilateral triangle cut in half is a 30-60-90 triangle.
  // 3. A 30-60-90 triangle has sides 1, 1/2, and sqrt(3/4).
  sqrt34 = sqrt(3.0/4.0);
  sqrt3 = sqrt(3.0);
  
  // Taking 10 out of the width and height to ensure that there's some padding.
  // Adding two to each count so that the padding is still covered by a hex.
  hCount = int((2.0*(width-10)-radius)/(3.0*radius))+2;
  vCount = int((height-10-sqrt34*radius)/(sqrt3*radius))+2;
  if (DEBUG) {
    println("Dimensions:", hCount, "x", vCount);
  }
  centers = new Spot[vCount][hCount];
  for (int h = -1; h < hCount-1; h++) {
    float x = radius + radius * 3 / 2 * h;
    float s = (h % 2 == 0) ? sqrt34*radius : sqrt3 * radius;
    for (int v = -1; v < vCount-1; v++) {
      // The y for this center is <start> + 2 * radius * <center number>.
      centers[v+1][h+1] = new Spot(x, s + sqrt3 * radius * v).WithIndex(h+1, v+1);
      if (DEBUG) {
        println("centers["+(v+1)+"]["+(h+1)+"] = (" + 
            centers[v+1][h+1].X + ", " + centers[v+1][h+1].Y + ")");
      }
    }
  }
  
  // Calculcate the full width and height of the space that the hexes occupy.
  float fullWidth = radius/2 + (hCount-2)*3*radius/2;
  float fullHeight = (vCount-2)*radius*sqrt3 + radius*sqrt34;
  if (DEBUG) {
    println("Hexes fill:", fullWidth, "x", fullHeight);
  }
  offsetX = (width - fullWidth) / 2;
  offsetY = (height - fullHeight) / 2;
  println("Offset:", offsetX, "x", offsetY);
  xLimMin = -offsetX;
  xLimMax = xLimMin + width;
  yLimMin = -offsetY;
  yLimMax = yLimMin + height;
  if (DEBUG) {
    println("Viewable X:", xLimMin, "to", xLimMax);
    println("Viewable Y:", yLimMin, "to", yLimMax);
  }
  
  // Calculcate all of the hex vertices.
  vertexSpots = new SparseGrid<>();
  for (Spot[] spots : centers) {
    for (Spot center : spots) {
      for (CircleCrossing dir : CircleCrossing.values()) { 
        Spot v = CalculateVertexSpot(center, dir);
        if (IsVisable(v)) {
          vertexSpots.Set(v.IndexX, v.IndexY, v);
        }
      }
    }
  }
  if (DEBUG) {
    for (Spot vertex : vertexSpots.GetAll()) {
      println("vertexSpots["+vertex.IndexY+"]["+vertex.IndexX+"]: ("+vertex.X+", "+vertex.Y+")");
    }
  }
}

void draw() {
  background(0);
  translate(offsetX, offsetY);
  
  noFill();
  strokeWeight(1);
  if (drawCircles) {
    for (Spot[] spots : centers) {
      for (Spot spot : spots) {
        stroke(#FFFFFF);
        circle(spot.X, spot.Y, radius*2);
        stroke(#0000FF);
        circle(spot.X, spot.Y, 10);
      }
    }
  }
  
  stroke(#00FF00);
  if (drawVertices) {
    for (Spot vertex : vertexSpots.GetAll()) {
      circle(vertex.X, vertex.Y, 10);
    }
  }
  
  noLoop();
}

Spot CalculateVertexSpot(Spot center, CircleCrossing dir) {
  float angle = dir.Radians();
  Spot rv = new Spot(center.X + radius * cos(angle), center.Y + radius * sin(angle));
  return rv.WithIndex(int(rv.X+0.5), int(rv.Y+0.5));
}

boolean IsVisable(Spot spot) {
  return xLimMin <= spot.X && spot.X <= xLimMax 
      && yLimMin <= spot.Y && spot.Y <= yLimMax;
}
