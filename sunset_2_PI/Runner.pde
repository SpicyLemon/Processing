class Spot {
  float X;
  float Y;
  
  Spot(float x, float y) {
    this.X = x;
    this.Y = y;
  }
}

class Runner {
  Spot[] Hist;
  int HistI;
  color Col;
  float SizeMin;
  float SizeMax;
  float SpeedMult;
  
  Runner(float x, float y, color col, int len) {
    this.Hist = new Spot[len];
    for (int i = 0; i < len; i++) {
      this.Hist[i] = new Spot(x, y);
    }
    this.HistI = 0;
    this.Col = col;
    this.SpeedMult = 1;
  }
  
  Runner WithSize(float sizeMin, float sizeMax) {
    this.SizeMin = sizeMin;
    this.SizeMax = sizeMax;
    return this;
  }
  
  Runner WithSpeed(float speedMult) {
    this.SpeedMult = speedMult;
    return this;
  }
  
  Spot Cur() {
    return this.Hist[this.HistI];
  }
  
  Runner Move() {
    Spot cur = this.Cur();
    int y = int(cur.Y-centerY);
    int x = int(cur.X);
    int m = -1; // Opposite of the grounds becasue we're going the other way.
    if (x > centerX) {
      x = int(pg.width - x);
      m = 1;
    }
    float dy = 0.0;
    float dx = 0.0;
    if (y >= 0 && y < dys.length) {
      dy = -dys[y];
      dx = m*dxs[y][x];
    }
    int nextI = (this.HistI + 1) % this.Hist.length;
    this.Hist[nextI].X = cur.X + dx*this.SpeedMult;
    this.Hist[nextI].Y = cur.Y + dy*this.SpeedMult;
    this.HistI = nextI;
    this.SizeMax *= pow(0.99, this.SpeedMult);
    this.SizeMin *= pow(0.99, this.SpeedMult);
    return this;
  }
  
  Runner Draw(color headColor) {
    Spot head = this.Hist[this.HistI];
    if (head.Y > centerY) {
      pg.fill(headColor);
      pg.stroke(headColor);
      pg.circle(this.Hist[this.HistI].X, this.Hist[this.HistI].Y, this.SizeMax);
    }
    pg.stroke(this.Col);
    for (int i = this.Hist.length-2; i >= 0; i--) {
      int j = (this.HistI + i + 1) % this.Hist.length;
      int k = (j + 1) % this.Hist.length;
      if (this.Hist[k].Y < centerY) {
        continue;
      }
      pg.strokeWeight(map(i, 0, this.Hist.length-1, this.SizeMin, this.SizeMax));
      pg.line(this.Hist[j].X, this.Hist[j].Y, this.Hist[k].X, this.Hist[k].Y);
    }
    return this;
  }
  
  boolean IsDead() {
    int lastI = (this.HistI + 1) % this.Hist.length;
    return this.Hist[lastI].Y <= centerY;
  }
}
  
