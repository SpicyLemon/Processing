class Spot implements Comparable<Spot> {
  float X;
  float Y;
  int IndexX;
  int IndexY;
  
  Spot(float x, float y) {
    this.X = x;
    this.Y = y;
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
}
