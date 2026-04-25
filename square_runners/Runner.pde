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
  
  Cell Copy() {
    return new Cell(this.X, this.Y);
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
  boolean homing;
  int dX;
  int dY;
  Cell Target;
 
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
      this.MoveToTarget();
    } else if (this.roaming) {
      this.Roam();
      if (this.DistanceHomeToTarget() == this.DistanceCurToTarget()) {
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
  
  Runner StartRoaming(Cell target) {
    this.homing = false;
    this.roaming = true;
    this.Target = target;
    return this;
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
  
  void Roam() {
    // Just starting. Set dX or dY based on side.
    // Note: If this is on a corner, the dx and dy will
    // move it to the next spot clockwise. Then next time
    // it'll go through this again to break free of the wall.
    if (this.Cur.Y == yResMin && this.Cur.X > xResMin) {
      // Top side
      this.dY = 1;
      this.dX = 0;
    } else if (this.Cur.X == xResMax && this.Cur.Y > yResMin) {
      // Right Side
      this.dX = -1;
      this.dY = 0;
    } else if (this.Cur.Y == yResMax && this.Cur.X < xResMax) {
      // Bottom
      this.dY = -1;
      this.dX = 0;
    } else if (this.Cur.X == xResMin && this.Cur.Y < yResMax) {
      // Left
      this.dX = 1;
      this.dY = 0;
    } else {
      boolean changeDir = int(random(changeDirOdds)) == 0
                          || (this.Cur.X <= xResMin+1 && this.dX < 0)
                          || (this.Cur.X >= xResMax-1 && this.dX > 0)
                          || (this.Cur.Y <= yResMin+1 && this.dY < 0)
                          || (this.Cur.Y >= yResMax-1 && this.dY > 0);
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
            this.dX = -1;
          }
        }
      }
    }
    
    this.Cur.X += this.dX;
    this.Cur.Y += this.dY;  
  }
  
  void MoveToTarget() {
    if (this.Cur.X == this.Target.X) {
      this.dX = 0;
      if (this.Cur.Y < this.Target.Y) {
        this.dY = 1;
      } else {
        this.dY = -1;
      }
    } else if (this.Cur.Y == this.Target.Y) {
      this.dY = 0;
      if (this.Cur.X < this.Target.X) {
        this.dX = 1;
      } else {
        this.dX = -1;
      }
    }
    // TODO: Finish MoveToTarget.
  }
  
  int DistanceCurToTarget() {
    return TaxiDistance(this.Cur, this.Target);
  }
  
  int DistanceHomeToTarget() {
    return EdgeDistance(this.Home, this.Target);
  }
  
  boolean AtHome() {
    return this.Cur.X == this.Home.X && this.Cur.Y == this.Home.Y;
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
  
  Runner DrawTarget() {
    if (this.Target != null) {
      stroke(#FFFFFF);
      Spot spot = this.Target.Spot();
      point(spot.X, spot.Y);
    }
    return this;
  }
}

// TaxiDistance returns the number of steps needed to get from
// (x1, y1) to (x2, y2) moving only up/down/left/right.
int TaxiDistance(int x1, int y1, int x2, int y2) {
  return abs(x1 - x2) + abs(y1 - y2);
}
int TaxiDistance(Cell a, Cell b) {
  return TaxiDistance(a.X, a.Y, b.X, b.Y);
}

// EdgeDistance returns the number of Move()s required to get from
// (x1, y1) to (x2, y2), traveling clockwise around the
// perimeter defined by xResMin, xResMax, yResMin, yResMax
int EdgeDistance(int x1, int y1, int x2, int y2) {
  int a = PerimeterPos(x1, y1);
  int b = PerimeterPos(x2, y2);
  return ((b - a) % perimeter + perimeter) % perimeter;
}
int EdgeDistance(Cell a, Cell b) {
  return EdgeDistance(a.X, a.Y, b.X, b.Y);
}

// PerimeterPos returns the clockwise position along the perimeter,
// measured from (xResMin, yResMin). Assumes (px, py) is on the perimeter.
int PerimeterPos(int px, int py) {
  if (py == yResMin) {
    // Top edge: 0 .. w
    return px - xResMin;
  }
  if (px == xResMax) {
    // Right edge: w .. w + h
    return xRes + (py - yResMin);
  }
  if (py == yResMax) {
    // Bottom edge: w + h .. 2w + h
    return xRes + yRes + (xResMax - px);
  }
  // Left edge: 2w + h .. 2w + 2h
  return 2 * xRes + yRes + (yResMax - py);
}

// CellFromPerimeterPos returns the Cell at the given clockwise position
// along the perimeter, measured from (xResMin, yResMin).
// This is the inverse of perimeterPos. Position 0 => (xResMin, yResMin).
Cell CellFromPerimeterPos(int pos) {
  // Normalize into [0, perimeter) so negatives and overflows wrap correctly.
  int p = ((pos % perimeter) + perimeter) % perimeter;
  
  if (p < xRes) {
    // Top edge: 0 .. w-1
    return new Cell(xResMin + p, yResMin);
  }
  if (p < xRes + yRes) {
    // Right edge: w .. w+h-1
    return new Cell(xResMax, yResMin + (p - xRes));
  }
  if (p < 2 * xRes + yRes) {
    // Bottom edge: w+h .. 2w+h-1
    return new Cell(xResMax - (p - xRes - yRes), yResMax);
  }
  // Left edge: 2w+h .. 2w+2h-1
  return new Cell(xResMin, yResMax - (p - 2 * xRes - yRes));
}

boolean IsCorner(Cell cell) {
  return (cell.X == xResMin && cell.Y == yResMin)
      || (cell.X == xResMin && cell.Y == yResMax)
      || (cell.X == xResMax && cell.Y == yResMin)
      || (cell.X == xResMax && cell.Y == yResMax);
}
