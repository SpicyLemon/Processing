import java.util.Collections;

Spot[][] centers;
SparseGrid<Vertex> vertexGrid;
ArrayList<Vertex> vertices;
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
boolean drawCircles = false;
boolean drawVertices = true;
boolean drawVertexPaths = true;
float hexRadius = 70;
float vertexRadius = 10;

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
  hCount = int((2.0*(width-10)-hexRadius)/(3.0*hexRadius))+2;
  vCount = int((height-10-sqrt34*hexRadius)/(sqrt3*hexRadius))+2;
  if (DEBUG) {
    println("Dimensions:", hCount, "x", vCount);
  }
  centers = new Spot[vCount][hCount];
  for (int h = -1; h < hCount-1; h++) {
    float x = hexRadius + hexRadius * 3 / 2 * h;
    float s = (h % 2 == 0) ? sqrt34*hexRadius : sqrt3 * hexRadius;
    for (int v = -1; v < vCount-1; v++) {
      // The y for this center is <start> + 2 * hexRadius * <center number>.
      centers[v+1][h+1] = new Spot(x, s + sqrt3 * hexRadius * v).WithIndex(h+1, v+1);
      if (DEBUG) {
        println("centers["+(v+1)+"]["+(h+1)+"] = (" + 
            centers[v+1][h+1].X + ", " + centers[v+1][h+1].Y + ")");
      }
    }
  }
  
  // Calculcate the full width and height of the space that the hexes occupy.
  float fullWidth = hexRadius/2 + (hCount-2)*3*hexRadius/2;
  float fullHeight = (vCount-2)*hexRadius*sqrt3 + hexRadius*sqrt34;
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
  vertexGrid = new SparseGrid<>();
  for (Spot[] spots : centers) {
    for (Spot center : spots) {
      for (CircleCrossing dir : CircleCrossing.values()) { 
        Spot s = CalculateVertexSpot(center, dir);
        if (IsVisable(s)) {
          vertexGrid.Set(s.IndexX, s.IndexY, new Vertex(s));
        }
      }
    }
  }
  if (DEBUG) {
    for (Vertex vertex : vertexGrid.GetAll()) {
      println("vertexGrid["+vertex.IndexY+"]["+vertex.IndexX+"]: ("+vertex.X+", "+vertex.Y+")");
    }
  }
  
  // Wire all the Vertices together.
  for (Integer y : vertexGrid.GetYs()) {
    for (Integer x : vertexGrid.GetXs(y)) {
      Vertex primary = vertexGrid.Get(x, y);
      Spot pSpot = primary.AsSpot();
      for (CircleCrossing cc : CircleCrossing.values()) {
        Spot oSpot = CalculateVertexSpot(pSpot, cc);
        Vertex other = vertexGrid.Get(int(oSpot.X+0.5), int(oSpot.Y+0.5));
        if (other != null) {
          primary.WithNeighbor(cc, other);
          other.WithNeighbor(cc.Opposite(), primary);
        }
      }
    }
  }
  
  vertices = vertexGrid.GetAll();
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
        circle(spot.X, spot.Y, hexRadius*2);
        stroke(#0000FF);
        circle(spot.X, spot.Y, 10);
      }
    }
  }
  
  if (drawVertices) {
    stroke(#00FF00);
    for (Vertex vertex : vertices) {
      vertex.DrawBorder();
    }
  }
  
  if (drawVertexPaths) {
    stroke(#FF0000);
    for (Vertex vertex : vertices) {
      for (CircleCrossing cc : CircleCrossing.values()) {
        Vertex other = vertex.Go(cc);
        if (other != null) {
          float angle = cc.Radians();
          float x1 = vertex.X + 10 * cos(angle);
          float y1 = vertex.Y + 10 * sin(angle);
          float x2 = vertex.X + 20 * cos(angle);
          float y2 = vertex.Y + 20 * sin(angle);
          line(x1, y1, x2, y2);
        }
      }
    }
  }
  
  noLoop();
}

Spot CalculateVertexSpot(Spot center, CircleCrossing dir) {
  Spot rv = CalculateRadialSpot(center.X, center.Y, dir.Radians(), hexRadius);
  return rv.WithIndex(int(rv.X+0.5), int(rv.Y+0.5));
}

Spot CalculateRadialSpot(float x, float y, float angle, float radius) {
  return new Spot(x + radius * cos(angle), y + radius * sin(angle));
}

boolean IsVisable(Spot spot) {
  return xLimMin <= spot.X && spot.X <= xLimMax 
      && yLimMin <= spot.Y && spot.Y <= yLimMax;
}
