import gifAnimation.*;

GifMaker gifExport;
int gifFrameLimit = 1000;
int gifFrameRate = 1000/30; // 30 fps
boolean saveGif = false;

Palette pal1;
Palette pal2;
int frameCounter = 0;
int hCount;
int vCount;
float squareLeft;
float squareTop;
int squareSize;

boolean doScale, doRot, doTrans;
float scaleCenX, scaleCenY, scaleTarget;
float rotCenX, rotCenY, rotTarget;
float transTargetX, transTargetY;

boolean debug = false;

int framesToChange = 900;
float maxScaleOffset = 0.2;
float maxRotOffset = 0.05;
float maxTransOffset = 25;

int oddsToScale = 3;
int oddsToRot = 3;
int oddsToTrans = 3;

color[] colors = new color[]{#000000, #FFFFFF, 
  #FF0000, #0000FF, #00FF00, #FFFF00, #FF00FF, #00FFFF,
  #AA0000, #0000AA, #00AA00, #AAAA00, #AA00AA, #00AAAA,
  #FFAA00, #AAFF00, #FF00AA, #AA00FF, #00FFAA, #00AAFF,
};

void setup() {
  fullScreen();
  frameRate(30);
  setVals();
  setPals();
  
  // Set up the gif exporter.
  if (saveGif) {
    gifExport = new GifMaker(this, "trippy-squares.gif");
    gifExport.setRepeat(0); // Loop forever.
    gifExport.setDelay(gifFrameRate);
    framesToChange = 200;
  }
}

void draw() {
  frameCounter++;
  
  if (frameCounter >= framesToChange) {
    frameCounter = 0;
    setVals();
    setPals();
  }

  float p1SquareThickness = squareSize/pal1.Size()/2;
  float p2SquareThickness = squareSize/pal2.Size()/2;
  
  if (doScale) {
    translate(scaleCenX, scaleCenY);
    float zoom = map(frameCounter, 0, framesToChange, 1, scaleTarget);
    scale(zoom);
    translate(-scaleCenX, -scaleCenY);
  }
  
  if (doRot) {
    translate(rotCenX, rotCenY);
    float angle;
    if (frameCounter < framesToChange/2) {
      angle = map(frameCounter, 0, framesToChange/2, 0, rotTarget);
    } else {
      angle = map(frameCounter, framesToChange/2, framesToChange, rotTarget, 0);
    }
    rotate(angle);
    translate(-rotCenX, -rotCenY);
  }
  
  if (doTrans) {
    float tx = map(frameCounter, 0, framesToChange, 0, transTargetX);
    float ty = map(frameCounter, 0, framesToChange, 0, transTargetY);
    translate(tx, ty);
  }
  
  noStroke();
  for (int i = 0; i < pal1.Size(); i++) {
    float d = p1SquareThickness*i; 
    fill(pal1.Get(i).Value);
    for (int x = 0; x < hCount; x++) {
      for (int y = 0; y < vCount; y++) {
        if ((x+y) % 2 == 0) {
          square(squareLeft+d+squareSize*x, squareTop+d+squareSize*y, squareSize-d*2);
        }
      }
    }
  }
  
  for (int i = 0; i < pal2.Size(); i++) {
    float d = p2SquareThickness*i; 
    fill(pal2.Get(i).Value);
    for (int x = 0; x < hCount; x++) {
      for (int y = 0; y < vCount; y++) {
        if ((x+y) % 2 != 0) {
          square(squareLeft+d+squareSize*x, squareTop+d+squareSize*y, squareSize-d*2);
        }
      }
    }
  }

  pal1.RotateRight();
  pal2.RotateLeft();
  
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

void setPals() {
  int c1i = int(random(colors.length));
  int c2i = int(random(colors.length));
  while (c1i == c2i) {
    c2i = int(random(colors.length));
  }
  
  pal1 = new Palette(10, colors[c1i], colors[c2i]).Append(new Palette(11, colors[c2i], colors[c1i]));
  pal2 = new Palette(pal1);  
}

void setVals() {
  squareSize = int(random(height/4))+50;
  hCount = (int)(width/squareSize)+4;
  vCount = (int)(height/squareSize)+4;
  squareLeft = (width-squareSize*(hCount-2))/2-squareSize;
  squareTop = (height-squareSize*(vCount-2))/2-squareSize;
  
  if (debug) {
    println("New vals:", squareSize, " = ", vCount, "x", hCount);
  }
  if (oddsToScale > 0) {
    doScale = int(random(oddsToScale)) == 0;
  }
  if (oddsToRot > 0) {
    doRot = int(random(oddsToRot)) == 0;
  }
  if (oddsToTrans > 0) {
    doTrans = int(random(oddsToTrans)) == 0;
  }
  
  if (doScale) {
    scaleCenX = random(width);
    scaleCenY = random(height);
    scaleTarget = 1 + (int(random(2)) == 0 ? maxScaleOffset : -maxScaleOffset);
    if (debug) {
      println("Doing scaling: (", scaleCenX, scaleCenY, "):", scaleTarget);
    }
  }
  
  if (doRot) {
    // float rotCenX, rotCenY, rotTarget;
    rotCenX = random(width);
    rotCenY = random(height);
    rotTarget = int(random(2)) == 0 ? maxRotOffset : -maxRotOffset;
    if (debug) {
      println("Doing rotation: (", rotCenX, rotCenY, "):", rotTarget);
    }
  }
  
  if (doTrans) {
    float angle = random(TWO_PI);
    transTargetX = maxTransOffset + cos(angle);
    transTargetY = maxTransOffset + sin(angle);
    if (debug) {
      println("Doing translation: (", transTargetX, transTargetY, "):", angle);
    }
  }
}
