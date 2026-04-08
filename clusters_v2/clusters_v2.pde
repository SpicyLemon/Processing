Palette pal;
Cluster[] clusters;
boolean mouseWasPressed;
boolean showCenter = false;

void restart() {
  pal = NewPalette16();
  clusters = new Cluster[pal.Size()];
  int i = 0;
  //for (; i < pal.Size()/2; i++) {
  //  clusters[i] = new Cluster(50.0+random(width-100.0), 50.0+random(height-100.0), 
  //                            5+int(random(10)), pal.Get(2*i), pal.Get(2*i+1));
  //}
  for (int j = 0; j < pal.Size(); i++, j++) {
    int j2 = (j + 1) % pal.Size();
    clusters[i] = new Cluster(50.0+random(width-100.0), 50.0+random(height-100.0), 
                              5+int(random(10)), pal.Get(j), pal.Get(j2));
  }
}

void setup() {
  size(1024, 768);
  restart();
}

void draw() {
  background(0);
  if (mouseWasPressed) {
    restart();
    mouseWasPressed = false;
  }
  for (Color col : pal.Colors) {
    col.AddRGB(int(random(-5.5, 5.5)), int(random(-5.5, 5.5)), int(random(-5.5, 5.5)));
  }
  for (Cluster cluster : clusters) {
    cluster.Move();
    cluster.Draw();
    if (showCenter) {
      noStroke();
      fill(#FFFFFF);
      circle(cluster.Center.X, cluster.Center.Y, 5);
    }
  }
}

void mousePressed() {
  mouseWasPressed = !mouseWasPressed;
}
