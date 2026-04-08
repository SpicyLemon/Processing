// Draw something only each time the mouse is clicked.

void setup() {
  size(400, 400);
  noLoop(); // Do not run draw() continusously as usual, just ignore it for now.
}

void draw() {
  background(204);
  line(mouseX, 0, mouseX, height);
  line(0, mouseY, width, mouseY);
}

void mousePressed() {
  redraw(); // Run the code in draw() one time.
}
