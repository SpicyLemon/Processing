boolean drawT = false;

void setup() {
  size(400, 400);
  noStroke();
}

void draw() {
  background(204);
  if (drawT == true) {
    rect(width*.2, height*.2, width*.6, height*.2);
    rect(width*.39, height*.4, width*.22, height*.45);
  }
}

void keyPressed() {
  if ((key == 'T') || (key == 't')) {
    drawT = true;
  }
}

void keyReleased() {
  drawT = false;
}
