ArrayList<Dot> dots;
Color[] colors;
boolean showCount = false;

void setup() {
  size(1024, 768);
  colors = new Color[]{
    new Color(#FFADAD), new Color(#FFD6A5),
    new Color(#FDFFB6), new Color(#CAFFBF),
    new Color(#9BF6FF), new Color(#A0C4FF),
    new Color(#BDB2ff), new Color(#FFC5FF),
  };
  
  dots = new ArrayList<Dot>(colors.length);
  for (int i = 0; i < colors.length; i++) {
    dots.add(new Dot(width/2, height/2, colors[i]));
  }
  
  textSize(32);
}

void draw() {
  background(0);
  
  int dRed = int(random(-5, 5));
  int dGreen = int(random(-5, 5));
  int dBlue = int(random(-5, 5));
  for (Color col : colors) {
    col.AddRGB(dRed, dGreen, dBlue);
  }
  
  for (Dot dot : dots) {
    dot.Accelerate(random(-1, 1), random(-1, 1));
    dot.Move();
    dot.Draw();
  }
  
  int dotCount = dots.size();
  
  if (showCount) {
    fill(255); // White
    text(dotCount, 3, height-5); // Shows in lower left corner.
  }
  
  for (int i = 0; i < dotCount; i++ ) {
    // There's a 1 in dotCount chance that we get a new dot.
    // So if there's 1 dot, we're guaranteed to get a new one.
    // And it gets less likely as we get more.
    if (int(random(dots.size())) == 0) {
      dots.add(dots.get(i).Copy());
    }
  }

  for (int i = dotCount - 1; i >= 0; i--) {
    // There's a 1 in 1000 - dotCount chance that this dot disappears.
    // So, the more dots there are, the more likely this dot is to disappear.
    if (int(random(1000 - dotCount)) == 0) {
      dots.remove(i);
    }
  }
}

void mousePressed() {
  showCount = ! showCount;
}
