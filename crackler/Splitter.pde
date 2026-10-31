class Splitter {
  PVector Start;
  PVector Split;
  PVector Corner1;
  PVector Corner2;
  PVector LastSplit1;
  PVector LastSplit2;
  PVector LastCorner1A;
  PVector LastCorner1B;
  PVector LastCorner2A;
  PVector LastCorner2B;
  PVector End1A;
  PVector End1B;
  PVector End2A;
  PVector End2B;
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

    this.LastSplit1 = mainDir.Go(this.Corner1, splitterStartLen);
    this.LastSplit2 = mainDir.Go(this.Corner2, splitterStartLen);
    
    this.LastCorner1A = DirTo1.Go(this.LastSplit1, splitterStartLen/2);
    this.LastCorner1B = DirTo2.Go(this.LastSplit1, splitterStartLen/2);
    this.LastCorner2A = DirTo1.Go(this.LastSplit2, splitterStartLen/2);
    this.LastCorner2B = DirTo2.Go(this.LastSplit2, splitterStartLen/2);
    
    this.End1A = mainDir.Go(this.LastCorner1A, splitterStartLen/2);
    this.End1B = mainDir.Go(this.LastCorner1B, splitterStartLen/2);
    this.End2A = mainDir.Go(this.LastCorner2A, splitterStartLen/2);
    this.End2B = mainDir.Go(this.LastCorner2B, splitterStartLen/2);
  }
  
  void Move() {
    this.Age++;
  }
  
  boolean IsDead() {
    return this.Age >= 30;
  }
  
  void Draw() {
    int minPal = 0;
    if (this.Age > 15) {
      minPal = min(this.Age/3 - 5, 4);
    }
    if (this.Age >= 12) {
        strokeWeight(splitterStartWeight/2);
        stroke(this.Pal[max(4, minPal)]);
        line(this.LastCorner1A.x, this.LastCorner1A.y, this.End1A.x, this.End1A.y);
        line(this.LastCorner1B.x, this.LastCorner1B.y, this.End1B.x, this.End1B.y);
        line(this.LastCorner2A.x, this.LastCorner2A.y, this.End2A.x, this.End2A.y);
        line(this.LastCorner2B.x, this.LastCorner2B.y, this.End2B.x, this.End2B.y);
    }
    if (this.Age >= 9) {
        strokeWeight(splitterStartWeight/2);
        stroke(this.Pal[max(3, minPal)]);
        line(this.LastSplit1.x, this.LastSplit1.y, this.LastCorner1A.x, this.LastCorner1A.y);
        line(this.LastSplit1.x, this.LastSplit1.y, this.LastCorner1B.x, this.LastCorner1B.y);
        line(this.LastSplit2.x, this.LastSplit2.y, this.LastCorner2A.x, this.LastCorner2A.y);
        line(this.LastSplit2.x, this.LastSplit2.y, this.LastCorner2B.x, this.LastCorner2B.y);
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
