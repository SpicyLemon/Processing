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
