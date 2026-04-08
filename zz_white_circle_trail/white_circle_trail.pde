// This scetch draws a trail of white circles on a black background, following the mouse.
int num = 50; // Keep the last 50 mouse positions.
int[] x = new int[num];
int[] y = new int[num];

void setup() {
  size(400, 400);
  noStroke();
  fill(255, 102); // Fill circles with white at 40% opacity.
}

void draw() {
  background(0); // Black
  // Shift all x and y mouse values to the right one spot.
  for (int i = num-1; i > 0; i--) {
    x[i] = x[i-1];
    y[i] = y[i-1];
  }
  
  // Add the new values to the start of the array.
  x[0] = mouseX;
  y[0] = mouseY;
  
  // Draw circles around those coordinates.
  for (int i = 0; i < num; i++) {
    ellipse(x[i], y[i], i/2.0, i/2.0);
  }
}
