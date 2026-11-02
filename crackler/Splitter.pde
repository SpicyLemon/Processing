class Splitter {
  PVector Start;
  PVector Split;
  PVector Corner1;
  PVector Corner2;
  PVector LastSplit1;
  PVector LastSplit2;
  PVector[] Path1A;
  PVector[] Path1B;
  PVector[] Path2A;
  PVector[] Path2B;
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
    
    this.Path1A = new PVector[5];
    this.Path1B = new PVector[5];
    this.Path2A = new PVector[5];
    this.Path2B = new PVector[5];

    this.Path1A[0] = DirTo1.Go(this.LastSplit1, splitterSecondLen);
    this.Path1B[0] = DirTo2.Go(this.LastSplit1, splitterSecondLen);
    this.Path2A[0] = DirTo1.Go(this.LastSplit2, splitterSecondLen);
    this.Path2B[0] = DirTo2.Go(this.LastSplit2, splitterSecondLen);
    
    this.Path1A[1] = mainDir.Go(this.Path1A[0], splitterSecondLen);
    this.Path1B[1] = mainDir.Go(this.Path1B[0], splitterSecondLen);
    this.Path2A[1] = mainDir.Go(this.Path2A[0], splitterSecondLen);
    this.Path2B[1] = mainDir.Go(this.Path2B[0], splitterSecondLen);
    
    for (int i = 2; i < 5; i++) {    
      this.Path1A[i] = Go(this.Path1A[i-1], mainDir.Radians() + random(-splitterThirdAngleMax, splitterThirdAngleMax), splitterThirdLen);
      this.Path1B[i] = Go(this.Path1B[i-1], mainDir.Radians() + random(-splitterThirdAngleMax, splitterThirdAngleMax), splitterThirdLen);
      this.Path2A[i] = Go(this.Path2A[i-1], mainDir.Radians() + random(-splitterThirdAngleMax, splitterThirdAngleMax), splitterThirdLen);
      this.Path2B[i] = Go(this.Path2B[i-1], mainDir.Radians() + random(-splitterThirdAngleMax, splitterThirdAngleMax), splitterThirdLen);
    }
  }
  
  void Move() {
    this.Age++;
  }
  
  boolean IsDead() {
    return this.Age >= 48;
  }
  
  void Draw() {
    int minPal = 0;
    if (this.Age > 24) {
      minPal = min(this.Age/3 - 8, 7);
    }
    if (this.Age >= 21) {
        strokeWeight(splitterThirdWeight);
        stroke(this.Pal[max(7, minPal)]);
        line(this.Path1A[3].x, this.Path1A[3].y, this.Path1A[4].x, this.Path1A[4].y);
        line(this.Path1B[3].x, this.Path1B[3].y, this.Path1B[4].x, this.Path1B[4].y);
        line(this.Path2A[3].x, this.Path2A[3].y, this.Path2A[4].x, this.Path2A[4].y);
        line(this.Path2B[3].x, this.Path2B[3].y, this.Path2B[4].x, this.Path2B[4].y);
    }
    if (this.Age >= 18) {
        strokeWeight(splitterThirdWeight);
        stroke(this.Pal[max(6, minPal)]);
        line(this.Path1A[2].x, this.Path1A[2].y, this.Path1A[3].x, this.Path1A[3].y);
        line(this.Path1B[2].x, this.Path1B[2].y, this.Path1B[3].x, this.Path1B[3].y);
        line(this.Path2A[2].x, this.Path2A[2].y, this.Path2A[3].x, this.Path2A[3].y);
        line(this.Path2B[2].x, this.Path2B[2].y, this.Path2B[3].x, this.Path2B[3].y);
    }
    if (this.Age >= 15) {
        strokeWeight(splitterThirdWeight);
        stroke(this.Pal[max(5, minPal)]);
        line(this.Path1A[1].x, this.Path1A[1].y, this.Path1A[2].x, this.Path1A[2].y);
        line(this.Path1B[1].x, this.Path1B[1].y, this.Path1B[2].x, this.Path1B[2].y);
        line(this.Path2A[1].x, this.Path2A[1].y, this.Path2A[2].x, this.Path2A[2].y);
        line(this.Path2B[1].x, this.Path2B[1].y, this.Path2B[2].x, this.Path2B[2].y);
    }
    if (this.Age >= 12) {
        strokeWeight(splitterSecondWeight);
        stroke(this.Pal[max(4, minPal)]);
        line(this.Path1A[0].x, this.Path1A[0].y, this.Path1A[1].x, this.Path1A[1].y);
        line(this.Path1B[0].x, this.Path1B[0].y, this.Path1B[1].x, this.Path1B[1].y);
        line(this.Path2A[0].x, this.Path2A[0].y, this.Path2A[1].x, this.Path2A[1].y);
        line(this.Path2B[0].x, this.Path2B[0].y, this.Path2B[1].x, this.Path2B[1].y);
    }
    if (this.Age >= 9) {
        strokeWeight(splitterSecondWeight);
        stroke(this.Pal[max(3, minPal)]);
        line(this.LastSplit1.x, this.LastSplit1.y, this.Path1A[0].x, this.Path1A[0].y);
        line(this.LastSplit1.x, this.LastSplit1.y, this.Path1B[0].x, this.Path1B[0].y);
        line(this.LastSplit2.x, this.LastSplit2.y, this.Path2A[0].x, this.Path2A[0].y);
        line(this.LastSplit2.x, this.LastSplit2.y, this.Path2B[0].x, this.Path2B[0].y);
    }
    if (this.Age >= 6) {
        strokeWeight(splitterStartWeight);
        stroke(this.Pal[max(2, minPal)]);
        line(this.Corner1.x, this.Corner1.y, this.LastSplit1.x, this.LastSplit1.y);
        line(this.Corner2.x, this.Corner2.y, this.LastSplit2.x, this.LastSplit2.y);
    }
    if (this.Age >= 3) {
        strokeWeight(splitterStartWeight);
        stroke(this.Pal[max(1, minPal)]);
        line(this.Split.x, this.Split.y, this.Corner1.x, this.Corner1.y);
        line(this.Split.x, this.Split.y, this.Corner2.x, this.Corner2.y);
    }
    if (this.Age >= 0) {
        strokeWeight(splitterStartWeight);
        stroke(this.Pal[max(0, minPal)]);
        line(this.Start.x, this.Start.y, this.Split.x, this.Split.y);
    }
  }
}

// Go returns the point reached by starting at from and moving dist at angle rads.
// Angle convention matches Direction.Radians(): 0 is +x (Right), measured clockwise
// in screen space (y points down), so HALF_PI is Down and PI_3_2 is Up.
PVector Go(PVector from, float rads, float dist) {
  return new PVector(from.x + dist * cos(rads), from.y + dist * sin(rads));
}
