import java.util.Collections;

PGraphics pg;

float centerX, centerY, sunRadius, sunDiameter, sunRadiusSq, focusY, skyRadius, skyDiameter;
ArrayList<Line> lines = new ArrayList<>();
float[] dys;
float[][] dxs;
float[] leftXs;
float[] vLineCuttoffs = new float[]{-1, -0.4, 0.0, 0.333, 0.666, 1, 1.4, 2};
VLine[] vLines;
float lineDDY = 0.05;
float lineStartDY = 0.2;
int framesPerLine = 25;
float[] widths, angles;
ArrayList<Runner> runners = new ArrayList<>();
boolean mouseWasPressed = false;

Palette sunPal = new Palette(5, #FFFF00, #FF9900)    // Yellow to Orange.
         .Append(new Palette(11, #FF9900, #FF00FF))  // To Magenta.
         .Append(new Palette(11, #FF00FF, #FFFF00))  // To Yellow.
         .WithoutLast();
int framesPerSunPal = 10;
int visibleSunCols = 15;

Palette skyPal = new Palette(5, #009999, #0000AA)    // Teal to Dark Blue.
         .Append(new Palette(11, #0000AA, #AA00AA))  // To Purple.
         .Append(new Palette(11, #AA00AA, #009999))  // To Teal.
         .WithoutLast();

Palette starPal = new Palette(5, #FFFF00, #FF9900)    // Yellow to Orange.
          .Append(new Palette(11, #FF9900, #FF00FF))  // To Magenta.
          .Append(new Palette(11, #FF00FF, #FFFF00))  // To Yellow.
          .WithoutLast();
ArrayList<Star> stars = new ArrayList<>();
int starChances = 10;
int starOdds = 10;
float starSizeMax = 5;
float starSizeMin = 2;
int starLifeMax = 300;
int starLifeMin = 100;
boolean drawStars = true;

Palette grassPal = new Palette(10, #00FF00, #FFFF00) // Green to Yellow.
           .SetAlpha(50); 
ArrayList<Ground> grasses = new ArrayList<>();
float grassLeftMax, grassRightMin;
float grassCutoff = 0.37; // Percent of width on left side (mirrored for right).
int grassChances = 100;
int grassOdds = 5;
float grassSizeMax = 25;
float grassSizeMin = 10;
float grassDSize = 0.2;
boolean drawGrass = true;

Palette flowerPal = new Palette(4, #FFFF00, #FF0000) // Yellow to Red.
            .Append(new Palette(5, #FF0000, #00FFFF)); // Red to Cyan;
int flowerChances = 10;
int flowerOdds = 10;
float flowerSizeMax = 25;
float flowerSizeMin = 10;
boolean drawFlowers = true;

Palette dirtPal = new Palette(5, #995500, #CE2D00).SetAlpha(150); // Brown to dark red-orange.
ArrayList<Ground> dirts = new ArrayList<>();
float dirtLeftMin, dirtLeftMax, dirtRightMin, dirtRightMax;
float dirtCutoffMin = 0.36; // Percent of width on left side (mirrored for right).
float dirtCutoffMax = 0.42; // Percent of width on left side (mirrored for right).
int dirtChances = 50;
int dirtOdds = 5;
float dirtSizeMax = 10;
float dirtSizeMin = 5;
float dirtDSize = 0.1;
boolean drawDirt = true;

Palette runnerPal = new Palette(sunPal).Append(skyPal);
int runnerChances = 2;
int runnerOdds = 20;
int runnerLength = 20;
float runnerSizeMin = 2.0;
float runnerSizeMax = 8.0;
boolean drawRunners = true;

void setup() {
  fullScreen(P2D);
  frameRate(30);
  pg = createGraphics(width/2, height/2);
  
  centerX = pg.width/2;
  centerY = pg.height/2;
  focusY = pg.height*0.45;
  sunDiameter = 0.6 * min(pg.width, pg.height);
  sunRadius = sunDiameter / 2;
  sunRadiusSq = sunRadius * sunRadius;
  skyRadius = mag(centerX, centerY);
  skyDiameter = skyRadius*2;
  grassLeftMax = pg.width * grassCutoff;
  grassRightMin = pg.width - grassLeftMax;
  dirtLeftMin = pg.width * dirtCutoffMin;
  dirtLeftMax = pg.width * dirtCutoffMax;
  dirtRightMin = pg.width - dirtLeftMax;
  dirtRightMax = pg.width - dirtLeftMin;
  
  // Pre-calculate all the dys at each given y below the horizon.
  // index = 0 => horizon.
  dys = new float[int(pg.height-centerY)+1];
  float lineStartDYSQ = lineStartDY * lineStartDY;
  for (int y = 0; y < dys.length; y++) {
    dys[y] = lineStartDY + sqrt(lineStartDYSQ + 2 * lineDDY * y);
  }
  // and the dxs at each given (x,y) at each given y below the horizon
  // and any x from 0 to width/2. For x's on the right side of the screen
  // use the negative of the mirrored x value.
  int cols = int(centerX)+1;
  dxs = new float[dys.length][cols];
  for (int y = 0; y < dxs.length; y++) {
    float dy = dys[y];
    for (int x = 0; x < dxs[y].length; x++) {
      float dx = 0.0;
      float d = focusY - (float(y)+centerY);
      if (d != 0) {
        dx = dy * (centerX - float(x)) / d;
      }
      dxs[y][x] = dx;
    }
  }
  
  // Calculate the width of the sun at each height.
  widths = new float[int(sunRadius)+1];
  angles = new float[int(sunRadius)+1];
  for (float i = 0; i <= sunRadius; i++) {
    float dy = i - sunRadius;
    widths[int(i)] = 4 * sqrt(sunRadiusSq - dy*dy);
    if (!Float.isNaN(widths[int(i)])) {
      angles[int(i)] = atan2(i - sunRadius, widths[int(i)]/2);
    } else {
      angles[int(i)] = Float.NaN;
    }
  }
  
  // Calculcate the left-most point that the horizontal lines will have.
  // This gets mirrored on the right.
  // This dictates the width of the horizontal line at the given distance
  // below the horizon.
  leftXs = new float[pg.height-int(centerY)+1];
  for (float i = 0; i <= centerY; i++) {
    float xa = pg.width*vLineCuttoffs[0];
    float ya = pg.height;
    float xb = centerX;
    float yb = focusY;
    float m = (yb - ya) / (xb - xa);
    float x = xa + (i+centerY - ya) / m;
    leftXs[int(i)] = x >= 0 ? x : 0;
  }
  
  // Calculate all the VLines.
  vLines = new VLine[vLineCuttoffs.length];
  for (int i = 0; i < vLineCuttoffs.length; i++) {
    float x1 = pg.width * vLineCuttoffs[i];
    float y1 = pg.height;
    float x3 = centerX;
    float y3 = focusY;
    float y2 = centerY+1;
    float x2 = x3; // In case x1 == x3 (undefined slope)
    if (x1 != x3) {
      float m = (y3 - y1) / (x3 - x1);
      x2 = x1 + (y2 - y1) / m;
    }
    vLines[i] = new VLine(x1, y1, x2, y2);
  }
}

void draw() {
  pg.beginDraw();
  pg.background(0);
  
  // Rotate the gradients every few frames.
  if (frameCount % framesPerSunPal == 0) {
    sunPal.RotateRight();
    skyPal.RotateLeft();
  }
  
  // Accelerate all the lines a little bit, and move them.
  for (Line line : lines) {
    line.Accelerate(lineDDY).Move();
  }
  
  // Remove any lines that are too far down now.
  for (int i = lines.size()-1; i >= 0; i--) {
    if (lines.get(i).Y > pg.height) {
      lines.remove(i);
    }
  }
  
  // Add a new line every few frames.
  if (frameCount % framesPerLine == 1) {
    lines.add(new Line(centerY).WithVelocity(lineStartDY));
  }
  
  // Age all the stars.
  for (Star star : stars) {
    star.Age();
  }
  
  // Clean out dead stars.
  for (int i = stars.size()-1; i >= 0; i--) {
    if (stars.get(i).IsDead()) {
      stars.remove(i);
    }
  }
  
  if (drawStars) {
    // Add new stars?
    for (int i = 0; i < starChances; i++) {
      if (int(random(starOdds)) == 0) {
        float size = random(starSizeMin, starSizeMax);
        stars.add(new Star(
          random(pg.width), random(centerY-size),
          size,
          starPal.Random().Value,
          int(random(starLifeMin, starLifeMax))
        ));
      }
    }
  }
  
  // Accelerate and move all the grasses.
  for (Ground grass : grasses) {
    int y = int(grass.Y-centerY);
    int x = int(grass.X);
    int m = 1;
    if (grass.X > centerX) {
      x = int(pg.width - grass.X);
      m = -1;
    }
    // If it's inside the pre-calculated window, update the velocity.
    // Otherwise, just leave it as it was as it moves off screen.
    if (x >= 0 && x < dxs[y].length) {
      grass.WithVelocity(m*dxs[y][x], dys[y]);
    }
    grass.Move();
    grass.Size += grassDSize;
  }
  
  // Clean out dead grass.
  for (int i = grasses.size()-1; i >= 0; i--) {
    if (grasses.get(i).IsDead()) {
      grasses.remove(i);
    }
  }
  
  if (drawGrass) {
    // Add new grasses.
    for (int i = 0; i < grassChances; i++) {
      if (int(random(grassOdds)) == 0) {
        float size = random(grassSizeMin, grassSizeMax);
        float x = random(0, grassLeftMax - size/2);
        if (int(random(2)) == 0) {
          x = pg.width - x;
        }
        grasses.add(new Ground(x, centerY, size, grassPal.Random().Value));
      }
    }
  }
 
  
  if (drawFlowers) {
    // Add new grasses.
    for (int i = 0; i < flowerChances; i++) {
      if (int(random(flowerOdds)) == 0) {
        float size = random(flowerSizeMin, flowerSizeMax);
        float x = random(0, grassLeftMax - size/2);
        if (int(random(2)) == 0) {
          x = pg.width - x;
        }
        grasses.add(new Ground(x, centerY, size, flowerPal.Random().Value));
      }
    }
  }
  
  // Accelerate and move all the dirts.
  for (Ground dirt : dirts) {
    int y = int(dirt.Y-centerY);
    int x = int(dirt.X);
    int m = 1;
    if (dirt.X > centerX) {
      x = int(pg.width - dirt.X);
      m = -1;
    }
    // If it's inside the pre-calculated window, update the velocity.
    // Otherwise, just leave it as it was as it moves off screen.
    if (x >= 0 && x < dxs[y].length) {
      dirt.WithVelocity(m*dxs[y][x], dys[y]);
    }
    dirt.Move();
    dirt.Size += dirtDSize;
  }
  
  // Clean out dead dirt.
  for (int i = dirts.size()-1; i >= 0; i--) {
    if (dirts.get(i).IsDead()) {
      dirts.remove(i);
    }
  }
  
  if (drawDirt) {
    // Add new dirts.
    for (int i = 0; i < dirtChances; i++) {
      if (int(random(dirtOdds)) == 0) {
        float size = random(dirtSizeMin, dirtSizeMax);
        float x = random(dirtLeftMin, dirtLeftMax);
        if (int(random(2)) == 0) {
          x = pg.width - x;
        }
        dirts.add(new Ground(x, centerY, size, dirtPal.Random().Value));
      }
    }
  }
  
  // Move all the runners.
  for (Runner runner : runners) {
    runner.Move();
  }

  // Clean out dead runners.
  for (int i = runners.size()-1; i >= 0; i--) {
    if (runners.get(i).IsDead()) {
      runners.remove(i);
    }
  }
  
  if (drawRunners) {
    // Add new runners.
    for (int i = 0; i < runnerChances; i++) {
      if (mouseWasPressed || int(random(runnerOdds)) == 0) {
        float x = random(vLines[1].X1, vLines[vLines.length-2].X1);
        float y = pg.height;
        float speed = 1.0;
        if (x < 0) {
          y = pg.height + ((focusY - pg.height) / (centerX - x)) * (-x);
          x = 0;
          speed = 3.0;
        } else if (x > pg.width) {
          y = pg.height + ((focusY - pg.height) / (centerX - x)) * (pg.width - x);
          x = pg.width;
          speed = 3.0;
        }
        runners.add(new Runner(x, y, runnerPal.Random().Value, runnerLength)
                       .WithSize(runnerSizeMin, runnerSizeMax)
                       .WithSpeed(speed));
        mouseWasPressed = false;
      }
    }
  }
  
  // Pre-calc the sun and sky's color indexes.
  int[] colIsR = new int[int(sunRadius)+1]; // color indexes to use if the palette is shifting right.
  int[] colIsL = new int[int(sunRadius)+1]; // color indexes to use if the palette is shifting left.
  for (float i = 0; i <= sunRadius; i++) {
    float colI = map(i, 0, sunRadius, 0, visibleSunCols)           // Main portion of index.
                +map(i%framesPerSunPal, 0, framesPerSunPal, 0, 1); // Fuzz/blend the colors a little bit.
    colIsR[int(i)] = int(colI + map(frameCount%framesPerSunPal, 0, framesPerSunPal, 1, 0)); // Smooth out the rotation.
    colIsL[int(i)] = int(colI + map(frameCount%framesPerSunPal, 0, framesPerSunPal, 0, 1)); // Smooth out the rotation.
  }
  
  // Draw the sky (before the sun and stars).
  pg.noStroke();
  for (float i = sunRadius; i >= 0; i -= 1) {
    float angle = angles[int(i)];
    if (!Float.isNaN(angle)) {
      pg.fill(skyPal.Get(colIsL[int(i)]).Value);
      // The angle is 0 at i = sunRadius, and -PI/2 at i = 0.
      pg.arc(centerX, centerY, skyDiameter, skyDiameter, PI-angle, TWO_PI+angle);
    }
  }

  // Draw the stars before the sun (to hide the ones behind the sun).
  for (Star star : stars) {
    star.Draw();
  }
  
  // Draw a black box on the bottom half to chop off any stars that dip below the horizon.
  pg.noStroke();
  pg.fill(0);
  pg.rect(0, centerY+1, pg.width, pg.height-centerY);
  // Draw a black half-circle where the sun goes because for some reason,
  // in fullscreen, the stars behind the sun show through (and this fixes that).
  pg.arc(centerX, centerY, sunDiameter-1, sunDiameter-1, PI, TWO_PI);
  
  // Draw the sun.
  pg.noStroke();
  for (float i = 0; i <= sunRadius; i++) {
    float w = widths[int(i)]/2;
    if (!Float.isNaN(w)) {
      pg.fill(sunPal.Get(colIsR[int(i)]).Value);
      pg.rect(centerX - w/2, centerY - sunRadius + i, w, 1);
    }
  }
  
  // Draw the dirt.
  Collections.sort(dirts);
  for (Ground dirt : dirts) {
    dirt.Draw();
  }
  
  // Draw the grass.
  Collections.sort(grasses);
  for (Ground grass : grasses) {
    grass.Draw();
  }
  
  // Draw the horizon line.
  pg.noFill();
  pg.stroke(#FFFFFF);
  pg.strokeWeight(1.0);
  //pg.arc(centerX, centerY, sunDiameter, sunDiameter, PI, TWO_PI);
  pg.line(0, centerY, pg.width, centerY);
  
  // Draw the vertical lines.
  pg.noFill();
  pg.stroke(#FFFFFF);
  pg.strokeWeight(1.0);
  for (VLine vLine : vLines) {
    vLine.Draw();
  }
  
  // Draw the advancing horizontal lines.
  for (Line line : lines) {
    float x = leftXs[int(line.Y-centerY)];
    pg.line(x, line.Y, pg.width-x, line.Y);
  }
  
  // Draw the runners.
  for (Runner runner : runners) {
    runner.Draw(sunPal.Get(colIsR[colIsR.length-1]).Value);
  }
  
  pg.endDraw();
  image(pg, 0, 0, width, height);
}

void mousePressed() {
  mouseWasPressed = true;
}
