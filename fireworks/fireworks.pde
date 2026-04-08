// launchColors = White to Yellow to Black.
Palette palLaunch = ContinuousPalette(#FFFFFF, 10, #FFFF00, 5, #222222);
// explosion1 = Red to Orange to Black.
Palette explosion1 = ContinuousPalette(#FF0000, 13, #FF8E00, 3, #222222).SetAlpha(126);
// explosion2 = Orange to Yellow to Black.
Palette explosion2 = ContinuousPalette(#FF8E00, 13, #FFFF00, 3, #222222).SetAlpha(126);
// explosion3 = Red to Purple to Black.
Palette explosion3 = ContinuousPalette(#FF0000, 13, #5D09C8, 3, #222222).SetAlpha(126);
// explosion4 = White to Blue to Black.
Palette explosion4 = ContinuousPalette(#D9FCFC, 13, #0000FF, 3, #222222).SetAlpha(126);

Palette[] palsExplosion = new Palette[]{explosion1, explosion2, explosion3, explosion4};
int nextExplosionPal = 0;
ArrayList<Dot> dots = new ArrayList<>();
ArrayList<Rocket> rockets = new ArrayList<>();
boolean mouseWasPressed = false;

void setup() {
  fullScreen();
}

void draw() {
  background(0);
  // DrawPalettes(palLaunch, explosion1, explosion2, explosion3, explosion4);

  if (mouseWasPressed) {
    Rocket rocket = new Rocket(palLaunch, mouseX, height)
                        .WithVelocity(random(-0.5, 0.5), -5.0 - random(10.0))
                        .WithExplosion(GetNextExplosionPal());
    rockets.add(rocket);
    mouseWasPressed = false;
  } else if (int(random(30)) == 0) {
    AddDotsAtRandom();
  } else if (int(random(200)) == 0) {
    for (int i = 0; i < 10; i++) {
      AddDotsAtRandom();
    }
  } else if (int(random(1000)) == 0) {
    for (int i = 0; i < 50; i++) {
      AddDotsAtRandom();
    }
  }
  
  for (Dot dot : dots) {
    dot.Accelerate(random(-1, 1), random(-1, 1));
    dot.Move();
    dot.Draw();
    dot.GetOlder();
  }
  
  for (int i = dots.size() - 1; i >= 0; i--) {
    if (dots.get(i).IsDead()) {
      dots.remove(i);
    }
  }
  
  if (dots.size() == 0) {
    AddDotsAtRandom();
  }
  
  for (Rocket rocket : rockets) {
    rocket.Move();
    rocket.Draw();
  }
  
  for (int i = rockets.size() - 1; i >= 0; i--) {
    if (rockets.get(i).IsDead()) {
      rockets.remove(i);
    }
  }
}

void mousePressed() {
  mouseWasPressed = true;
}

void AddDotsAtRandom() {
  AddDots(random(width*.9)+width*.05, random(height*.9)+height*.05);
}

void AddDots(float x, float y) {
  int count = int(random(80))+20;
  Palette pal = GetNextExplosionPal();
  for (int i = 0; i < count; i++) {
    dots.add(new Dot(pal, x, y, 20 + int(random(80))));
  }
}

Palette GetNextExplosionPal() {
  Palette rv = palsExplosion[nextExplosionPal];
  nextExplosionPal = (nextExplosionPal + 1) % palsExplosion.length;
  return rv;
}

// ContinuousPalette creates a palette that has count1 colors from colStart to colMid, then an
// additional count2 colors ending with colEnd. The colMid value is only included once.
// The resulting palette has count1 + count2 colors in it.
Palette ContinuousPalette(color colStart, int count1, color colMid, int count2, color colEnd) {
  // Both palettes will have the colMid value, but we only want it once in the result.
  // So we create the second palette with 1 extra, and then ignore the zeroth entry in it.
  Palette p1 = new Palette(count1, colStart, colMid);
  Palette p2 = new Palette(count2+1, colMid, colEnd);
  p1.Colors = (Color[])expand(p1.Colors, count1 + count2);
  for (int i = 1; i <= count2; i++) {
    p1.Colors[count1+i-1] = p2.Colors[i];
  }
  return p1;
}

// DrawPalettes fills the screen with each of the provided palettes.
// Each palette is printed in vertical stripes from left to right.
void DrawPalettes(Palette... palettes) {
  int h = int(height/palettes.length);
  for (int i = 0; i < palettes.length; i++) {
    DrawInRect(palettes[i], 0, i*h, width, h);
  }
}

// DrawInRect will draw this palette in vertical stripes from left to right,
// starting at (x, y) with the provided resulting width and height. 
void DrawInRect(Palette pal, int x, int y, int resultWidth, int resultHeight) {
  float colWidth = (float)resultWidth/(float)pal.Colors.length;
  for (int i = 0; i < pal.Colors.length; i++) {
    stroke(pal.Colors[i].Opposite());
    fill(pal.Colors[i].Value);
    rect(i*colWidth+x, y, colWidth, resultHeight);
  }
}
