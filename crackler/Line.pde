class Line {
  color Col;
  ArrayList<PVector> Points;
  ArrayList<Float> Dists;
  float Head;
  float Tail;
  float Speed;
  color HighlightMid;
  color HighlightMain;
  
  Line(color col, float x, float y) {
    this.Col = col;
    this.Points = new ArrayList<>();
    this.Points.add(new PVector(x, y));
    this.Dists = new ArrayList<>();
    this.Dists.add(0.0);
    this.HighlightMain = #FFFFFF;
    this.HighlightMid = lerpColor(this.Col, this.HighlightMain, 0.5);
  }
  
  Line WithLength(float l) {
    this.Tail = -l;
    return this;
  }
  
  Line WithSpeed(float s) {
    this.Speed = s;
    return this;
  }

  Line Go(Direction dir, float distance) {
    this.Points.add(dir.Go(this.Last(), distance));
    this.Dists.add(this.Dists.get(this.Dists.size() - 1) + distance);
    return this;
  }
  
  PVector Last() {
    if (this.Points == null || this.Points.size() == 0) {
      return null;
    }
    return this.Points.get(this.Points.size() - 1);
  }
  
  Line SetLast(float x, float y) {
    int i = this.Points.size() - 1;
    PVector last = this.Points.get(i);
    last.set(x, y);
    this.Dists.set(i, this.Dists.get(i - 1) + PVector.dist(this.Points.get(i - 1), last));
    return this;
  }

  Float Length() {
    return this.Dists.get(this.Dists.size() - 1);
  }
  
  PVector GetPoint(float distance) {
    if (distance <= 0) {
      return this.Points.get(0).copy();
    }
    if (distance >= this.Length()) {
      return this.Last().copy();
    }
    for (int i = 1; i < this.Points.size(); i++) {
      float d1 = this.Dists.get(i);
      if (distance <= d1) {
        float d0 = this.Dists.get(i - 1);
        float amt = (distance - d0) / (d1 - d0);
        return PVector.lerp(this.Points.get(i-1), this.Points.get(i), amt);
      }
    }
    return this.Last().copy();
  }
  
  boolean IsDead() {
    return this.Tail >= this.Length();
  }
  
  void Move() {
    this.Head += this.Speed;
    this.Tail += this.Speed;
  }
  
  void DrawFull() {
    float sw = this.Points.size()*2 + 1;
    stroke(this.Col);
    PVector p1 = null;
    PVector p2 = this.Points.get(0);
    if (DEBUG) {
      println("0: (" + p2.x + ", " + p2.y + ")");
    }
    for (int i = 1; i < this.Points.size(); i++) {
      p1 = p2;
      p2 = this.Points.get(i);
      if (DEBUG) {
        println(i + ": (" + p2.x + ", " + p2.y + ")");
      }
      strokeWeight(sw);
      line(p1.x, p1.y, p2.x, p2.y);
      sw -= 2;
    }
    
    PVector head = this.GetPoint(this.Head);
    PVector tail = this.GetPoint(this.Tail);
    stroke(#FFFFFF);
    strokeWeight(lineWeight);
    point(head.x, head.y);
    point(tail.x, tail.y);
  }
  
  void DrawShort() {
    ArrayList<PVector> pts = new ArrayList<>();
    pts.add(this.GetPoint(this.Tail));
    for (int i = 0; i < this.Points.size(); i++) {
      float d = this.Dists.get(i);
      if (this.Tail <= d && d <= this.Head) {
        pts.add(this.Points.get(i).copy());
      }
    }
    pts.add(this.GetPoint(this.Head));
    
    stroke(this.Col);
    strokeWeight(lineWeight);
    PVector p0;
    PVector p1 = pts.get(0);
    for (int i = 1; i < pts.size(); i++) {
      p0 = p1;
      p1 = pts.get(i);
      line(p0.x, p0.y, p1.x, p1.y);
    }

    stroke(this.HighlightMid);
    strokeWeight(lineHighlightMidWeight);
    p1 = pts.get(0);
    for (int i = 1; i < pts.size(); i++) {
      p0 = p1;
      p1 = pts.get(i);
      line(p0.x-offsetHighlightMid, p0.y-offsetHighlightMid, p1.x-offsetHighlightMid, p1.y-offsetHighlightMid);
    }

    stroke(this.HighlightMain);
    strokeWeight(lineHighlightMainWeight);
    p1 = pts.get(0);
    for (int i = 1; i < pts.size(); i++) {
      p0 = p1;
      p1 = pts.get(i);
      line(p0.x-offsetHighlightMain, p0.y-offsetHighlightMain, p1.x-offsetHighlightMain, p1.y-offsetHighlightMain);
    }
  }
}

enum Direction {
  Up,
  Right,
  Down,
  Left;
  
  Direction Opposite() {
    switch(this) {
      case Up: return Down;
      case Right: return Left;
      case Down: return Up;
      case Left: return Right;
    }
    return null;
  }
  
  PVector Go(PVector from, float distance) {
    switch (this) {
      case Up: return new PVector(from.x, from.y - distance);
      case Right: return new PVector(from.x + distance, from.y);
      case Down: return new PVector(from.x, from.y + distance);
      case Left: return new PVector(from.x - distance, from.y);
    }
    throw new IllegalArgumentException("Unknown direction: " + this);
  }
}

static final Direction[] DIRECTIONS = Direction.values();

Direction randomDirection() {
  return DIRECTIONS[(int) random(DIRECTIONS.length)];
}

Direction randomPerpendicular(Direction main) {
  int v = (int) random(2); // 0 or 1.
  if (main == Direction.Up || main == Direction.Down) {
      if (v == 0) {
        return Direction.Left;
      }
      return Direction.Right;
  }
  // main = Left or Right.
  if (v == 0) {
    return Direction.Up;
  }
  return Direction.Down;
}
