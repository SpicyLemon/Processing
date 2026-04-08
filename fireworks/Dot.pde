float _DotDefaultSize = 5;
float _DotDefaultMaxSpeed = 3;

class Dot {
  Palette Pal;
  float X;
  float Y;
  float Dx;
  float Dy;
  float MaxSpeed;
  float Size;
  int Life;
  int Age;
  
  Dot(float x, float y) {
    this.X = x;
    this.Y = y;
  }
  
  Dot(Palette pal, float x, float y, int life) {
    this.Pal = pal;
    this.X = x;
    this.Y = y;
    this.Life = life;
    this.Dx = 0.0;
    this.Dy = 0.0;
    this.MaxSpeed = _DotDefaultMaxSpeed;
    this.Size = _DotDefaultSize;
  }
  
  Dot SetSize(float size) {
    this.Size = size;
    return this;
  }
  
  Dot SetMaxSpeed(float maxSpeed) {
    this.MaxSpeed = maxSpeed;
    return this;
  }
  
  void Accelerate(float ddx, float ddy) {
    this.Dx += ddx;
    if (this.Dx > this.MaxSpeed) {
      this.Dx = this.MaxSpeed;
    }
    if (this.Dx < -this.MaxSpeed) {
      this.Dx = -this.MaxSpeed;
    }
    
    this.Dy += ddy;
    if (this.Dy > this.MaxSpeed) {
      this.Dy = this.MaxSpeed;
    }
    if (this.Dy < -this.MaxSpeed) {
      this.Dy = -this.MaxSpeed;
    }
  }
  
  void Move() {
    this.X += this.Dx;
    this.Y += this.Dy;
  }
  
  void GetOlder() {
    this.Age++;
  }
  
  void Draw() {
    if (this.Age > this.Life) {
      return; // He's dead Jim, Nothing to do.
    }
    noStroke();
    fill(this.Pal.Colors[this.Pal.Colors.length*this.Age/(this.Life+1)].Value);
    ellipse(this.X, this.Y, this.Size, this.Size);
  }
  
  boolean IsDead() {
    return this.Age > this.Life;
  }
}
