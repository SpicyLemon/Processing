float cur = 0;
void setup() {
  size(1024, 768);
  logArchLen(0.25, 1, true);
  logArchLen(0.25, 1, false);
  logArchLen(2.5, 1, true);
  logArchLen(2.5, 1, false);
}

void draw() {
  background(#000000);
  stroke(#FFFFFF);
  fill(#FFFFFF);
  arc(width/2, height/2, 50, 50, cur, PI+HALF_PI);
  cur += 0.01;
  if (cur >= TWO_PI) {
    cur = 0;
  }
  noFill();
  stroke(#FF0000); // Red
  drawArch(0.25, 1, 70, true);
  stroke(#00FFFF); // Cyan
  drawArch(0.25, 1, 75, false);
  stroke(#FF0000); // Red
  drawArch(2.5, 1, 95, true);
  stroke(#00FFFF); // Cyan
  drawArch(2.5, 1, 100, false);
}

void drawArch(float start, float stop, float radius, boolean clockwise) {
  if (clockwise) {
    if (start < stop) {
      arc(width/2, height/2, radius, radius, start, stop);
    } else {
      arc(width/2, height/2, radius, radius, start, stop+TWO_PI);
    }
  } else {
    if (start < stop) {
      arc(width/2, height/2, radius, radius, stop, start+TWO_PI);
    } else {
      arc(width/2, height/2, radius, radius, stop, start);
    }
  }
}

void logArchLen(float start, float stop, boolean clockwise) {
  String dir = (clockwise) ? "CW " : "CCW";
  float rv = archLen(start, stop, clockwise);
  println("archLen(", start, ",", stop, ",", dir, ") = ", rv);
}

float archLen(float start, float stop, boolean clockwise) {
  if (clockwise) {
    if (start < stop) {
      return stop - start;
    }
    return stop+TWO_PI-start;
  }
  if (stop < start) {
    return start - stop;
  }
  return start+TWO_PI - stop;
}
