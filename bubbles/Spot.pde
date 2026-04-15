class Spot {
  float X;
  float Y;
  float MaxRadius;
  float MinRadius;
  float DMinRadius;
  color Col;
  
  Spot(float x, float y) {
    this.X = x;
    this.Y = y;
  }
  
  Spot WithRadius(float rad) {
    this.MaxRadius = rad;
    this.MinRadius = float(int(random(rad)));
    this.DMinRadius = random(minDRadius, maxDRadius);
    if (int(random(2)) == 0) {
      this.DMinRadius *= -1;
    }
    return this;
  }
  
  Spot WithColor(color col) {
    this.Col = col;
    return this;
  }
  
  Spot(Spot orig) {
    this.X = orig.X;
    this.Y = orig.Y;
    this.MaxRadius = orig.MaxRadius;
    this.MinRadius = orig.MinRadius;
    this.DMinRadius = orig.DMinRadius;
    this.Col = orig.Col;
  }
  
  Spot Copy() {
    return new Spot(this);
  }
  
  Spot Iterate() {
    this.MinRadius += this.DMinRadius;
    if (this.MinRadius >= this.MaxRadius) {
      this.MinRadius = this.MaxRadius;
      this.DMinRadius = 0;
      if (int(random(changeOdds)) == 0) {
        this.Col = randomFadedColor();
        this.DMinRadius = -random(minDRadius, maxDRadius);
      }
    } else if (this.MinRadius <= 0) {
      this.MinRadius = 0;
      this.DMinRadius = 0;
      if (int(random(changeOdds)) == 0) {
        this.DMinRadius = random(minDRadius, maxDRadius);
      }
    }
    return this;
  }
  
  Spot Draw() {
    noStroke();
    fill(this.Col);
    for (float r = this.MaxRadius*2; r > this.MinRadius*2; r--) {
      circle(this.X, this.Y, r);
    }
    return this;
  }
}
