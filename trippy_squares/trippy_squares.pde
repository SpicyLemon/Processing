import gifAnimation.*;

GifMaker gifExport;
int gifFrameLimit = 1000;
int gifFrameRate = 1000/30; // 30 fps
boolean saveGif = false;

Palette pal1;
Palette pal2;
boolean mouseWasPressed = false;
int frameCounter = 0;
int hCount;
int vCount;
float squareLeft;
float squareTop;

int squareSize = 75;

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
  }
}

void draw() {
  float p1SquareThickness = squareSize/pal1.Size()/2;
  float p2SquareThickness = squareSize/pal2.Size()/2;
  
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
  
  if (mouseWasPressed || frameCount % 900 == 0 || (saveGif && frameCount % 200 == 0)) {
    mouseWasPressed = false;
    setVals();
    setPals();
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
  mouseWasPressed = true;
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
  hCount = (int)(width/squareSize)+2;
  vCount = (int)(height/squareSize)+2;
  squareLeft = (width-squareSize*(hCount-2))/2-squareSize;
  squareTop = (height-squareSize*(vCount-2))/2-squareSize;
}
