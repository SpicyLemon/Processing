class Puddle {
  PVector Center;
  PVector UpperLeft;
  PVector UpperRight;
  PVector LowerLeft;
  PVector LowerRight;
  color[] Pal;
  int Age;
  
  Puddle(PVector center, float size, color[] pal) {
    this.Center = center.copy();
    this.UpperLeft = new PVector(center.x - size, center.y - size);
    this.UpperRight = new PVector(center.x + size, center.y - size);
    this.LowerLeft = new PVector(center.x - size, center.y + size);
    this.LowerRight = new PVector(center.x + size, center.y + size);
    this.Pal = pal;
  }
  
  void Move() {
    this.Age++;
  }
  
  boolean IsDead() {
    return this.Age >= 6;
  }
  
  void Draw() {
    if (this.Age < 6) {
      strokeWeight(1);
      PVector ul = PVector.add(this.Center, this.UpperLeft).mult(0.5);
      PVector ur = PVector.add(this.Center, this.UpperRight).mult(0.5);
      PVector ll = PVector.add(this.Center, this.LowerLeft).mult(0.5);
      PVector lr = PVector.add(this.Center, this.LowerRight).mult(0.5);
      if (this.Age >= 2) {
        stroke(this.Pal[0]);
        line(this.UpperLeft.x, this.UpperLeft.y, ul.x, ul.y);
        line(this.UpperRight.x, this.UpperRight.y, ur.x, ur.y);
        line(this.LowerLeft.x, this.LowerLeft.y, ll.x, ll.y);
        line(this.LowerRight.x, this.LowerRight.y, lr.x, lr.y);
      }
      if (this.Age < 4) {
        stroke(this.Pal[2]);
        line(ul.x, ul.y, lr.x, lr.y);
        line(ur.x, ur.y, ll.x, ll.y);
      }
    }
  }
}
