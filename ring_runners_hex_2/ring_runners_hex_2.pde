import gifAnimation.*;
import java.util.Map;

GifMaker gifExport;
int gifFrameLimit = 500;
int gifFrameRate = 1000/30; // 30 fps
boolean saveGif = false;

CenterSpot[][] centers;
float sqrt34;
float offsetX, offsetY;
int hCount;
int vCount;
Palette[] pals;
Tracer[] tracers;

static float PI_1_3 = PI / 3;     // lower right intersection angle.
static float PI_2_3 = PI * 2 / 3; // lower left intersection angle.
static float PI_4_3 = PI * 4 / 3; // upper left intersection angle.
static float PI_5_3 = PI * 5 / 3; // upper right inteersection angle.

boolean drawCircles = false;
color[] tracerColors = new color[]{
  #FF0000, // Red 
  #00FF00, // Green
  #FF00FF, // Magenta
  #00FFFF, // Cyan
  #FFFF00, // Yellow
  #AA00FF, // Purple
  #FFAA00, // Orange
};
color tracerColorEnd = #FFFFFF;
int tracersPerColor = 3;
int changeOdds = 2;
float radius = 40;
float speedDiv = 18.0; // Must be divisible by 6.
float tailLen = 2 * TWO_PI;
float tracerSize = 15.0;

void setup() {
  size(800, 600); //fullScreen();
  // sqrt(3/4) is important here because:
  // 1. A hex can be thought of as six equaliateral triangles.
  // 2. An equilateral triangle cut in half is a 30-60-90 triangle.
  // 3. A 30-60-90 triangle has sides 1, 1/2, and sqrt(3/4).
  // So each row of circles is 2*sqrt(3/4) * radius above the next row.
  // At the same time, each circle in each row is 2 * radius to the left of the next.
  sqrt34 = sqrt(3.0/4.0);
  
  // Taking 10 out of the width and height to ensure that there's at least some padding.
  hCount = int((width-10-radius)/(radius*2))+2;
  vCount = int((height-2*radius-10)/(sqrt34*radius*2))+3;
  centers = new CenterSpot[vCount][hCount];
  for (int v = -1; v < vCount-1; v++) {
    // The y for this row is radius + 2*sqrt(3/4)*radius*<row number>.
    float y = radius + 2 * sqrt34 * radius * v;
    // The zeroth row starts at x = radius.
    // The next row starts at x = 2 * radius (half a circle over).
    // The next row is back to starting at x = radius.
    float s = (v % 2 == 0) ? radius : 2 * radius;
    for (int h = -1; h < hCount-1; h++) {
      // The x for this circle is <start> + 2 * radius * <circle number>.
      centers[v+1][h+1] = new CenterSpot(s + 2 * radius * h, y).WithIndex(h+1, v+1);
      println("centers[" + (v+1) + "][" + (h+1) + "] = ", centers[v+1][h+1].X, centers[v+1][h+1].Y);
    }
  }
  
  // On the top circles, Most of them cannot change anywhere except lower right and lower left.
  // But in those two spots, it MUST change. Start by marking all of them as cannot change,
  // and later, we'll go through and fix them. Same with the bottom ones.
  for (int h = 0; h < hCount; h++) {
    for (CircleCrossing cc : CircleCrossing.values()) {
      for (CircleDir cd : CircleDir.values()) {
        centers[0][h].SetCannotChange(cc, cd, true).SetIsEdge(true);
        centers[vCount-1][h].SetCannotChange(cc, cd, true).SetIsEdge(true);
      }
    }
  }
  
  // Do the same for the sides.
  for (int v = 1; v < vCount-1; v++) {
    centers[v][0].SetIsEdge(true);
    centers[v][hCount-1].SetIsEdge(true);
    for (CircleCrossing cc : CircleCrossing.values()) {
      for (CircleDir cd : CircleDir.values()) {
        centers[v][0].SetCannotChange(cc, cd, true);
        centers[v][hCount-1].SetCannotChange(cc, cd, true);
      }
    }
  }
  
  // Now, fix the top and bottom ones to force a change where appropriate.
  // Also set the top and bottom inside edges to not allow changing where appropriate.
  for (int h = 0; h < hCount; h++) {
    // Start with the top ones.
    CenterSpot bl = GetNextCenter(h, 0, CircleCrossing.BottomLeft);
    CenterSpot br = GetNextCenter(h, 0, CircleCrossing.BottomRight);
    if (bl != null && br != null && !bl.IsEdge && !br.IsEdge) {
      centers[0][h].SetCannotChange(CircleCrossing.BottomLeft, CW, false)
                      .SetCannotChange(CircleCrossing.BottomLeft, CCW, false)
                      .SetMustChange(CircleCrossing.BottomLeft, true)
                      .SetCannotChange(CircleCrossing.BottomRight, CW, false)
                      .SetCannotChange(CircleCrossing.BottomRight, CCW, false)
                      .SetMustChange(CircleCrossing.BottomRight, true);
      bl.SetCannotChange(CircleCrossing.TopRight, CCW, true);
      br.SetCannotChange(CircleCrossing.TopLeft, CW, true);
    }
    if (bl != null && (br == null || br.IsEdge)) {
      bl.SetCannotChange(CircleCrossing.TopRight, CW, true)
        .SetCannotChange(CircleCrossing.TopRight, CCW, true);
    }
    if ((bl == null || bl.IsEdge) && br != null) {
      br.SetCannotChange(CircleCrossing.TopLeft, CW, true)
        .SetCannotChange(CircleCrossing.TopLeft, CCW, true);
    }
    
    // Similarly for the bottom ones.
    CenterSpot tr = GetNextCenter(h, vCount-1, CircleCrossing.TopRight);
    CenterSpot tl = GetNextCenter(h, vCount-1, CircleCrossing.TopLeft);
    if (tr != null && tl != null && !tr.IsEdge && !tl.IsEdge) {
      centers[vCount-1][h].SetCannotChange(CircleCrossing.TopRight, CW, false)
                             .SetCannotChange(CircleCrossing.TopRight, CCW, false)
                             .SetMustChange(CircleCrossing.TopRight, true)
                             .SetCannotChange(CircleCrossing.TopLeft, CW, false)
                             .SetCannotChange(CircleCrossing.TopLeft, CCW, false)
                             .SetMustChange(CircleCrossing.TopLeft, true);
      tr.SetCannotChange(CircleCrossing.BottomLeft, CCW, true);
      tl.SetCannotChange(CircleCrossing.BottomRight, CW, true);
    }
    if (tr != null && (tl == null || tl.IsEdge)) {
      tr.SetCannotChange(CircleCrossing.BottomLeft, CW, true)
        .SetCannotChange(CircleCrossing.BottomLeft, CCW, true);
    }
    if ((tr == null || tr.IsEdge) && tl != null) {
      tl.SetCannotChange(CircleCrossing.BottomRight, CW, true)
        .SetCannotChange(CircleCrossing.BottomRight, CCW, true);
    }
  }
  
  // Now, do stuff with left and right ends on the rows that are left-shifted.
  for (int v = 1; v < vCount-1; v += 2) {
    // Start with the left side.
    CenterSpot leftInnerEdge = GetNextCenter(0, v, CircleCrossing.Right);
    leftInnerEdge.SetCannotChange(CircleCrossing.Left, CW, true)
                 .SetCannotChange(CircleCrossing.Left, CCW, true)
                 .SetCannotChange(CircleCrossing.TopLeft, CCW, true)
                 .SetCannotChange(CircleCrossing.BottomLeft, CW, true);
    if (v <= vCount - 2) {
      leftInnerEdge.GetNext(CircleCrossing.BottomLeft)
                   .SetMustChange(CircleCrossing.TopRight, true)
                   .SetCannotChange(CircleCrossing.TopRight, CW, false)
                   .SetCannotChange(CircleCrossing.TopRight, CCW, false);
    }
    if (v >= 2) {
      leftInnerEdge.GetNext(CircleCrossing.TopLeft)
                   .SetMustChange(CircleCrossing.BottomRight, true)
                   .SetCannotChange(CircleCrossing.BottomRight, CW, false)
                   .SetCannotChange(CircleCrossing.BottomRight, CCW, false);
    }

    // And right side as needed.
    CenterSpot rightInnerEdge = centers[v][hCount-2];
    if (v == 1) {
      rightInnerEdge.SetCannotChange(CircleCrossing.Right, CCW, true);
      rightInnerEdge.GetNext(CircleCrossing.Right)
                    .SetMustChange(CircleCrossing.Left, true)
                    .SetCannotChange(CircleCrossing.Left, CW, false)
                    .SetCannotChange(CircleCrossing.Left, CCW, false);
    } else if (v == vCount-2) {
      rightInnerEdge.SetCannotChange(CircleCrossing.Right, CW, true);
      rightInnerEdge.GetNext(CircleCrossing.Right)
                    .SetMustChange(CircleCrossing.Left, true)
                    .SetCannotChange(CircleCrossing.Left, CW, false)
                    .SetCannotChange(CircleCrossing.Left, CCW, false);
    } else {
      rightInnerEdge.GetNext(CircleCrossing.Right)
                    .SetCannotChange(CircleCrossing.Left, CW, false)
                    .SetCannotChange(CircleCrossing.Left, CCW, false);
    }
  }
  
  // And now, stuff with the left and right ends on the rows that are right-shifted.
  for (int v = 2; v < vCount-1; v += 2) {
    // Start with the right side.
    CenterSpot rightInnerEdge = GetNextCenter(hCount-1, v, CircleCrossing.Left);
    rightInnerEdge.SetCannotChange(CircleCrossing.Right, CW, true)
                  .SetCannotChange(CircleCrossing.Right, CCW, true)
                  .SetCannotChange(CircleCrossing.TopRight, CW, true)
                  .SetCannotChange(CircleCrossing.BottomRight, CCW, true);
    if (v <= vCount - 3) {
      rightInnerEdge.GetNext(CircleCrossing.BottomRight)
                    .SetMustChange(CircleCrossing.TopLeft, true)
                    .SetCannotChange(CircleCrossing.TopLeft, CW, false)
                    .SetCannotChange(CircleCrossing.TopLeft, CCW, false);
    }
    if (v >= 2) {
      rightInnerEdge.GetNext(CircleCrossing.TopRight)
                    .SetMustChange(CircleCrossing.BottomLeft, true)
                    .SetCannotChange(CircleCrossing.BottomLeft, CW, false)
                    .SetCannotChange(CircleCrossing.BottomLeft, CCW, false);
    }

    // And right side as needed.
    CenterSpot leftInnerEdge = centers[v][1];
    if (v == 1) {
      leftInnerEdge.SetCannotChange(CircleCrossing.Left, CW, true);
      leftInnerEdge.GetNext(CircleCrossing.Left)
                   .SetMustChange(CircleCrossing.Right, true)
                   .SetCannotChange(CircleCrossing.Right, CW, false)
                   .SetCannotChange(CircleCrossing.Right, CCW, false);
    } else if (v == vCount-2) {
      leftInnerEdge.SetCannotChange(CircleCrossing.Left, CCW, true);
      leftInnerEdge.GetNext(CircleCrossing.Left)
                   .SetMustChange(CircleCrossing.Right, true)
                   .SetCannotChange(CircleCrossing.Right, CW, false)
                   .SetCannotChange(CircleCrossing.Right, CCW, false);
    } else {
      leftInnerEdge.GetNext(CircleCrossing.Left)
                   .SetCannotChange(CircleCrossing.Right, CW, false)
                   .SetCannotChange(CircleCrossing.Right, CCW, false);
    }
  }

  // Calculate the full width and height of the space that the circles occupy.
  // Each circle is 2 * radius to the left of the next.
  // Same in the row below which is offset by the radius.
  // So horizontally, we occupy <num circles> * radius * 2 + radius.
  float fullWidth = (hCount-2)*radius*2 + radius;
  // Each row is 2*sqrt(3/4) * radius above the next.
  // There's 1 * radius on both the top and bottom of that.
  // And since we've accounted for 1/2 a circle on top and 1/2 a circle on bottom,
  // we remove one from the row count.
  // So vertically, we occupy 2*radius + (<num circles>-1)*sqrt(3/4)*radius*2.
  float fullHeight = 2 * radius + (vCount-3)*sqrt34*radius*2;
  offsetX = (width - fullWidth) / 2;
  offsetY = (height - fullHeight) / 2;
  
  pals = new Palette[tracerColors.length];
  for (int i = 0; i < tracerColors.length ; i++) {
    pals[i] = new Palette(16, tracerColors[i], tracerColorEnd);
  }
  
  tracers = new Tracer[pals.length*tracersPerColor];
  for (int p = 0; p < pals.length; p++) {
    for (int i = 0; i < tracersPerColor; i++) {
      tracers[p*tracersPerColor+i] = newTracer(p);
    }
  }
  
  // Set up the gif exporter.
  if (saveGif) {
    gifExport = new GifMaker(this, "ring_runners_hex.gif");
    gifExport.setRepeat(0); // Loop forever.
    gifExport.setDelay(gifFrameRate);
  }
}

void draw() {
  background(0);
  translate(offsetX, offsetY);
  
  if (drawCircles) {
    for (CenterSpot[] spots : centers) {
      for (CenterSpot spot : spots) {
        spot.Draw();
      }
    }
  }

  for (Tracer tracer : tracers) {
    tracer.Move();
  }
  
  for (Tracer tracer : tracers) {
    tracer.Draw();
  }
  
  if (saveGif) {
    // Add this frame to the gif.
    if (frameCount <= gifFrameLimit) {
      gifExport.addFrame();
    }
    
    // Finish and save.
    if (frameCount == gifFrameLimit) {
      gifExport.finish();
      println("GIF saved!");
      exit();
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

Tracer newTracer(int palI) {
  int cx = int(random(hCount-2))+1;
  int cy = int(random(vCount-2))+1;
  while (centers[cy][cx] == null) {
    cx = int(random(hCount-2))+1;
    cy = int(random(vCount-2))+1;
  }
  
  float speed = PI/speedDiv;
  if (int(random(2)) == 0) {
    speed *= -1;
  }
  
  return new Tracer(cx, cy)
            .WithAngle(PI_1_3*(float)int(random(6)))
            .WithSpeed(speed)
            .WithStroke(tracerSize)
            .WithColor(pals[palI].Get(0).Value)
            .WithTail(tailLen, pals[palI]);
}

CenterSpot GetNextCenter(int curX, int curY, CircleCrossing cc) {
  int newX = -1;
  int newY = -1;
  switch(cc) {
  case Right:
    newX = curX+1;
    newY = curY;
    break;
  case BottomRight:
    newX = curX + (curY % 2 == 0 ? 1 : 0);
    newY = curY + 1;
    break;
  case BottomLeft:
    newX = curX - (curY % 2 == 0 ? 0 : 1);
    newY = curY + 1;
    break;
  case Left:
    newX = curX - 1;
    newY = curY;
    break;
  case TopLeft:
    newX = curX - (curY % 2 == 0 ? 0 : 1);
    newY = curY - 1;
    break;
  case TopRight:
    newX = curX + (curY % 2 == 0 ? 1 : 0);
    newY = curY - 1;
    break;
  }
  if (newX < 0 || newY < 0 || newY >= centers.length || newX >= centers[newY].length) {
    return null;
  }
  return centers[newY][newX];
}
