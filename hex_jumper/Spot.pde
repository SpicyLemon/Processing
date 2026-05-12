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
}

class Vertex implements Comparable<Vertex> {
  float X;
  float Y;
  int IndexX;
  int IndexY;
  HashMap<CircleCrossing, Vertex> Neighbors;

  Vertex(Spot spot) {
    this.X = spot.X;
    this.Y = spot.Y;
    this.IndexX = spot.IndexX;
    this.IndexY = spot.IndexY;
    Neighbors = new HashMap<CircleCrossing, Vertex>();
  }
  
  Vertex(float x, float y) {
    this.X = x;
    this.Y = y;
    Neighbors = new HashMap<CircleCrossing, Vertex>();
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
  
  @Override
  public int compareTo(Vertex other) {
    int rv = Integer.compare(this.IndexY, other.IndexY);
    if (rv != 0) {
      return rv;
    }
    return Integer.compare(this.IndexX, other.IndexX);
  }
}
