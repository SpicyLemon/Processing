class Spot {
  float X;
  float Y;
  
  Spot(float x, float y) {
    this.X = x;
    this.Y = y;
  }
  
  Spot Copy() {
    return new Spot(this.X, this.Y);
  }
}

class Tracer {
  Spot Center;
  float Radius;
  float Angle;
  float Speed;
  Color Col;
  Spot[] history;
  int histInd;
  Palette histPal;
  
  Tracer(float x, float y) {
    this.Center = new Spot(x, y);
  }
  
  Tracer WithRadius(float radius) {
    this.Radius = radius;
    return this;
  }
  
  Tracer WithAngle(float angle) {
    this.Angle = angle;
    return this;
  }
  
  Tracer WithSpeed(float speed) {
    this.Speed = speed;
    return this;
  }
  
  Tracer WithTail(int len) {
    Spot cur = this.Cur();
    this.history = new Spot[len];
    for (int i = 0; i < this.history.length; i++) {
      this.history[i] = cur.Copy();
    }
    return this;
  }
  
  Tracer WithColor(Color col) {
    this.Col = col;
    this.histPal = new Palette(this.history.length, #000000, this.Col.Value);
    for (int i = 0; i < this.histPal.Size(); i++) {
      // at i = 0, alpha = 0.
      // at i = length, alpha = 255.
      // m = (255 - 0)/(length - 0) = 255/length
      // b = 0
      this.histPal.SetAlpha(int((float)255.0/this.histPal.Size()*(float)i));
    }
    return this;
  }
  
  Spot Cur() {
    return new Spot(
      this.Center.X + this.Radius * cos(this.Angle),
      this.Center.Y + this.Radius * sin(this.Angle)
    );
  }
  
  void normalizeAngle() {
    if (this.Angle < 0) {
      this.Angle += TWO_PI;
    }
    if (this.Angle >= TWO_PI) {
      this.Angle -= TWO_PI;
    }
  }
  
  Tracer Move() {
    // Move the current spot along the arc in the amount of the speed.
    // arc length = radius * angle, so angle = length / radius.
    this.Angle = this.Angle + this.Speed / this.Radius;
    // Keep the angle between zero and two*pi.
    this.normalizeAngle();
    
    this.histInd = (this.histInd + 1) % this.history.length;
    this.history[this.histInd] = this.Cur();
    
    if (int(random(TWO_PI*2)) == 0 || mouseWasPressed) {
      // Pick a new center on the opposite side.
      float r = random(height/2.0-5.0)+5.0;
      Spot cen = new Spot(
        this.Center.X + (this.Radius+r)*cos(this.Angle),
        this.Center.Y + (this.Radius+r)*sin(this.Angle)
      );
      // Only switch if the whole circle fits on the screen.
      if (cen.X > r && cen.X < width-r && cen.Y > r && cen.Y < height-r) {
        this.Center = cen;
        this.Radius = r;
        this.Speed *= -1;
        this.Angle += PI;
        this.normalizeAngle();
      }
    }
    return this;
  }
  
  Tracer Draw() {
    stroke(this.Col.Value);
    
    // Draw the history lines
    for (int i = 0; i < this.history.length-1; i++) {
      int pos1 = (this.histInd + i + 1) % this.history.length;
      int pos2 = (this.histInd + i + 2) % this.history.length;
      Spot s1 = this.history[pos1];
      Spot s2 = this.history[pos2];
      stroke(this.histPal.Get(i+1).Value);
      strokeWeight(40.0/(float)this.history.length * (float)i + 1.0);
      line(s1.X, s1.Y, s2.X, s2.Y);
    }

    
    noStroke();
    fill(this.Col.Value);
    // Draw the history dots
    // for (int i = 0; i < this.history.length; i++) {
    //   int pos = (this.histInd + i) % this.history.length;
    //   circle(this.history[pos].X, this.history[pos].Y, 5);
    // }
    
    // Draw the current dot.
    Spot cur = this.Cur();
    circle(cur.X, cur.Y, 5);
    
    // Draw a center dot.
    // fill(#FFFFFF);
    // circle(this.Center.X, this.Center.Y, 5);
    return this;
  }
}
