class Spot implements Comparable<Spot> {
  float X;
  float Y;
  int IndexX;
  int IndexY;

  Spot(float x, float y) {
    this.X = x;
    this.Y = y;
  }
  
  Spot(Spot orig) {
    this.X = orig.X;
    this.Y = orig.Y;
    this.IndexX = orig.IndexX;
    this.IndexY = orig.IndexY;
  }
  
  Spot WithIndex(int indexX, int indexY) {
    this.IndexX = indexX;
    this.IndexY = indexY;
    return this;
  }
  
  @Override
  public int compareTo(Spot other) {
    int rv = Integer.compare(this.IndexY, other.IndexY);
    if (rv != 0) {
      return rv;
    }
    return Integer.compare(this.IndexX, other.IndexX);
  }
  
  Vertex AsVertex() {
    return new Vertex(this);
  }
}

enum CircleCrossing {
  Right,
  BottomRight,
  BottomLeft,
  Left,
  TopLeft,
  TopRight;

  float Radians() {
    switch(this) {
      case Right: return 0.0;
      case BottomRight: return PI_1_3;
      case BottomLeft: return PI_2_3;
      case Left: return PI;
      case TopLeft: return PI_4_3;
      case TopRight: return PI_5_3;
    }
    return 0;
  }
  
  CircleCrossing Opposite() {
    switch(this) {
      case Right: return Left;
      case BottomRight: return TopLeft;
      case BottomLeft: return TopRight;
      case Left: return Right;
      case TopLeft: return BottomRight;
      case TopRight: return BottomLeft;
    }
    return null;
  }
  
  HexCornerRotated Rot90(CircleDir dir) {
    switch(dir) {
      case CW:
        switch(this) {
          case Right: return HexCornerRotated.Bottom;
          case BottomRight: return HexCornerRotated.BottomLeft;
          case BottomLeft: return HexCornerRotated.TopLeft;
          case Left: return HexCornerRotated.Top;
          case TopLeft: return HexCornerRotated.TopRight;
          case TopRight: return HexCornerRotated.BottomRight;
        }
        break;
      case CCW:
        switch(this) {
          case Right: return HexCornerRotated.Top;
          case BottomRight: return HexCornerRotated.TopRight;
          case BottomLeft: return HexCornerRotated.BottomRight;
          case Left: return HexCornerRotated.Bottom;
          case TopLeft: return HexCornerRotated.BottomLeft;
          case TopRight: return HexCornerRotated.TopLeft;
        }
        break;
    }
    return null;
  }
  
  CircleCrossing Next(CircleDir dir) {
    switch(dir) {
      case CW:
        switch(this) {
          case Right: return BottomRight;
          case BottomRight: return BottomLeft;
          case BottomLeft: return Left;
          case Left: return TopLeft;
          case TopLeft: return TopRight;
          case TopRight: return Right;
        }
        break;
      case CCW:
        switch(this) {
          case Right: return TopRight;
          case BottomRight: return Right;
          case BottomLeft: return BottomRight;
          case Left: return BottomLeft;
          case TopLeft: return Left;
          case TopRight: return TopLeft;
        }
        break;
      }
    return null;
  }
}

CircleCrossing RandomCircleCrossing() {
  CircleCrossing[] vals = CircleCrossing.values();
  return vals[int(random(vals.length))];
}

enum HexCornerRotated {
  Top,
  TopRight,
  BottomRight,
  Bottom,
  BottomLeft,
  TopLeft;
  
  float Radians() {
    switch(this) {
      case Top: return PI_3_2;
      case TopRight: return PI_11_6;
      case BottomRight: return PI_1_6;
      case Bottom: return HALF_PI;
      case BottomLeft: return PI_5_6;
      case TopLeft: return PI_7_6;
    }
    return 0;
  }
  
  HexCornerRotated Opposite() {
    switch(this) {
      case Top: return Bottom;
      case TopRight: return BottomLeft;
      case BottomRight: return TopLeft;
      case Bottom: return Top;
      case BottomLeft: return TopRight;
      case TopLeft: return BottomRight;
    }
    return null;
  }
  
  CircleCrossing Rot90(CircleDir dir) {
    switch(dir) {
      case CW:
        switch(this) {
          case Top: return CircleCrossing.Right;
          case TopRight: return CircleCrossing.BottomRight;
          case BottomRight: return CircleCrossing.BottomLeft;
          case Bottom: return CircleCrossing.Left;
          case BottomLeft: return CircleCrossing.TopLeft;
          case TopLeft: return CircleCrossing.TopRight;
        }
        break;
      case CCW:
        switch(this) {
          case Top: return CircleCrossing.Left;
          case TopRight: return CircleCrossing.TopLeft;
          case BottomRight: return CircleCrossing.TopRight;
          case Bottom: return CircleCrossing.Right;
          case BottomLeft: return CircleCrossing.BottomRight;
          case TopLeft: return CircleCrossing.BottomLeft;
        }
        break;
    }
    return null;
  }
  
  HexCornerRotated Next(CircleDir dir) {
    switch(dir) {
      case CW:
        switch(this) {
          case Top: return TopRight;
          case TopRight: return BottomRight;
          case BottomRight: return Bottom;
          case Bottom: return BottomLeft;
          case BottomLeft: return TopLeft;
          case TopLeft: return Top;
        }
        break;
      case CCW:
        switch(this) {
          case Top: return TopLeft;
          case TopRight: return Top;
          case BottomRight: return TopRight;
          case Bottom: return BottomRight;
          case BottomLeft: return Bottom;
          case TopLeft: return BottomLeft;
        }
        break;
    }
    return null;
  }
}

HexCornerRotated RandomHexCornerRotated() {
  HexCornerRotated[] vals = HexCornerRotated.values();
  return vals[int(random(vals.length))];
}

enum CircleDir {
  CW,
  CCW;
  
  CircleDir Reverse() {
    return this == CW ? CCW : CW;
  }
}

CircleDir RandomCircleDir() {
  CircleDir[] vals = CircleDir.values();
  return vals[int(random(vals.length))];
}


class Vertex implements Comparable<Vertex> {
  float X;
  float Y;
  int IndexX;
  int IndexY;
  HashMap<CircleCrossing, Vertex> Neighbors;
  HashMap<HexCornerRotated, Spot> BorderSpots;

  Vertex(Spot spot) {
    this.X = spot.X;
    this.Y = spot.Y;
    this.IndexX = spot.IndexX;
    this.IndexY = spot.IndexY;
    Neighbors = new HashMap<CircleCrossing, Vertex>();
    this.SetBorderSpots();
  }
  
  Vertex(float x, float y) {
    this.X = x;
    this.Y = y;
    Neighbors = new HashMap<CircleCrossing, Vertex>();
    this.SetBorderSpots();
  }
  
  Vertex WithIndex(int indexX, int indexY) {
    this.IndexX = indexX;
    this.IndexY = indexY;
    return this;
  }
  
  Vertex WithNeighbor(CircleCrossing cc, Vertex neighbor) {
    this.Neighbors.put(cc, neighbor);
    return this;
  }
  
  Vertex Go(CircleCrossing cc) {
    return this.Neighbors.get(cc);
  }
  
  Spot AsSpot() {
    return new Spot(this.X, this.Y).WithIndex(this.IndexX, this.IndexY);
  }
  
  Vertex SetBorderSpots() {
    this.BorderSpots = new HashMap<HexCornerRotated, Spot>();
    for (HexCornerRotated corner : HexCornerRotated.values()) {
      this.BorderSpots.put(corner, CalculateRadialSpot(this.X, this.Y, corner.Radians(), vertexRadius));
    }
    return this;
  }
  
  Spot GetBorderSpot(HexCornerRotated corner) {
    return this.BorderSpots.get(corner);
  }
  
  Vertex DrawBorder() {
    beginShape();
    for (HexCornerRotated corner : HexCornerRotated.values()) {
      Spot c = this.BorderSpots.get(corner);
      vertex(c.X, c.Y);
    }
    endShape(CLOSE);
    return this;
  }
  
  @Override
  public int compareTo(Vertex other) {
    int rv = Integer.compare(this.IndexY, other.IndexY);
    if (rv != 0) {
      return rv;
    }
    return Integer.compare(this.IndexX, other.IndexX);
  }
}
