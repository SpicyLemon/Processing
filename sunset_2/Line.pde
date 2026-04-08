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

class VLine {
  float X1;
  float Y1;
  float X2;
  float Y2;
  
  VLine(float x1, float y1, float x2, float y2) {
    this.X1 = x1;
    this.Y1 = y1;
    this.X2 = x2;
    this.Y2 = y2;
  }
  
  VLine Draw() {
    line(this.X1, this.Y1, this.X2, this.Y2);
    return this;
  }
}

class Star {
  float X;
  float Y;
  Color Col;
  float Size;
  int LifeMax;
  int LifeLeft;
  int HalfLife;
  
  Star(float x, float y, float size, color col, int life) {
    this.X = x;
    this.Y = y;
    this.Size = size;
    this.Col = new Color(col).SetAlpha(0);
    this.LifeMax = life;
    this.LifeLeft = life;
    this.HalfLife = life/2;
  }
  
  Star Age() {
    this.LifeLeft--;
    if (this.LifeLeft > this.HalfLife) {
      this.Col.SetAlpha(int(map(this.LifeLeft, this.LifeMax, this.HalfLife, 0, 200)));
    } else {
      this.Col.SetAlpha(int(map(this.LifeLeft, this.HalfLife, 0, 200, 0)));
    }
    return this;
  }
  
  boolean IsDead() {
    return this.LifeLeft < 0;
  }
  
  Star Draw() {
    noStroke();
    fill(this.Col.Value);
    circle(this.X, this.Y, this.Size);
    return this;
  }
}

class Ground {
  float X;
  float Y;
  float DX;
  float DY;
  float Size;
  color Col;
  
  Ground(float x, float y, float size, color col) {
    this.X = x;
    this.Y = y;
    this.Size = size;
    this.Col = col;
  }
  
  Ground WithVelocity(float dx, float dy) {
    this.DX = dx; 
    this.DY = dy;
    return this;
  }

  Ground Accelerate(float ddx, float ddy) {
    this.DX += ddx;
    this.DY += ddy;
    return this;
  }
  
  Ground Move() {
    this.X += this.DX;
    this.Y += this.DY;
    return this;
  }
  
  boolean IsDead() {
    return this.X < -this.Size || this.X > width+this.Size || this.Y > height;
  }
  
  Ground Draw() {
    noStroke();
    fill(this.Col);
    circle(this.X, this.Y, this.Size);
    return this;
  }
}
