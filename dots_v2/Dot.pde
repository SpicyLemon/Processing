color _DefaultDotColor = #FFFFFF;
float _DefaultDotSize = 5;
float _SpeedMax = 3;

class Dot {
  float X;
  float Y;
  float Dx;
  float Dy;

  Color Color;

  float Size;
  
  Dot() {
    this(0, 0, _DefaultDotColor, _DefaultDotSize);
  }
  
  Dot(float x, float y) {
    this(x, y, _DefaultDotColor, _DefaultDotSize);
  }
  
  Dot(float x, float y, color col) {
    this(x, y, col, _DefaultDotSize);
  }
  
  Dot(float x, float y, Color col) {
    this(x, y, col, _DefaultDotSize);
  }
  
  Dot(float x, float y, color col, float size) {
    this(x, y, new Color(col), size);
  }
  
  Dot(float x, float y, Color col, float size) {
    this.X = x;
    this.Y = y;
    this.SetSpeed(0, 0);
    this.Color = col;
    this.Size = size;
  }
  
  // Copy returns a copy of this dot with the same location, size, and color instance, but no velocity.
  Dot Copy() {
    return new Dot(this.X, this.Y, this.Color, this.Size);
  }
  
  void SetSpeed(float dx, float dy) {
    this.Dx = dx;
    this.Dy = dy;
  }
  
  void SetColor(color col) {
    this.Color.Value = col;
  }
  
  void SetColor(Color col) {
    this.Color = col;
  }
  
  void Accelerate(float ddx, float ddy) {
    this.Dx += ddx;
    if (this.Dx > _SpeedMax) {
      this.Dx = _SpeedMax;
    }
    if (this.Dx < -_SpeedMax) {
      this.Dx = -_SpeedMax;
    }
    
    this.Dy += ddy;
    if (this.Dy > _SpeedMax) {
      this.Dy = _SpeedMax;
    }
    if (this.Dy < -_SpeedMax) {
      this.Dy = -_SpeedMax;
    }
  }
  
  void Move() {
    // this.MoveBounce();
    this.MoveTrans();
  }
  
  // MoveTrans moves the dot, transferring it to the opposite side when it hits one.
  void MoveTrans() {
    this.X += this.Dx % width;
    if (this.X >= width) {
      this.X -= width;
    }
    if (this.X < 0) {
      this.X += width;
    }

    this.Y += this.Dy % height;
    if (this.Y >= height) {
      this.Y -= height;
    }
    if (this.Y < 0) {
      this.Y += height;
    }
  }
  
  // MoveBounce moves the dot, making them bounce of the edges.
  void MoveBounce() {
    this.X += this.Dx % width;
    if (this.X >= width) {
      this.X = width - (this.X - width);
      this.Dx *= -1;
    }
    if (this.X < 0) {
      this.X *= -1;
      this.Dx *= -1;
    }
    
    this.Y += this.Dy % height;
    if (this.Y >= height) {
      this.Y = height - (this.Y - height);
      this.Dy *= -1;
    }
    if (this.Y < 0) {
      this.Y *= -1;
      this.Dy *= -1;
    }
  }
  
  void ColorShift(int dred, int dgreen, int dblue) {
    this.Color.AddRGB(dred, dgreen, dblue);
  }
  
  void Draw() {
    noStroke();
    fill(this.Color.Value);
    ellipse(this.X, this.Y, this.Size, this.Size);
  }
}
