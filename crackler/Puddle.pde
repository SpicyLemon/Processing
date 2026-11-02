class Puddle {
  PVector Center;
  PVector[] UL;
  PVector[] UR;
  PVector[] LL;
  PVector[] LR;
  color[] Pal;
  int Age;
  
  Puddle(PVector center, float size, color[] pal) {
    this.Center = center.copy();
    this.Pal = pal;
    this.UL = new PVector[pal.length];
    this.UR = new PVector[pal.length];
    this.LL = new PVector[pal.length];
    this.LR = new PVector[pal.length];
    for (int i = 0; i < pal.length; i++) {
      float s = map(i, 0, pal.length+1, size, 0);
      this.UL[i] = new PVector(center.x - s, center.y - s);
      this.UR[i] = new PVector(center.x + s, center.y - s);
      this.LL[i] = new PVector(center.x - s, center.y + s);
      this.LR[i] = new PVector(center.x + s, center.y + s);
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
    // Segment k (0 = innermost) goes from Center (k = 0) or index 
    // maxIdx-k+1 (k > 0) out to index maxIdx-k, and is drawn with Pal[maxIdx-k].
    int maxIdx = this.Pal.length - 1;
    int first = max(0, this.Age - VISIBLE_SEGMENTS + 1);
    int last = min(maxIdx, this.Age);
    strokeWeight(1);
    for (int k = first; k <= last; k++) {
      int i = maxIdx - k;
      stroke(this.Pal[i]);
      if (k == 0) {
        line(this.Center.x, this.Center.y, this.UL[i].x, this.UL[i].y);
        line(this.Center.x, this.Center.y, this.UR[i].x, this.UR[i].y);
        line(this.Center.x, this.Center.y, this.LL[i].x, this.LL[i].y);
        line(this.Center.x, this.Center.y, this.LR[i].x, this.LR[i].y);
      } else {
        line(this.UL[i+1].x, this.UL[i+1].y, this.UL[i].x, this.UL[i].y);
        line(this.UR[i+1].x, this.UR[i+1].y, this.UR[i].x, this.UR[i].y);
        line(this.LL[i+1].x, this.LL[i+1].y, this.LL[i].x, this.LL[i].y);
        line(this.LR[i+1].x, this.LR[i+1].y, this.LR[i].x, this.LR[i].y);
      }
    }
  }
}
