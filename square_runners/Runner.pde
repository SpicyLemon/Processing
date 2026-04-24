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

class Cell {
  int X;
  int Y;
  
  Cell(int x, int y) {
    this.X = x;
    this.Y = y;
  }
 
  Spot Spot() {
    return new Spot(xLimMin + float(this.X) * dotSpace,
                    yLimMin + float(this.Y) * dotSpace);
  }
}

class Runner {
  Cell Cur;
  Cell Home;
  Spot[] history;
  int histInd;
  Palette histPal;
  boolean roaming;
  int toRoam;
  boolean homing;
  int dX;
  int dY;
 
  Runner(int x, int y, color col, int len) {
    this.Cur = new Cell(x, y);
    this.Home = new Cell(x, y);
    this.history = new Spot[len];
    this.histPal = new Palette(len, runnerEndColor, col);
    this.history[0] = this.Cur.Spot();
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
        if (this.Cur.Y == yResMin && this.Cur.X > xResMin) {
          // Top side
          this.dY = 1;
        } else if (this.Cur.X == xResMax && this.Cur.Y > yResMin) {
          // Right Side
          this.dX = -1;
        } else if (this.Cur.Y == yResMax && this.Cur.X < yResMax) {
          // Bottom
          this.dY = -1;
        } else if (this.Cur.X == xResMin && this.Cur.Y < yResMax) {
          // Left
          this.dX = 1;
        }
      } else {
        boolean changeDir = int(random(changeDirOdds)) == 0
                            || (this.Cur.X == xResMin+1 && this.dX < 0)
                            || (this.Cur.X == xResMax-1 && this.dX > 0)
                            || (this.Cur.Y == yResMin+1 && this.dY < 0)
                            || (this.Cur.Y == yResMax-1 && this.dY > 0);
        if (changeDir) {
          if (this.dX != 0) {
            this.dX = 0;
            if (this.Cur.Y <= yResMin+1) {
              this.dY = 1;
            } else if (this.Cur.Y >= yResMax-1) {
              this.dY = -1;
            } else if (int(random(2)) == 0) {
              this.dY = 1;
            } else {
              this.dY = -1;
            }
          } else {
            this.dY = 0;
            if (this.Cur.X <= xResMin+1) {
              this.dX = 1;
            } else if (this.Cur.X >= xResMax-1) {
              this.dX = -1;
            } else if (int(random(2)) == 0) {
              this.dX = 1;
            } else {
              this.dY = -1;
            }
          }
        }
      }
      
      this.Cur.X += this.dX;
      this.Cur.Y += this.dY;

      this.toRoam--;
      if (this.toRoam <= 0) {
        this.roaming = false;
        this.homing = true;
      }
    } else {
      this.Cur.X = this.Home.X;
      this.Cur.Y = this.Home.Y;
    }
    
    this.histInd = (this.histInd + 1) % this.history.length;
    this.history[this.histInd] = this.Cur.Spot();
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
    if (this.Home.Y == yResMin) {
      if (this.Home.X < xResMax) {
        this.Home.X++;
      } else {
        this.Home.Y++;
      }
    } else if (this.Home.X == xResMax) {
      if (this.Home.Y < yResMax) {
        this.Home.Y++;
      } else {
        this.Home.X--;
      }
    } else if (this.Home.Y == yResMax) {
      if (this.Home.X > xResMin) {
        this.Home.X--;
      } else {
        this.Home.Y--;
      }
    } else if (this.Home.X == xResMin) {
      if (this.Home.Y > yResMin) {
        this.Home.Y--;
      } else {
        this.Home.X++;
      }
    }
  }
  
  int DistanceHome() {
    return abs(this.Cur.X - this.Home.X) + abs(this.Cur.Y - this.Home.Y);
  }
  
  boolean AtHome() {
    return this.Cur.X == this.Home.X && this.Cur.Y == this.Home.Y;
  }
  
  // EdgeDistance returns the number of Move()s required to get from
  // (this.HomeX, this.HomeY) to (x, y), traveling clockwise around the
  // perimeter defined by xResMin, xResMax, yResMin, yResMax.
  int EdgeDistance(int x, int y) {
    int f = perimeterPos(this.Home.X, this.Home.Y, xRes, yRes);
    int t = perimeterPos(x, y, xRes, yRes);
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
