Palette rotL;
Palette rotR;
int top = 25;
int frameCounter = 0;


void setup() {
  size(1024, 768);
  Palette p1 = new Palette(100, #FF00FF, #00FFFF);
  p1.Set(10, #FFFF00);
  DrawFull(p1);
  
  Palette p2 = new Palette(10, #00FF00, #FF0000, 126);  
  Palette p3 = new Palette(16);
  Palette p4 = new Palette(#F03838, #EA6D24, #FC9E38, #F7D211, #717136, #303030);

  DrawPal[] toDraw = new DrawPal[]{
    new DrawPal(50, p1),
    new DrawPal(10, p2),
    new DrawPal(15, p3),
    new DrawPal(75, new Palette(p1, p2, p3, p4)),
    // 10 colors because first color of append equals last of base.
    new DrawPal(50, new Palette(6, #00A71D, #4F4FFF)
            .Append(new Palette(5, #4F4FFF, #FFFFFF))),
    // 11 colors because first color of append is not the same as the last of the base.
    new DrawPal(50, new Palette(6, #00A71D, #4F4FFF)
            .Append(new Palette(5, #4F50FF, #FFFFFF))),
    // Dark-Red to Blue.
    new DrawPal(25, new Palette(20, #AA0000, #0000FF)),
    // Green to teal to magenta:
    new DrawPal(25, new Palette(10, #81FF5F, #04B4BC)
            .Append(new Palette(11, #04B4BC, #EA24DE))),
    // Red to Yellow.
    new DrawPal(25, new Palette(17, #FF0000, #FFFF00)
            .Append(new Palette(4, #FFFF00, #F0FF00))),
    // Yellow, Orange, Red, Purple, Blue.
    new DrawPal(25, new Palette(10, #FFFF00, #FF0000)
            .Append(new Palette(11, #FF0000, #0000FF))),
    // Forrest.
    new DrawPal(25, new Palette(7, #0FB7A7, #387627)
            .Append(new Palette(8, #387627, #AAAA45))
            .Append(new Palette(7, #AAAA45, #93601C))),
    // Red to black to red, fading out at the end.
    new DrawPal(10, new Palette(10, #FF0000, #000000)
            .Append(new Palette(11, #000000, #FF0000))
            .WithAlphaGradient(255, 0)),
    // Blue to Green to Blue, fading in from the start.
    new DrawPal(10, new Palette(10, #0000FF, #00FF00)
            .Append(new Palette(11, #00FF00, #0000FF))
            .WithAlphaGradient(0, 255)),
    new DrawPal(10, new Palette(5, #FFFF00, #FF9900)
            .Append(new Palette(11, #FF9900, #FF00FF))),
  };

  for (DrawPal dp : toDraw) {
    DrawInRect(dp.Pal, 50, top, width-100, dp.Height);
    top += dp.Height + 15;
  }
  
  rotR = new Palette(10, #00FF00, #FF0000);
  rotL = new Palette(16).Append(new Palette(16, #FFFFFF, #000000));
}

void draw() {
  frameCounter++;
  if (frameCounter >= 10) {
    rotR.RotateRight();
    rotL.RotateLeft();
    frameCounter = 0;
  }
  DrawInRect(rotR, 50, top, width-100, 25);
  DrawInRect(rotL, 50, top+40, width-100, 25);
}

// DrawFull will draw this palette in vertical stripes from left to right,
// accross the whole screen.
void DrawFull(Palette pal) {
  DrawInRect(pal, 0, 0, width, height);
}

// DrawInRect will draw this palette in vertical stripes from left to right,
// starting at (x, y) with the provided resulting width and height. 
void DrawInRect(Palette pal, int x, int y, int resultWidth, int resultHeight) {
  float colWidth = (float)resultWidth/(float)pal.Size();
  for (int i = 0; i < pal.Size(); i++) {
    stroke(pal.Get(i).Opposite());
    fill(pal.Get(i).Value);
    rect(i*colWidth+x, y, colWidth, resultHeight);
  }
}

class DrawPal {
  Palette Pal;
  int Height;
  
  DrawPal(int h, Palette pal) {
    this.Height = h;
    this.Pal = pal;
  }
}
