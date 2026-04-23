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
  int HomeX;
  int HomeY;
  Spot[] history;
  int histInd;
  Palette histPal;
  boolean roaming;
  int toRoam;
  boolean homing;
  int dX;
  int dY;
  int targetX;
  int targetY;
 
  Runner(int x, int y, color col, int len) {
    this.X = x;
    this.Y = y;
    this.HomeX = x;
    this.HomeY = y;
    this.history = new Spot[len];
    this.histPal = new Palette(len, runnerEndColor, col);
    this.history[0] = this.Cur();
  }
  
  Runner Move() {
    this.MoveHome();
    if (this.homing) {
    } else if (this.roaming) {
      if (this.AtHome()) {
        // Just starting. Set dX or dY based on side.
        // Note: If this is on a corner, the dx and dy will
        // move it to the next spot clockwise. Then next time
        // it'll go through this again to break free of the wall.
        if (this.Y == yResMin && this.X > xResMin) {
          // Top side
          this.dY = 1;
        } else if (this.X == xResMax && this.Y > yResMin) {
          // Right Side
          this.dX = -1;
        } else if (this.Y == yResMax && this.X < yResMax) {
          // Bottom
          this.dY = -1;
        } else if (this.X == xResMin && this.Y < yResMax) {
          // Left
          this.dX = 1;
        }
      } else {
        boolean changeDir = int(random(changeDirOdds)) == 0
                            || (this.X == xResMin+1 && this.dX < 0)
                            || (this.X == xResMax-1 && this.dX > 0)
                            || (this.Y == yResMin+1 && this.dY < 0)
                            || (this.Y == yResMax-1 && this.dY > 0);
        if (changeDir) {
          if (this.dX != 0) {
            this.dX = 0;
            if (int(random(2)) == 0) {
              this.dY = -1;
            } else {
              this.dY = 1;
            }
          } else {
            this.dY = 0;
            if (int(random(2)) == 0) {
              this.dX = -1;
            } else {
              this.dY = 1;
            }
          }
        }
      }
      
      this.X += this.dX;
      this.Y += this.dY;

      this.toRoam--;
      if (this.toRoam <= 0) {
        this.roaming = false;
        this.homing = true;
      }
    } else {
      this.X = HomeX;
      this.Y = HomeY;
    }
    
    this.histInd = (this.histInd + 1) % this.history.length;
    this.history[this.histInd] = this.Cur();
    return this;
  }
  
  Runner StartRoaming(int steps) {
    this.homing = false;
    this.roaming = true;
    this.toRoam = steps;
    return this;
  }
  
  // StartHoming returns true if a suitable home target is found and homing can start.
  boolean StartHoming() {
    this.roaming = false;
    // TODO: Identify a target (x, y) to move towards.
    //       The target will be the same distance away from
    //       both (X, Y) and (HomeX, HomeY).
    return true;
  }
  
  void MoveHome() {
    if (this.HomeY == yResMin) {
      if (this.HomeX < xResMax) {
        this.HomeX++;
      } else {
        this.HomeY++;
      }
    } else if (this.HomeX == xResMax) {
      if (this.HomeY < yResMax) {
        this.HomeY++;
      } else {
        this.HomeX--;
      }
    } else if (this.HomeY == yResMax) {
      if (this.HomeX > xResMin) {
        this.HomeX--;
      } else {
        this.HomeY--;
      }
    } else if (this.HomeX == xResMin) {
      if (this.HomeY > yResMin) {
        this.HomeY--;
      } else {
        this.HomeX++;
      }
    }
  }
  
  Spot Cur() {
    return new Spot(xLimMin + float(this.X) * dotSpace,
                    yLimMin + float(this.Y) * dotSpace);
  }
  
  int DistanceHome() {
    return abs(this.X - this.HomeX) + abs(this.Y - this.HomeY);
  }
  
  boolean AtHome() {
    return this.X == this.HomeX && this.Y == this.HomeY;
  }
  
  // EdgeDistance returns the number of Move()s required to get from
  // (this.HomeX, this.HomeY) to (x, y), traveling clockwise around the
  // perimeter defined by xResMin, xResMax, yResMin, yResMax.
  int EdgeDistance(int x, int y) {
    int w = xResMax - xResMin;
    int h = yResMax - yResMin;
    int perimeter = 2 * w + 2 * h;
    int f = perimeterPos(this.HomeX, this.HomeY, w, h);
    int t = perimeterPos(x, y, w, h);
    return ((t - f) % perimeter + perimeter) % perimeter;
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

// perimeterPos returns the clockwise position along the perimeter,
// measured from (xResMin, yResMin). Assumes (px, py) is on the perimeter.
int perimeterPos(int px, int py, int w, int h) {
  if (py == yResMin) {
    // Top edge: 0 .. w
    return px - xResMin;
  }
  if (px == xResMax) {
    // Right edge: w .. w + h
    return w + (py - yResMin);
  }
  if (py == yResMax) {
    // Bottom edge: w + h .. 2w + h
    return w + h + (xResMax - px);
  }
  // Left edge: 2w + h .. 2w + 2h
  return 2 * w + h + (yResMax - py);
}
