import java.util.Collections;
import java.util.Arrays;

Spot[][] centers;
SparseGrid<Vertex> vertexGrid;
SparseGrid<Vertex> centerGrid;
SparseGrid<VertexDot> dotGrid;
ArrayList<Vertex> vertices;
ArrayList<Vertex> centerVertices;
color[][] dropletGradients;
HashMap<Integer, Integer> dropletGradientIndexMap;
int[] dropletFrameCounts;
color[] colors;
float offsetX, offsetY;
int hCount, vCount;
float xLimMin, xLimMax, yLimMin, yLimMax;
Crawler[] crawlers;
ArrayList<Droplet> droplets;
int vertexDotBorderColorIdx, vertexDotBorderColorFramesLeft;

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

boolean DEBUG = false;
boolean OUTPUT_FPS = false;

float hexRadius = 85;
int centerRadiusMin = 1;
int centerRadiusMax = 45;
int dropletRadiusMin = 5;
int dropletRadiusMax = 54;
int dropletAlphaStart = 255;
int dropletAlphaStop = 10;
int dropletMaxFrames = 5;
float crawlerWeightHead = 15;
float crawlerWeightTail = 5;
float crawlerSpeed = 5;
int crawlersPerColor = 2;
int vertexDotRadius = 8;
float vertexDotBorderWeight = 1.5;
color vertexDotFillColor = #FFFFFF;
int vertexDotFramesPerColor = 5;

int colorsBetweenBases = 1;
color[] baseColors = new color[]{
  #FF0000, // Red
  #FFFF00, // Yellow
  #00FF00, // Green
  #00FFFF, // Cyan
  #0000FF, // Blue
  #FF00FF, // Magenta
};
boolean loopBaseColors = true;

int vertexDotFramesPerAlpha = 3;
int[] vertexDotAlphaGradient = new int[]{0, 50, 101, 153, 204, 255};

boolean drawCircles = false;
color drawCirclesColor = #FFFFFF;

boolean drawCircleCenters = false;
float drawCircleCentersRadius = 3;
color drawCircleCentersColor = #444444;

boolean drawVertices = false;
float drawVerticesRadius = 2;
color drawVerticesColor = #AAAAAA;
color drawVerticesFill = #AAAAAA;

boolean drawVertexPaths = false;
color drawVertexPathsColor = #FF00AA;
float drawVertexPathsLength = 6;
float drawVertexPathsStart = 5;

boolean drawOtherPaths = false;
color drawOtherPathsColor = #00FF00;
float drawOtherPathsLength = 6;
float drawOtherPathsStart = 5;

boolean drawVertexHexes = false;
color drawVertexHexesFill = setAlpha(#FF0000, 75);
color drawVertexHexesBorder = #FF0000;

boolean drawVertexHexesMin = false;
color drawVertexHexesMinColor = #FF0000;

boolean drawVertexHexesMax = false;
color drawVertexHexesMaxColor = #AA0000;

boolean drawCenterHexes = false;
color drawCenterHexesFill = setAlpha(#00FF00, 75);
color drawCenterHexesBorder = #00FF00;

boolean drawCenterHexesMin = false;
color drawCenterHexesMinColor = #0000FF;

boolean drawCenterHexesMax = false;
color drawCenterHexesMaxColor = #333333;

boolean drawCrawlers = true;
boolean drawDroplets = true;
boolean drawDotGrid = true;

void setup() {
  fullScreen();
  frameRate(30);
  
  // sqrt(3/4) is important here because:
  // 1. A hex can be thought of as six equaliateral triangles.
  // 2. An equilateral triangle cut in half is a 30-60-90 triangle.
  // 3. A 30-60-90 triangle has sides 1, 1/2, and sqrt(3/4).
  float sqrt34 = sqrt(3.0/4.0);
  float sqrt3 = sqrt(3.0);
  
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
  if (DEBUG) {
    println("Offset:", offsetX, "x", offsetY);
  }
  xLimMin = -offsetX;
  xLimMax = xLimMin + width;
  yLimMin = -offsetY;
  yLimMax = yLimMin + height;
  if (DEBUG) {
    println("Viewable X:", xLimMin, "to", xLimMax);
    println("Viewable Y:", yLimMin, "to", yLimMax);
  }
  
  // Populate the vertex grid with all the spots.
  vertexGrid = new SparseGrid<Vertex>();
  centerGrid = new SparseGrid<Vertex>();
  for (int i = 0; i < centers.length; i++) {
    for (int j = 0; j < centers[i].length; j++) {
      Spot center = centers[i][j];
      // Only keep vertices on circles where all vertices are visible.
      HashMap<CircleCrossing, Spot> neighbors = new HashMap<CircleCrossing, Spot>();
      for (CircleCrossing cc : CircleCrossing.values()) {
        Spot corner = CalculateVertexSpot(center, cc);
        if (!IsVisable(corner)) {
          neighbors = null;
          break;
        }
        neighbors.put(cc, corner);
      }
      if (neighbors == null) {
        continue;
      }
      
      for (CircleCrossing cc : CircleCrossing.values()) {
        Spot s = neighbors.get(cc);
        if (!vertexGrid.Has(s)) {
          vertexGrid.Set(s, new Vertex(s));
        }
      }
      
      centerGrid.Set(center, new Vertex(center));
    }
  }

  vertices = vertexGrid.GetAll();
  Collections.sort(vertices);
  
  if (DEBUG) {
    println("There are", vertices.size(), "vertices");
    for (Vertex v : vertices) {
      println("vertexGrid[" + v.IndexY + "][" + v.IndexX + "] = (" + v.X + ", " + v.Y + ")");
    }
  }
  
  centerVertices = centerGrid.GetAll();
  Collections.sort(centerVertices);
  
  if (DEBUG) {
    println("There are", centerVertices.size(), "centers");
    for (Vertex v : centerVertices) {
      println("centerGrid[" + v.IndexY + "][" + v.IndexX + "] = (" + v.X + ", " + v.Y + ")");
    }
  }
  
  // Wire all the vertices together.
  for (Vertex v : vertices) {
    Spot focus = v.AsSpot();
    for (CircleCrossing cc : CircleCrossing.values()) {
      Spot neighborSpot = CalculateVertexSpot(focus, cc);
      Vertex neighbor = vertexGrid.Get(neighborSpot);
      if (neighbor != null) {
        v.WithNeighbor(cc, neighbor);
      }
    }
  }
  
  // Wire the centers to all the vertices, and vice versa.
  for (Vertex center : centerVertices) {
    Spot centerSpot = center.AsSpot();
    for (CircleCrossing cc : CircleCrossing.values()) {
      Spot s = CalculateVertexSpot(centerSpot, cc);
      Vertex v = vertexGrid.Get(s);
      center.WithOther(cc, v);
      v.WithOther(cc.Opposite(), center);
    }
  }
  
  // Pre-calc all the hexes around the vertices.
  int vertexRadiusMin = min(dropletRadiusMin, vertexDotRadius);
  for (Vertex v : vertices) {
    v.WithCorners(vertexRadiusMin, dropletRadiusMax);
  }
  for (Vertex v : centerVertices) {
    v.WithCorners(centerRadiusMin, centerRadiusMax);
  }
  
  // Define the actual colors that will be used.
  if (loopBaseColors) {
    colors = new color[baseColors.length*(colorsBetweenBases + 1)];
    int idx = 0;
    for (int c = 0; c < baseColors.length; c++) {
      color c1 = baseColors[c];
      color c2 = baseColors[(c+1) % baseColors.length];
      colors[idx++] = c1;
      for (int n = 1; n <= colorsBetweenBases; n++) {
        colors[idx++] = lerpColor(c1, c2, (float)n / (colorsBetweenBases+1));
      }
    }
  } else {
    colors = new color[baseColors.length+(baseColors.length-1)*colorsBetweenBases];
    int idx = 0;
    for (int c = 0; c < baseColors.length - 1; c++) {
      color c1 = baseColors[c];
      color c2 = baseColors[c+1];
      colors[idx++] = c1;
      for (int n = 1; n <= colorsBetweenBases; n++) {
        colors[idx++] = lerpColor(c1, c2, (float)n/(colorsBetweenBases+1));
      }
    }
    colors[idx] = baseColors[baseColors.length-1];
  }
  
  if (DEBUG) {
    println("There are", colors.length, "colors");
    for (int i = 0; i < colors.length; i++) {
      println("colors[" + i + "] = " + hex(colors[i]));
    }
  }
  
  vertexDotBorderColorIdx = 0;
  vertexDotBorderColorFramesLeft = vertexDotFramesPerColor;
  
  // Pre-calc all the gradients that the droplets will use.
  droplets = new ArrayList<Droplet>();
  int radCount = dropletRadiusMax - dropletRadiusMin + 1;
  dropletGradients = new color[colors.length][radCount];
  dropletGradientIndexMap = new HashMap<Integer, Integer>();
  for (int c = 0; c < colors.length; c++) {
    dropletGradientIndexMap.put(colors[c], c); 
    for (int r = 0; r < radCount; r++) {
      int alpha = int(map(r, 0, radCount-1, dropletAlphaStart, dropletAlphaStop));
      dropletGradients[c][r] = setAlpha(colors[c], alpha);
    }
  }
  dropletFrameCounts = new int[radCount];
  for (int r = 0; r < radCount; r++) {
    dropletFrameCounts[r] = int(map(r, 0, radCount-1, 1, dropletMaxFrames));
  }
  
  // Create the initial dot grid.
  dotGrid = new SparseGrid<VertexDot>();
  for (Vertex vertex : vertices) {
    dotGrid.Set(vertex, new VertexDot(vertex).FullyOn());
  }
  
  // Now create the crawlers.
  crawlers = new Crawler[colors.length*crawlersPerColor];
  for (int n = 0; n < crawlersPerColor; n++) {
    for (int c = 0; c < colors.length; c++) {
      Crawler crawler = NewRandomCrawler(colors[c]);
      crawlers[n*colors.length+c] = crawler;
      dotGrid.Delete(crawler.Head);
      dotGrid.Delete(crawler.Tail);
    }
  }
}

void draw() {
  background(0);
  translate(offsetX, offsetY);
  
  vertexDotBorderColorFramesLeft--;
  if (vertexDotBorderColorFramesLeft <= 0) {
    vertexDotBorderColorFramesLeft = vertexDotFramesPerColor;
    vertexDotBorderColorIdx++;
    if (vertexDotBorderColorIdx >= colors.length) {
      vertexDotBorderColorIdx = 0;
    }
  }
  
  for (VertexDot vd : dotGrid.GetAll()) {
    vd.Move();
  }

  for (Droplet droplet : droplets) {
    droplet.Move();
  }
  
  for (int i = droplets.size()-1; i >= 0; i--) {
    if (droplets.get(i).IsDone()) {
      if (drawDotGrid) {
        Vertex home = droplets.get(i).Home;
        dotGrid.Set(home, new VertexDot(home));
      }
      droplets.remove(i);
    }
  }
  
  // Everwhere where there's still a droplet, there shouldn't be a vertex dot.
  for (Droplet droplet : droplets) {
    dotGrid.Delete(droplet.Home);
  }
  
  for (Crawler crawler : crawlers) {
    Droplet droplet = crawler.Move();
    if (droplet != null && drawDroplets) {
      droplets.add(droplet);
      dotGrid.Delete(droplet.Home);
    }
    dotGrid.Delete(crawler.Head);
    dotGrid.Delete(crawler.Tail);
  }

  noFill();
  strokeWeight(1);
  
  if (drawCircles) {
    stroke(drawCirclesColor);
    for (Vertex center : centerVertices) {
      circle(center.X, center.Y, hexRadius*2);
    }
  }
  
  if (drawCircleCenters) {
    stroke(drawCircleCentersColor);
    for (Vertex center: centerVertices) {
      circle(center.X, center.Y, drawCircleCentersRadius*2);
    }
  }
  
  if (drawCenterHexes) {
    stroke(drawCenterHexesBorder);
    fill(drawCenterHexesFill);
    for (Vertex v : centerVertices) {
      v.Draw();
    }
    noFill();
  }
  
  if (drawCenterHexesMin) {
    stroke(drawCenterHexesMinColor);
    for (Vertex v : centerVertices) {
      v.DrawBorder(centerRadiusMin);
    }
  }

  if (drawCenterHexesMax) {
    stroke(drawCenterHexesMaxColor);
    for (Vertex v : centerVertices) {
      v.DrawBorder(centerRadiusMax);
    }
  }
  
  if (drawVertexHexes) {
    stroke(drawVertexHexesBorder);
    fill(drawVertexHexesFill);
    for (Vertex v : vertices) {
      v.Draw();
    }
    noFill();
  }
  
  if (drawVertexHexesMin) {
    stroke(drawVertexHexesMinColor);
    for (Vertex v : vertices) {
      v.DrawBorder(dropletRadiusMin);
    }
  }
  
  if (drawVertexHexesMax) {
    stroke(drawVertexHexesMaxColor);
    for (Vertex v : vertices) {
      v.DrawBorder(dropletRadiusMax);
    }
  }
  
  if (drawVertices) {
    stroke(drawVerticesColor);
    fill(drawVerticesFill);
    for (Vertex vertex : vertices) {
      circle(vertex.X, vertex.Y, drawVerticesRadius*2);
    }
    noFill();
  }
  
  if (drawVertexPaths) {
    stroke(drawVertexPathsColor);
    drawPaths(vertices, drawVertexPathsStart, drawVertexPathsLength, new VertexGetter() {
      Vertex get(Vertex v, CircleCrossing cc) {
        return v.Go(cc);
      }
    });
  }
  
  if (drawOtherPaths) {
    stroke(drawOtherPathsColor);
    VertexGetter vg = new VertexGetter() {
      Vertex get(Vertex v, CircleCrossing cc) {
        return v.GetOther(cc);
      }
    };
    drawPaths(vertices, drawOtherPathsStart, drawOtherPathsLength, vg);
    drawPaths(centerVertices, drawOtherPathsStart, drawOtherPathsLength, vg);
  }
  
  if (drawDotGrid) {
    for (VertexDot vd : dotGrid.GetAll()) {
      vd.Draw();
    }
  }
  
  for (Droplet droplet : droplets) {
    droplet.Draw();
  }
  
  if (drawCrawlers) {
    for (Crawler crawler : crawlers) {
      crawler.Draw();
    }
  }
  
  if (OUTPUT_FPS) {
    println("FPS:", frameRate);
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

Spot CalculateRadialSpot(float x, float y, float angle, float radius) {
  return new Spot(x + radius * cos(angle), y + radius * sin(angle));
}

Spot CalculateRadialSpot(Vertex v, CircleCrossing dir, float radius) {
  return CalculateRadialSpot(v.X, v.Y, dir.Radians(), radius);
}

Spot CalculateVertexSpot(Spot center, CircleCrossing dir) {
  Spot rv = CalculateRadialSpot(center.X, center.Y, dir.Radians(), hexRadius);
  return rv.WithIndex(indexVal(rv.X), indexVal(rv.Y));
}

boolean IsVisable(Spot spot) {
  return xLimMin <= spot.X && spot.X <= xLimMax 
      && yLimMin <= spot.Y && spot.Y <= yLimMax;
}

color setAlpha(color col, int alpha) {
  return (col & 0x00FFFFFF) | ((alpha & 0xFF) << 24);
}

int indexVal(float val) {
  // If it's roughly x.5, round up.
  if (roughlyEqual(val - float(int(val)), 0.5)) {
    return int(val+1.0);
  }
  // Otherwise, round to the nearest.
  return int(val+0.5);
}

boolean roughlyEqual(float x, float y) {
  return abs(x - y) < 0.001;
}

color[] GetDropletGradient(color col) {
  Integer i = dropletGradientIndexMap.get(col);
  if (i == null) {
    return null;
  }
  return dropletGradients[i];
}

interface VertexGetter {
  Vertex get(Vertex v, CircleCrossing cc);
}

void drawPaths(ArrayList<Vertex> vs, float pathStart, float pathLength, VertexGetter getter) {
  for (Vertex vertex : vs) {
    for (CircleCrossing cc : CircleCrossing.values()) {
      Vertex other = getter.get(vertex, cc);
      if (other != null) {
        float angle = cc.Radians();
        float x1 = vertex.X + pathStart * cos(angle);
        float y1 = vertex.Y + pathStart * sin(angle);
        float x2 = vertex.X + (pathStart+pathLength) * cos(angle);
        float y2 = vertex.Y + (pathStart+pathLength) * sin(angle);
        line(x1, y1, x2, y2);
      }
    }
  }
}

Crawler NewRandomCrawler(color tailColor) {
  Vertex head = vertices.get(int(random(vertices.size())));
  CircleCrossing headDir = head.RandomNeighborDir();
  float headLen = random(hexRadius);
  CircleCrossing headToTail = head.RandomNeighborDir(headDir);
  Vertex tail = head.Go(headToTail);
  CircleCrossing tailDir = tail.RandomNeighborDir(headToTail.Opposite());
  float tailLen = hexRadius - headLen;
  return new Crawler()
           .WithColor(#FFFFFF, tailColor, 16)
           .WithHead(head, headDir, headLen)
           .WithTail(headToTail, tail, tailDir, tailLen);
}
