class Line {
  float Y;
  float DY;

  Line(float y) {
    this.Y = y;
  }
  
  Line WithVelocity(float dy) {
    this.DY = dy;
    return this;
  }
  
  Line Accelerate(float ddy) {
    this.DY += ddy;
    return this;
  }
  
  Line Move() {
    this.Y += this.DY;
    return this;
  }
}
