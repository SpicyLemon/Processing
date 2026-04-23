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

class Runner {
  int X;
  int Y;
  Spot[] history;
  int histInd;
  Palette histPal;
 
  Runner(int x, int y, color col, int len) {
    this.X = x;
    this.Y = y;
    this.history = new Spot[len];
    this.histPal = new Palette(len, runnerEndColor, col);
    this.history[0] = this.Cur();
  }
  
  Runner Move() {
    if (this.Y == yResMin) {
      if (this.X < xResMax) {
        this.X++;
      } else {
        this.Y++;
      }
    } else if (this.X == xResMax) {
      if (this.Y < yResMax) {
        this.Y++;
      } else {
        this.X--;
      }
    } else if (this.Y == yResMax) {
      if (this.X > xResMin) {
        this.X--;
      } else {
        this.Y--;
      }
    } else if (this.X == xResMin) {
      if (this.Y > yResMin) {
        this.Y--;
      } else {
        this.X++;
      }
    }
    
    this.histInd = (this.histInd + 1) % this.history.length;
    this.history[this.histInd] = this.Cur();
    return this;
  }
  
  Spot Cur() {
    return new Spot(xLimMin + float(this.X) * dotSpace,
                    yLimMin + float(this.Y) * dotSpace);
  }
  
  Runner DrawI(int i) {
    int pos = (this.histInd + i + 1) % this.history.length;
    Spot spot = this.history[pos];
    if (spot != null) {
      stroke(this.histPal.Get(i).Value);
      point(spot.X, spot.Y);
    }
    return this;
  }
}
