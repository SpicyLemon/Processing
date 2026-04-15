class Spot {
  float X;
  float Y;
  
  Spot(float x, float y) {
    this.X = x;
    this.Y = y;
  }
  
  Spot(Spot orig) {
    this.X = orig.X;
    this.Y = orig.Y;
  }
  
  Spot Copy() {
    return new Spot(this);
  }
}

enum CircleDir {
  CW(0),
  CCW(1);
  
  int val;
  
  CircleDir(int val) {
    this.val = val;
  }
  
  int getVal() {
    return this.val;
  }
  
  CircleDir Rev() {
    return this.val == 0 ? CCW : CW;
  }
  
  String Str() {
    return this.val == 0 ? "CW" : "CCW";
  }
}

CircleDir CW = CircleDir.CW;
CircleDir CCW = CircleDir.CCW;
    
class Arch {
  Spot Center;
  float Start;
  float Stop;
  CircleDir Dir;
  Arch Next;
  
  Arch(Spot center, float start, float stop, CircleDir dir) {
    this.Center = center;
    this.Start = normalizeAngle(start);
    this.Stop = normalizeAngle(stop);
    this.Dir = dir;
  }
  
  Arch WithNext(Arch nextArch) {
    this.Next = nextArch;
    return this;
  }
  
  float Length() {
    float rads = 0.0;
    if (this.Dir == CW) {
      if (this.Start > this.Stop) {
        rads = TWO_PI - this.Start + this.Stop;
      } else {
        rads = this.Stop - this.Start;
      }
    } else {
      // this.Dir == CCW
      if (this.Start > this.Stop) {
        rads = this.Start - this.Stop;
      } else {
        rads = TWO_PI - this.Stop + this.Start;
      }
    }
    return abs(radius*rads);
  }
  
  float AngleLength() {
    return angleLenth(this.Start, this.Stop, this.Dir);
  }
}

float normalizeAngle(float angle) {
  while (angle < 0) {
    angle += TWO_PI;
  }
  while (angle > TWO_PI) {
    angle -= TWO_PI;
  }
  return angle;
}

float angleLenth(float start, float stop, CircleDir dir) {
  if (dir == CW) {
    if (start < stop) {
      return stop - start;
    }
    return stop+TWO_PI - start;
  }
  if (stop < start) {
    return start - stop;
  }
  return start+TWO_PI - stop;
}

class ArchToDraw {
  Spot Center;
  float Start;
  float Stop;
  CircleDir Dir;
  color Col;
  float StrokeWeight;
  
  ArchToDraw(Spot center, float start, float stop, CircleDir dir, color col, float strokeWeight) {
    this.Center = center;
    this.Start = start;
    this.Stop = stop;
    this.Dir = dir;
    this.Col = col;
    this.StrokeWeight = strokeWeight;
  }
  
  void Draw() {
    pg.stroke(this.Col);
    pg.strokeWeight(this.StrokeWeight);
    drawArch(this.Center.X, this.Center.Y, radius*2, this.Start, this.Stop, this.Dir);
  }
}

class Tracer {
  int CenterX;
  int CenterY;
  float Angle;
  float Speed;
  float Stroke;
  Color Col;
  Arch history;
  Palette TailPal;
  float TailLen;
  
  Tracer(int centersX, int centersY) {
    this.CenterX = centersX;
    this.CenterY = centersY;
    this.Stroke = 15.0;
  }
   
  Tracer WithAngle(float angle) {
    this.Angle = angle;
    return this;
  }
  
  Tracer WithSpeed(float speed) {
    this.Speed = speed;
    return this;
  }
  
  Tracer WithStroke(float stroke) {
    this.Stroke = stroke;
    return this;
  }
  
  Tracer WithColor(color col) {
    this.Col = new Color(col);
    return this;
  }
  
  Tracer WithTail(float tailLen, Palette tailPal) {
    this.TailLen = tailLen;
    this.TailPal = tailPal;
    return this;
  }
  
  Spot Cur() {
    Spot center = centers[this.CenterY][this.CenterX];
    return new Spot(
      center.X + radius/2 * cos(this.Angle),
      center.Y + radius/2 * sin(this.Angle)
    );
  }
  
  Spot Center() {
    return centers[this.CenterY][this.CenterX];
  }
  
  CircleDir Dir() {
    return this.Speed >= 0 ? CW : CCW;
  }
  
  Tracer Move() {
    int dx = 0;
    int dy = 0;
    boolean atCrossing = false;
    if (isAtTopLeft(this.Angle)) {
      atCrossing = true;
      this.Angle = PI_4_3;
      dy = -1;
      if (this.CenterY % 2 == 0) {
        dx = -1;
      }
    } else if (isAtTopRight(this.Angle)) {
      atCrossing = true;
      this.Angle = PI_5_3;
      dy = -1;
      if (this.CenterY % 2 != 0) {
        dx = 1;
      }
    } else if (isAtRight(this.Angle)) {
      atCrossing = true;
      this.Angle = 0;
      dx = 1;
    } else if (isAtBottomRight(this.Angle)) {
      atCrossing = true;
      this.Angle = PI_1_3;
      dy = 1;
      if (this.CenterY % 2 != 0) {
        dx = 1;
      }
    } else if (isAtBottomLeft(this.Angle)) {
      atCrossing = true;
      this.Angle = PI_2_3;
      dy = 1;
      if (this.CenterY % 2 == 0) {
        dx = -1;
      }
    } else if (isAtLeft(this.Angle)) {
      atCrossing = true;
      this.Angle = PI;
      dx = -1;
    }
    
    if (atCrossing) {
      if (int(random(changeOdds)) != 0) {
        dx = 0;
        dy = 0;
      }
      if (dx != 0 || dy != 0) {
        int cx = this.CenterX + dx;
        int cy = this.CenterY + dy;
        if (cy >= 0 && cy < centers.length && cx >= 0 && cx < centers[cy].length && centers[cy][cx] != null) {
          this.CenterX = cx;
          this.CenterY = cy;
          this.Speed *= -1;
          this.Angle = normalizeAngle(this.Angle+PI);
        }
      }
      Arch newHist = new Arch(this.Center(), this.Angle, this.Angle, this.Dir().Rev())
                          .WithNext(this.history);
      this.history = newHist;
    }
    
    if (this.history == null) {
      this.history = new Arch(this.Center(), this.Angle, this.Angle, this.Dir().Rev());
    }
    this.Angle = normalizeAngle(this.Angle + this.Speed);
    this.history.Start = this.Angle;
    
    return this;
  }
  
  Tracer Draw() {
    Arch cur = this.history;
    float lenLeft = this.TailLen;
    float lenPerPal = this.TailLen / this.TailPal.Size();
    int palI = 0;
    pg.strokeWeight(this.Stroke);
    pg.stroke(this.TailPal.Get(palI).Value);
    float curStart = cur.Start;
    float curStop = cur.Stop;
    float palLenLeft = lenPerPal;
    float histLenLeft = cur.AngleLength();
    color curCol = this.TailPal.Get(0).Value;
    float curWeight = this.Stroke;
    ArrayList<ArchToDraw> toDraw = new ArrayList<>();
    while (lenLeft > 0) {
      // Pick the next stopper.
      // It's the lesser of palLenLeft or histLenLeft.
      if (palLenLeft < histLenLeft) {
        // We draw to the line from the start for a distance left on the pallete.
        curStop = normalizeAngle(curStart + (cur.Dir == CW ? palLenLeft : -palLenLeft));
        toDraw.add(new ArchToDraw(cur.Center, curStart, curStop, cur.Dir, curCol, curWeight));

        lenLeft -= palLenLeft;
        histLenLeft -= palLenLeft;
        palLenLeft = lenPerPal;
        palI += 1;
        if (palI >= this.TailPal.Size()) {
          // out of palette space, we're done!
          break;
        }
        // Setup the stroke and weight for the next time around.
        curCol = this.TailPal.Get(palI).Value;
        curWeight = this.Stroke-palI*this.Stroke/this.TailPal.Size();
        curStart = curStop;
      } else {
        // We draw the line to the end of this history.
        curStop = cur.Stop;
        toDraw.add(new ArchToDraw(cur.Center, curStart, curStop, cur.Dir, curCol, curWeight));

        lenLeft -= histLenLeft;
        palLenLeft -= histLenLeft;
        cur = cur.Next;
        if (cur == null) {
          break;
        }
        histLenLeft = cur.AngleLength();
        curStart = cur.Start;
      }
    }
    
    if (cur != null) {
      cur.Next = null;
    }
    
    pg.fill(setAlpha(this.TailPal.Get(0).Value, wedgeAlpha));
    for (int i = toDraw.size()-1; i >= 0; i--) {
      toDraw.get(i).Draw();
    }
    return this;
  }
}

boolean isAtBottomRight(float angle) {
  return roughlyEqual(angle, PI_1_3);
}

boolean isAtBottomLeft(float angle) {
  return roughlyEqual(angle, PI_2_3);
}

boolean isAtLeft(float angle) {
  return roughlyEqual(angle, PI);
}

boolean isAtTopLeft(float angle) {
  return roughlyEqual(angle, PI_4_3);
}

boolean isAtTopRight(float angle) {
  return roughlyEqual(angle, PI_5_3);
}

boolean isAtRight(float angle) {
  return roughlyEqual(angle, 0) || roughlyEqual(angle, TWO_PI);
}

boolean isAtCrossing(float angle) {
  return isAtBottomRight(angle) || isAtBottomLeft(angle) || isAtLeft(angle) 
      || isAtTopLeft(angle) || isAtTopRight(angle) || isAtRight(angle);
}

boolean roughlyEqual(float a, float b) {
  return abs(a-b) < 0.0001;
}

void drawArch(float x, float y, float radius, float start, float stop, CircleDir dir) {
  if (roughlyEqual(start, stop)) {
    return;
  }
  if (dir == CW) {
    if (start < stop) {
      pg.arc(x, y, radius, radius, start, stop);
    } else {
      pg.arc(x, y, radius, radius, start, stop+TWO_PI);
    }
  } else {
    if (start < stop) {
      pg.arc(x, y, radius, radius, stop, start+TWO_PI);
    } else {
      pg.arc(x, y, radius, radius, stop, start);
    }
  }
}

color setAlpha(color col, int alpha) {
  return (col & 0x00FFFFFF) | ((alpha & 0xFF) << 24);
}
