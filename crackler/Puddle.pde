class Puddle {
  PVector Center;
  PVector[][] Corners;
  color[] Pal;
  int Age;
  
  Puddle(PVector center, color[] pal) {
    this.Center = center.copy();
    this.Pal = pal;
    this.Corners = new PVector[puddleCorners.length][puddleCorners[0].length+1];
    for (int i = 0; i < puddleCorners.length; i++) {
      for (int j = 0; j < puddleCorners[i].length; j++) {
        this.Corners[i][j] = PVector.add(center, puddleCorners[i][j]);
      }
      this.Corners[i][puddleCorners[i].length] = this.Center;
    }
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
      stroke(puddleHighlights[i]);
      for (int j = 0; j < this.Corners.length; j++) {
        line(this.Corners[j][i+1].x, this.Corners[j][i+1].y, this.Corners[j][i].x, this.Corners[j][i].y);
      }
    }
    strokeWeight(1);
    for (int k = first; k <= last; k++) {
      int i = maxIdx - k;
      stroke(this.Pal[i]);
      for (int j = 0; j < this.Corners.length; j++) {
        line(this.Corners[j][i+1].x, this.Corners[j][i+1].y, this.Corners[j][i].x, this.Corners[j][i].y);
      }
    }
  }
}
