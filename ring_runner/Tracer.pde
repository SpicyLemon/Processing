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
    return abs(pathRadius*rads);
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
    stroke(this.Col);
    strokeWeight(this.StrokeWeight);
    drawArch(this.Center.X, this.Center.Y, pathRadius, this.Start, this.Stop, this.Dir);
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
      center.X + pathRadius/2 * cos(this.Angle),
      center.Y + pathRadius/2 * sin(this.Angle)
    );
  }
  
  Spot Center() {
    return centers[this.CenterY][this.CenterX];
  }
  
  CircleDir Dir() {
    return this.Speed >= 0 ? CW : CCW;
  }
  
  Tracer Move() {
    if (isAtCrossing(this.Angle)) {
      int dx = 0;
      int dy = 0;
      if (int(random(3)) == 0) {
        if (isAtTop(this.Angle) && this.CenterY > 0) {
          dy = -1;
        } else if (isAtBottom(this.Angle) && this.CenterY < vCount-1) {
          dy = 1;
        } else if (isAtLeft(this.Angle) && this.CenterX > 0) {
          dx = -1;
        } else if (isAtRight(this.Angle) && this.CenterX < hCount-1) {
          dx = 1;
        }
      }
      if (dx != 0 || dy != 0) {
        this.CenterX += dx;
        this.CenterY += dy;
        this.Speed *= -1;
        this.Angle = normalizeAngle(this.Angle+PI);
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
    // strokeWeight(this.Stroke);
    //stroke(#FFFFFF);
    //Spot curSpot = this.Cur();
    //circle(curSpot.X, curSpot.Y, this.Stroke);
    //Spot cen = this.Center();
    //stroke(this.Col.Value);
    //strokeWeight(1);
    //line(curSpot.X, curSpot.Y, cen.X, cen.Y);
    
    strokeWeight(this.Stroke);
    
    Arch cur = this.history;
    float lenLeft = this.TailLen;
    float lenPerPal = this.TailLen / this.TailPal.Size();
    int palI = 0;
    strokeWeight(this.Stroke);
    stroke(this.TailPal.Get(palI).Value);
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
    
    for (int i = toDraw.size()-1; i >= 0; i--) {
      toDraw.get(i).Draw();
    }
    return this;
  }
}

float PI_2_3 = PI + HALF_PI;

boolean isAtTop(float angle) {
  return roughlyEqual(angle, PI_2_3);
}

boolean isAtBottom(float angle) {
  return roughlyEqual(angle, HALF_PI);
}

boolean isAtLeft(float angle) {
  return roughlyEqual(angle, PI);
}

boolean isAtRight(float angle) {
  return roughlyEqual(angle, 0) || roughlyEqual(angle, TWO_PI);
}

boolean isAtCrossing(float angle) {
  return isAtTop(angle) || isAtBottom(angle) || isAtLeft(angle) || isAtRight(angle);
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
      arc(x, y, radius, radius, start, stop);
    } else {
      arc(x, y, radius, radius, start, stop+TWO_PI);
    }
  } else {
    if (start < stop) {
      arc(x, y, radius, radius, stop, start+TWO_PI);
    } else {
      arc(x, y, radius, radius, stop, start);
    }
  }
}
