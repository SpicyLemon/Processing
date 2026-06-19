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
  
  String ToString() {
    return "(" + this.X + ", " + this.Y + ")";
  }
}

class Tracer {
  Spot Center;
  float Radius;
  float DRadius;
  float Angle;
  float Speed;
  color Col;
  float Stroke;
  float Size;
  Spot[] history;
  int histInd;
  Palette histPal;
  float strokeMult;
  int radiusHold;
  
  String ToString() {
    return hex(this.Col, 6) + ": " 
           + this.Cur().ToString() + " <= " 
           + this.Center.ToString() + " r=" + this.Radius + " dr=" + this.DRadius;
  }
  
  Tracer(float x, float y) {
    this.Center = new Spot(x, y);
    this.Stroke = 8.0;
    this.Size = 5.0;
  }
  
  Tracer WithRadius(float radius) {
    this.Radius = radius;
    return this;
  }
  
  Tracer WithDRadius(float dRadius) {
    this.DRadius = dRadius;
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
    if (len > 0) {
      this.strokeMult = this.Stroke/(float)this.history.length;
    } else {
      this.strokeMult = 0;
    }
    return this;
  }
  
  Tracer WithColor(color col) {
    this.Col = col;
    this.histPal = new Palette(this.history.length, #000000, this.Col);
    return this;
  }
  
  Tracer WithStroke(float stroke) {
    this.Stroke = stroke;
    if (this.history != null && this.history.length > 0) {
      this.strokeMult = this.Stroke/(float)this.history.length;
    } else {
      this.strokeMult = 0;
    }
    return this;
  }
  
  Tracer WithSize(float size) {
    this.Size = size;
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
  
  Tracer Move(boolean forceDirChange) {
    // Adjust the radius. If it gets to the minRadius, just make it grow again.
    // If it gets to the max, hold it at the max for two frames, then make it shrink again.
    if (this.radiusHold > 0) {
      this.radiusHold--;
      if (this.radiusHold == 0) {
        this.DRadius *= -1;
        this.Radius += this.DRadius;
      }
    } else if (this.Radius < minRadius && this.DRadius <= 0) {
      this.DRadius *= -1;
      this.Radius += this.DRadius;
    } else if (!isInLimits(this.Center.X, this.Center.Y, this.Radius) && this.DRadius >= 0) {
      this.radiusHold = 3;
    } else {
      this.Radius += this.DRadius;
    }
    
    // Move the current spot along the arc in the amount of the speed.
    // arc length = radius * angle, so angle = length / radius.
    this.Angle = this.Angle + this.Speed / this.Radius;
    // Keep the angle between zero and two*pi.
    this.normalizeAngle();
    
    this.histInd = (this.histInd + 1) % this.history.length;
    this.history[this.histInd] = this.Cur();
    
    if (forceDirChange || int(random(changeDirOdds)) == 0) {
      // Pick a new center on the opposite side.
      float r = randomRadius();
      Spot cen = new Spot(
        this.Center.X + (this.Radius+r)*cos(this.Angle),
        this.Center.Y + (this.Radius+r)*sin(this.Angle)
      );
      // Only switch if the whole circle fits on the screen.
      if (isInLimits(cen.X, cen.Y, r)) {
        this.Center = cen;
        this.Radius = r;
        this.Speed *= -1;
        this.Angle += PI;
        this.normalizeAngle();
        this.DRadius = randomDRadius();
      }
    }
    return this;
  }
  
  Tracer Draw() {
    stroke(this.Col);
    
    // Draw the history lines
    for (int i = 0; i < this.history.length-1; i++) {
      this.DrawI(i);
    }
    
    // Draw the current dot.
    this.DrawDot();
    
    return this;
  }
  
  Tracer DrawI(int i) {
    int pos1 = (this.histInd + i + 1) % this.history.length;
    int pos2 = (this.histInd + i + 2) % this.history.length;
    Spot s1 = this.history[pos1];
    Spot s2 = this.history[pos2];
    stroke(this.histPal.Get(i+1).Value);
    strokeWeight(this.strokeMult * (float)i + 1.0);
    line(s1.X, s1.Y, s2.X, s2.Y);
    return this;
  }
  
  Tracer DrawDot() {
    if (this.Size > 0.0001) {
      noStroke();
      fill(this.Col);
      Spot cur = this.Cur();
      circle(cur.X, cur.Y, this.Size);
    }
    
    return this;
  }
}
