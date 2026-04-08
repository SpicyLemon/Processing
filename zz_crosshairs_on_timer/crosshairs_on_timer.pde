// This sketch shows crosshairs on the mouse cursor for 2 seconds after clicking.
int frame = 0;

void setup() {
  size(400, 400);
}

void draw() {
  // Should be 60 frames per second, so 120 frames = 2 seconds.
  if (frame > 120) {
    noLoop(); // Stop the draw() program part (once done with this iteration).
    background(0); // and turn the background black.
  } else {
    // It's been less than 2 seconds since a click (or program start).
    background(204); // Set the background to gray.
    line(mouseX, 0, mouseX, height); // Draw vertical line on mouse.
    line(0, mouseY, width, mouseY);  // Draw horizontal line on mouse.
    frame++; // One more frame done.
  }
}

void mousePressed() {
  loop();
  frame = 0;
}
