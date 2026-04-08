class Point {
  float X;
  float Y;
  float DX;
  float DY;
  
  Point(float x, float y) {
    this.X = x;
    this.Y = y;
  }
  
  Point WithVelocity(float dx, float dy) {
    this.DX = dx;
    this.DY = dy;
    return this;
  }
  
  Point(Point orig) {
    this.X = orig.X;
    this.Y = orig.Y;
    this.DX = orig.DX;
    this.DY = orig.DY;
  }
  
  Point Copy() {
    return new Point(this);
  }
  
  Point Accelerate(float ddx, float ddy, float maxD) {
    this.DX = min(max(this.DX+ddx, -maxD), maxD);
    this.DY = min(max(this.DY+ddy, -maxD), maxD);
    return this;
  }
  
  Point Move() {
    this.X += this.DX;
    if (this.X <= xLimMin && this.DX < 0) {
      this.DX /= 2;
    } else if (this.X >= xLimMax && this.DX > 0) {
      this.DX /= 2;
    }
    
    this.Y += this.DY;
    if (this.Y <= yLimMin && this.DY < 0) {
      this.DY /= 2;
    } else if (this.Y >= yLimMax && this.DY > 0) {
      this.DY /= 2;
    }
    
    return this;
  }
}

class Trail {
  Point[] Points;
  color Col;
  
  Trail(int count, color col) {
    this.Points = new Point[count];
    this.Points[0] = new Point(random(xLimMax), random(yLimMax))
                    .WithVelocity(random(dMax), random(dMax));
    for (int i = 1; i < pointCount; i++) {
      this.Points[i] = this.Points[i-1]
                      .Copy()
                      .Accelerate(random(-ddMax, ddMax), random(-ddMax, ddMax), dMax)
                      .Move();
    }
    this.Col = col;
  }
}
