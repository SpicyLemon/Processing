// This scetch draws a trail of white circles on a black background, following the mouse.
// This one should have better performance than the previous one.
int num = 100; // Keep the last 100 mouse positions.
int[] x = new int[num];
int[] y = new int[num];
int indexPosition = 0;

void setup() {
  size(400, 400);
  noStroke();
  fill(255, 102); // Fill circles with white at 40% opacity.
}

void draw() {
  background(0); // Black

  // Add the new values to the start of the array.
  x[indexPosition] = mouseX;
  y[indexPosition] = mouseY;
  
  // Move to the next position for next iteration.
  indexPosition = (indexPosition + 1) % num;
  
  // Draw circles around those coordinates.
  for (int i = 0; i < num; i++) {
    // translate i to be based on the indexPosition (instead of 0).
    int pos = (indexPosition + i) % num;
    float radius = (num - i) / 2.0; // Just calc this once.
    ellipse(x[pos], y[pos], radius, radius);
  }
}
