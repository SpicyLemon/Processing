Palette pal;
Cluster[] clusters;
boolean mouseWasPressed;

void restart() {
  pal = NewPalette16();
  clusters = new Cluster[pal.Size()/2];
  for (int i = 0; i < clusters.length; i++) {
    clusters[i] = new Cluster(50.0+random(width-100.0), 50.0+random(height-100.0), 
                              10+int(random(20)), pal.Get(2*i), pal.Get(2*i+1));
  }
}

void setup() {
  fullScreen();
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
    //noStroke();
    //fill(#FFFFFF);
    //circle(cluster.Center.X, cluster.Center.Y, 5);
  }
}

void mousePressed() {
  mouseWasPressed = !mouseWasPressed;
}
