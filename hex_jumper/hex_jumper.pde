import java.util.Collections;

Spot[][] centers;
SparseGrid<Vertex> vertexGrid;
ArrayList<Vertex> vertices;
float sqrt34, sqrt3;
float offsetX, offsetY;
int hCount, vCount;
float xLimMin, xLimMax, yLimMin, yLimMax;
Jumper[] jumpers;

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
color drawCirclesColor = #222222;
boolean drawCircleCenters = false;
color drawCircleCentersColor = #0000FF;
boolean drawVertices = true;
color drawVerticesColor = #444444;
boolean drawVertexPaths = false;
color drawVertexPathsColor = #FF0000;
float drawVertexPathsLength = 10;
float drawVerexPathsStart = 10;
float hexRadius = 80;
float vertexRadius = 10;
int changeVertexOdds = 1;
int changeRotDirOdds = 5;
int jumperCount = 60;
boolean jumperHeadFirst = false;
float headStroke = 100;
int tailLength = 17;
color[] colors = new color[]{#FFFFFF, 
  #FF0000, #0000FF, #00FF00, #FFFF00, #FF00FF, #00FFFF,
  #AA0000, #0000AA, #00AA00, #AAAA00, #AA00AA, #00AAAA,
  #FFAA00, #AAFF00, #FF00AA, #AA00FF, #00FFAA, #00AAFF,
  #000000, // Black last for easier random control.
};

void setup() {
  fullScreen();
  frameRate(15);
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
  
  // Remove any vertices that have fewer than 2 neighbors.
  for (Vertex vertex : vertexGrid.GetAll()) {
    if (vertex.Neighbors.size() < 2) {
      vertexGrid.Delete(vertex.IndexX, vertex.IndexY);
      for (CircleCrossing cc : CircleCrossing.values()) {
        Vertex other = vertex.Go(cc);
        if (other != null) {
          vertex.Neighbors.remove(cc);
          other.Neighbors.remove(cc.Opposite());
        }
      }
    }
  }

  vertices = vertexGrid.GetAll();
  Collections.sort(vertices);
  
  jumpers = new Jumper[jumperCount];
  for (int i = 0; i < jumpers.length; i++) {
    // Pick a random first color (that isn't black).
    int c1 = int(random(colors.length-1));
    // Pick a random second color by adding a random number to the first.
    int c2 = (c1 + int(random(colors.length-1)) + 1) % colors.length;
    jumpers[i] = newRandomJumper(colors[c1], colors[c2]);
  }
}

void draw() {
  background(0);
  translate(offsetX, offsetY);
  
  for (Jumper jumper : jumpers) {
    jumper.Move();
  }
  
  noFill();
  strokeWeight(1);
  if (drawCircles) {
    stroke(drawCirclesColor);
    for (Spot[] spots : centers) {
      for (Spot spot : spots) {
        circle(spot.X, spot.Y, hexRadius*2);
      }
    }
  }
  
  if (drawCircleCenters) {
    stroke(drawCircleCentersColor);
    for (Spot[] spots : centers) {
      for (Spot spot : spots) {
        circle(spot.X, spot.Y, 10);
      }
    }
  }
  
  if (drawVertices) {
    stroke(drawVerticesColor);
    for (Vertex vertex : vertices) {
      vertex.DrawBorder();
    }
  }
  
  if (drawVertexPaths) {
    stroke(drawVertexPathsColor);
    for (Vertex vertex : vertices) {
      for (CircleCrossing cc : CircleCrossing.values()) {
        Vertex other = vertex.Go(cc);
        if (other != null) {
          float angle = cc.Radians();
          float x1 = vertex.X + drawVerexPathsStart * cos(angle);
          float y1 = vertex.Y + drawVerexPathsStart * sin(angle);
          float x2 = vertex.X + (drawVerexPathsStart+drawVertexPathsLength) * cos(angle);
          float y2 = vertex.Y + (drawVerexPathsStart+drawVertexPathsLength) * sin(angle);
          line(x1, y1, x2, y2);
        }
      }
    }
  }
  
  strokeWeight(20.0);
  for (int i = 0; i < tailLength; i++) {
    for (Jumper jumper : jumpers) {
      jumper.DrawI(i);
    }
  }
}

void mousePressed() {
  if (mouseButton == LEFT) {
    noLoop();
    redraw();
  } else if (mouseButton == RIGHT) {
    loop();
  }
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

Jumper newRandomJumper(color headColor, color tailColor) {
  Vertex home = vertices.get(int(random(vertices.size())));
  return new Jumper(home, tailLength)
            .WithColor(headColor, tailColor)
            .WithCorner(RandomHexCornerRotated())
            .WithRotDir(RandomCircleDir());
}
