class Puddle {
  PVector[][] Corners;
  color[] Pal;
  int Age;
  
  Puddle(PVector[][] corners, color[] pal) {
    this.Corners = corners;
    this.Pal = pal;
  }
  
  void Move() {
    this.Age++;
  }
  
  boolean IsDead() {
    return this.Age >= (this.Pal.length - 1) + this.Pal.length * SHRINK_FRAMES;
  }

  // Once at full size, the number of frames each inner-most square lasts before disappearing.
  static final int SHRINK_FRAMES = 2;

  void Draw() {
    int shapes = this.Pal.length;  // == Corners[0].length - 1 (the last entry is the center).
    int colorAge = min(this.Age, shapes - 1);
    int minS = max(0, this.Age - (shapes - 1)) / SHRINK_FRAMES;
    noStroke();
    // Outer-most first so inner shapes are drawn on top.
    for (int s = min(this.Age, shapes - 1); s >= minS; s--) {
      int ring = shapes - 1 - s;  // Index into Corners[j][...]; 0 is outer-most.
      fill(this.Pal[shapes - 1 - (colorAge - s)]);
      beginShape();
      for (int j = 0; j < this.Corners.length; j++) {
        vertex(this.Corners[j][ring].x, this.Corners[j][ring].y);
      }
      endShape(CLOSE);
    }
  }
}

class Pinwheel {
  PVector Center;
  PVector[][] Corners;
  color[] Pal;
  int Age;
  int DSpin;
  
  Pinwheel(PVector center, color[] pal, int dSpin) {
    this.Center = center.copy();
    this.Pal = pal;
    this.Corners = new PVector[pinwheelCorners.length][pinwheelCorners[0].length+1];
    for (int i = 0; i < pinwheelCorners.length; i++) {
      for (int j = 0; j < pinwheelCorners[i].length; j++) {
        this.Corners[i][j] = PVector.add(center, pinwheelCorners[i][j]);
      }
      this.Corners[i][pinwheelCorners[i].length] = this.Center;
    }
    this.DSpin = dSpin;
  }
  
  void Move() {
    this.Age++;
  }
  
  // The max number of segments visible in each direction at once.
  static final int VISIBLE_SEGMENTS = 4;

  boolean IsDead() {
    // Segment k is drawn while Age is in [k, k+VISIBLE_SEGMENTS-1], 
    // and the last segment is k = Pal.length-1.
    return this.Age >= this.Pal.length + VISIBLE_SEGMENTS - 1;
  }
  
  boolean LeavingCenter() {
    return this.Age == VISIBLE_SEGMENTS - 1;
  }
  
  boolean ReachedEdge() {
    return this.Age == this.Pal.length - 1;
  }

  void Draw() {
    int maxIdx = this.Pal.length-1;
    int first = max(0, this.Age - VISIBLE_SEGMENTS + 1);
    int last = min(maxIdx, this.Age);
    strokeWeight(1.5);
    for (int k = first; k <= last; k++) {
      int i = maxIdx - k;
      stroke(pinwheelHighlights[i]);
      for (int j = 0; j < this.Corners.length; j++) {
        int j2 = (j + this.Corners.length + this.DSpin) % this.Corners.length;
        line(this.Corners[j][i+1].x, this.Corners[j][i+1].y, this.Corners[j2][i].x, this.Corners[j2][i].y);
      }
    }
    strokeWeight(1);
    for (int k = first; k <= last; k++) {
      int i = maxIdx - k;
      stroke(this.Pal[i]);
      for (int j = 0; j < this.Corners.length; j++) {
        int j2 = (j + this.Corners.length + this.DSpin) % this.Corners.length;
        line(this.Corners[j][i+1].x, this.Corners[j][i+1].y, this.Corners[j2][i].x, this.Corners[j2][i].y);
      }
    }
  }
}

class Zapper {
  PVector[] Points;
  color Col;
  int Age;
  
  Zapper(PVector start, float mainDir, int steps, color col) {
    this.Col = col;
    this.Points = new PVector[steps+1];
    this.Points[0] = start.copy();
    for (int i = 1; i <= steps; i++) {
      this.Points[i] = Go(this.Points[i-1], 
        mainDir + random(-zapperAngleMax, zapperAngleMax), 
        random(zapperLengthMin, zapperLengthMax));
    }
  }
  
  void Move() {
    this.Age++;
  }
  
  // The max number of segments visible at once.
  static final int VISIBLE_SEGMENTS = 4;

  boolean IsDead() {
    // The last segment is gone once minI (in Draw) passes it.
    int steps = this.Points.length - 1;
    return this.Age >= steps + min(VISIBLE_SEGMENTS, steps) - 1;
  }

  void Draw() {
    // Segment i goes from Points[i-1] to Points[i] and is visible while Age is in
    // [i-1, i-2+VISIBLE_SEGMENTS]. Once the last point is reached, the rest disappear one per age.
    int steps = this.Points.length - 1;
    int maxI = min(this.Age+1, steps);
    int minI = max(1, this.Age - min(VISIBLE_SEGMENTS, steps) + 2);
    strokeWeight(1.5);
    stroke(pinwheelHighlights[0]);
    for (int i = minI; i <= maxI; i++) {
      line(this.Points[i-1].x, this.Points[i-1].y, this.Points[i].x, this.Points[i].y);
    }
    strokeWeight(1);
    stroke(this.Col);
    for (int i = minI; i <= maxI; i++) {
      line(this.Points[i-1].x, this.Points[i-1].y, this.Points[i].x, this.Points[i].y);
    }
  }
}
