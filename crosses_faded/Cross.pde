class Point {
  float X;
  float Y;
  float Dx;
  float Dy;

  Point(float x, float y) {
    this.X = x;
    this.Y = y;
  }
  
  Point WithVelocity(float dx, float dy) {
    this.Dx = dx; 
    this.Dy = dy;
    return this;
  }
  
  Point(Point orig) {
    this.X = orig.X;
    this.Y = orig.Y;
    this.Dx = orig.Dx;
    this.Dy = orig.Dy;
  }
  
  Point Copy() {
    return new Point(this);
  }
  
  boolean Equals(Point that) {
    if (this == that) {
      return true;
    }
    if (that == null) {
      return false;
    }
    return roughlyEqual(this.X, that.X) && roughlyEqual(this.Y, that.Y);
  }
  
  Point Accelerate(float ddx, float ddy, float maxD) {
    this.Dx += ddx;
    if (this.Dx > maxD) {
      this.Dx = maxD;
    } else if (this.Dx < -maxD) {
      this.Dx = -maxD;
    }
    
    this.Dy += ddy;
    if (this.Dy > maxD) {
      this.Dy = maxD;
    } else if (this.Dy < -maxD) {
      this.Dy = -maxD;
    }
    
    return this;
  }
  
  Point Move() {
    this.X += this.Dx;
    if (this.X <= xLimMin && this.Dx < 0) {
      this.Dx /= 2;
    } else if (this.X >= xLimMax && this.Dx > 0) {
      this.Dx /= 2;
    }
    
    this.Y += this.Dy;
    if (this.Y <= yLimMin && this.Dy < 0) {
      this.Dy /= 2;
    } else if (this.Y >= yLimMax && this.Dy > 0) {
      this.Dy /= 2;
    }
    
    return this;
  }
}

boolean roughlyEqual(float a, float b) {
  return abs(a-b) < 0.0001;
}

class CrossHist {
  Point L1p1;
  Point L1p2;
  Point L2p1;
  Point L2p2;
  
  CrossHist(Point l1p1, Point l1p2, Point l2p1, Point l2p2) {
    this.L1p1 = l1p1;
    this.L1p2 = l1p2;
    this.L2p1 = l2p1;
    this.L2p2 = l2p2;
  }
}

class Cross {
  Point Center;
  Point Other;
  CrossHist[] Hist;
  int HistIndex;
  color Col;
  
  Cross(float x1, float y1, float x2, float y2) {
    this.Center = new Point(x1, y1);
    this.Other = new Point(x2, y2);
  }
  
  Cross WithColor(color col, int histLen) {
    this.Col = col;
    this.Hist = new CrossHist[histLen];
    this.HistIndex = -1;
    return this;
  }
  
  Cross Accelerate() {
    this.Center.Accelerate(random(-0.5, 0.5), random(-0.5, 0.5), centerMaxD);
    this.Other.Accelerate(random(-1, 1), random(-1, 1), otherMaxD);
    return this;
  }
  
  Cross Move() {
    this.Center.Move();
    this.Other.Move();
    if (this.Center.Equals(this.Other)) {
      return this;
    }
    
    Point l1p1 = calcEdgePoint(this.Center, this.Other);
    Point l1p2 = calcEdgePoint(this.Other, this.Center);
    Point third = calcThird(this.Center, this.Other);
    Point l2p1 = calcEdgePoint(this.Center, third);
    Point l2p2 = calcEdgePoint(third, this.Center);
    
    this.HistIndex = (this.HistIndex + 1) % this.Hist.length;
    this.Hist[this.HistIndex] = new CrossHist(l1p1, l1p2, l2p1, l2p2);

    return this;
  }
  
  Cross Draw() {
    strokeWeight(3.0);
    for (int i = 0; i < this.Hist.length; i++) {
      this.DrawHist(i);
    }
    return this;
  }
  
  Cross DrawHist(int i) {
    CrossHist h1 = this.Hist[(i + this.HistIndex+1) % this.Hist.length];
    if (h1 == null) {
      return this;
    }
    
    int c = this.Hist.length-1-i;
    if (c == 0) {
      // If we're on color 0, just draw the cross.
      stroke(this.Col);
      line(h1.L1p1.X, h1.L1p1.Y, h1.L1p2.X, h1.L1p2.Y);
      line(h1.L2p1.X, h1.L2p1.Y, h1.L2p2.X, h1.L2p2.Y);
      return this;
    }
    
    // Otherwise, draw rectangles between this cross and the next.
    CrossHist h2 = this.Hist[(i + this.HistIndex+2) % this.Hist.length];
    if (h2 != null) {
      pg.beginDraw();
      pg.clear();
      pg.noStroke();
      pg.fill(this.Col);
      pg.quad(h1.L1p1.X, h1.L1p1.Y, 
              h1.L1p2.X, h1.L1p2.Y,
              h2.L1p2.X, h2.L1p2.Y,
              h2.L1p1.X, h2.L1p1.Y);
      pg.quad(h1.L2p1.X, h1.L2p1.Y, 
              h1.L2p2.X, h1.L2p2.Y,
              h2.L2p2.X, h2.L2p2.Y,
              h2.L2p1.X, h2.L2p1.Y);
      pg.endDraw();
      
      float alpha = map(i, 0, this.Hist.length-1, 0, 255);
      tint(255, alpha);
      image(pg, 0, 0);
    }
    return this;
  }
}

Point calcThird(Point center, Point other) {
  float distAB = dist(center.X, center.Y, other.X, other.Y);
  float dx = other.X - center.X;
  float dy = other.Y - center.Y;
  float perpDx = -dy;
  float perpDy = dx;
  float len = sqrt(perpDx*perpDx + perpDy*perpDy);
  perpDx /= len;
  perpDy /= len;
  return new Point(center.X + perpDx*distAB, center.Y + perpDy * distAB);
}

Point calcEdgePoint(Point start, Point next) {
  Point rv = next.Copy().WithVelocity(next.X - start.X, next.Y - start.Y);
  while (rv.X >= 0 && rv.X <= width && rv.Y >= 0 && rv.Y <= height) {
    if (rv.Dx <= 100 && rv.Dy <= 100) {
      rv.Dx *= 10;
      rv.Dy *= 10;
    }
    rv.X += rv.Dx;
    rv.Y += rv.Dy;
  }
  return rv;
}
