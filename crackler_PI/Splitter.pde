class Splitter {
  PVector Start;
  PVector Split;
  PVector Corner1;
  PVector Corner2;
  PVector LastSplit1;
  PVector LastSplit2;
  color[] Pal;
  int Age;
  Line Parent;
  
  Splitter(PVector start, Direction mainDir, Line parent) {
    Direction DirTo1 = mainDir.TurnCW();
    Direction DirTo2 = mainDir.TurnCCW();
    
    this.Parent = parent;
    this.Pal = splitterColors[colorIndex.get(parent.Col)];

    this.Start = start.copy();
    this.Split = mainDir.Go(this.Start, splitterStartLen);

    this.Corner1 = DirTo1.Go(this.Split, splitterStartLen);
    this.Corner2 = DirTo2.Go(this.Split, splitterStartLen);

    float da = random(splitterStartAngleMax);
    this.LastSplit1 = Go(this.Corner1, mainDir.Radians() + da, splitterStartLen);
    this.LastSplit2 = Go(this.Corner2, mainDir.Radians() - da, splitterStartLen);
  }
  
  void Move() {
    this.Age++;
  }
  
  boolean IsDead() {
    return this.Age >= 4;
  }
  
  void Draw() {
    strokeWeight(splitterStartWeight);
    stroke(this.Pal[2]);
    line(this.Corner1.x, this.Corner1.y, this.LastSplit1.x, this.LastSplit1.y);
    line(this.Corner2.x, this.Corner2.y, this.LastSplit2.x, this.LastSplit2.y);

    stroke(this.Pal[1]);
    line(this.Split.x, this.Split.y, this.Corner1.x, this.Corner1.y);
    line(this.Split.x, this.Split.y, this.Corner2.x, this.Corner2.y);

    stroke(this.Pal[0]);
    line(this.Start.x, this.Start.y, this.Split.x, this.Split.y);
  }
}

// Go returns the point reached by starting at from and moving dist at angle rads.
// Angle convention matches Direction.Radians(): 0 is +x (Right), measured clockwise
// in screen space (y points down), so HALF_PI is Down and PI_3_2 is Up.
PVector Go(PVector from, float rads, float dist) {
  return new PVector(from.x + dist * cos(rads), from.y + dist * sin(rads));
}
