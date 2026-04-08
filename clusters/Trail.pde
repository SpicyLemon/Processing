class Point {
  float X;
  float Y;
  float Dx;
  float Dy;
  float MaxSpeed;
  
  Point(float x, float y) {
    this.X = x;
    this.Y = y;
    this.MaxSpeed = 5.0;
  }
  
  Point WithVelocity(float dx, float dy) {
    this.Dx = dx;
    this.Dy = dy;
    return this;
  }
  
  Point WithMaxSpeed(float maxSpeed) {
    this.MaxSpeed = maxSpeed;
    return this;
  }
  
  Point Move() {
    this.X += this.Dx;
    this.Y += this.Dy;
    return this;
  }
  
  Point Copy() {
    return new Point(this.X, this.Y).WithVelocity(this.Dx, this.Dy).WithMaxSpeed(this.MaxSpeed);
  }
  
  Point Accelerate(float ddx, float ddy) {
    this.Dx = minMax(this.Dx + ddx, this.MaxSpeed);    
    this.Dy = minMax(this.Dy + ddy, this.MaxSpeed);
    return this;
  }
  
  Point RestrictBounce(float minX, float maxX, float minY, float maxY) {
    if (this.X < minX) {
      this.X = minX;
      this.Dx *= -1;
    }
    if (this.X > maxX) {
      this.X = maxX;
      this.Dx *= -1;
    }
    if (this.Y < minY) {
      this.Y = minY;
      this.Dy *= -1;
    }
    if (this.Y > maxY) {
      this.Y = maxY;
      this.Dy *= -1;
    }
    return this;
  }
}

class Trail {
  Point[] Points;
  int PointsIndex;
  Color Col;
  
  Trail(Color col, Point... points) {
    this.Points = points;
    this.PointsIndex = 0;
    this.Col = col;
  }
  
  Trail(int size, Color col, float x, float y) {
    this.Points = new Point[size];
    this.PointsIndex = 0;
    this.Col = col;
    for (int i = 0; i < size; i++) {
      this.Points[i] = new Point(x, y);
    }
  }
  
  Trail WithPoints(Point... points) {
    this.Points = points;
    this.PointsIndex = 0;
    return this;
  }
  
  Trail WithColor(Color col) {
    this.Col = col;
    return this;
  }
    
  Trail ShiftIn(float x, float y) {
    this.Points[this.PointsIndex] = new Point(x, y);
    this.PointsIndex = (this.PointsIndex + 1) % this.Points.length;
    return this;
  }
  
  Trail ShiftIn(Point point) {
    this.Points[this.PointsIndex] = point;
    this.PointsIndex = (this.PointsIndex + 1) % this.Points.length;
    return this;
  }

  Trail Draw() {
    if (this.Points.length == 0) {
      return this;
    }
    
    stroke(this.Col.Value);
    fill(this.Col.Value);
    for (int i = 0; i < this.Points.length-1; i++) {
      int pos1 = (this.PointsIndex + i) % this.Points.length;
      int pos2 = (this.PointsIndex + i + 1) % this.Points.length;
      line(this.Points[pos1].X, this.Points[pos1].Y, 
           this.Points[pos2].X, this.Points[pos2].Y);
    }
    int fi = (this.PointsIndex -1 + this.Points.length) % this.Points.length;
    circle(this.Points[fi].X, this.Points[fi].Y, 2);

    return this;
  }
}

float minMax(float value, float minMax) {
  return minMax(value, -minMax, minMax);
}

float minMax(float value, float min, float max) {
  if (value < min) {
    return min;
  }
  if (value > max) {
    return max;
  }
  return value;
}
