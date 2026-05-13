class Jumper {
  Vertex Home;
  HexCornerRotated Corner;
  CircleDir RotDir;
  Spot[] History;
  int HistoryI;
  color[] Gradient;
  
  Jumper(Vertex home, int tailLength) {
    this.Home = home;
    this.History = new Spot[tailLength+1];
    this.Gradient = new color[tailLength+1];
  }
  
  Jumper WithColor(color headColor, color tailColor) {
    int tailLength = this.Gradient.length;
    this.Gradient[0] = tailColor;
    this.Gradient[tailLength-1] = headColor;
    for (int i = 1; i < tailLength-1; i++) {
      this.Gradient[i] = lerpColor(tailColor, headColor, (float)i / (float)(tailLength-1));
    }
    return this;
  }
  
  Jumper WithCorner(HexCornerRotated corner) {
    this.Corner = corner;
    return this.initializeHistory();
  }
  
  Jumper WithRotDir(CircleDir rotDir) {
    this.RotDir = rotDir;
    return this.initializeHistory();
  }
  
  Jumper initializeHistory() {
    if (this.Corner == null || this.RotDir == null) {
      return this;
    }
    HexCornerRotated corner = this.Corner;
    for (int i = 0; i < this.History.length; i++) {
      this.History[i] = this.Home.GetBorderSpot(corner);
      corner = corner.Next(this.RotDir);
    }
    this.HistoryI = this.History.length-1;
    return this;
  }
  
  Jumper Move() {
    Vertex neighbor = this.Home.Go(this.Corner.Rot90(this.RotDir));
    if (neighbor != null && int(random(changeVertexOdds)) == 0) {
      this.Home = neighbor;
      if (int(random(2)) == 0) {
        this.Corner = this.Corner.Opposite();
        this.RotDir = this.RotDir.Reverse();
      }
    } else {
      this.Corner = this.Corner.Next(this.RotDir);
    }
    this.HistoryI = (this.HistoryI + 1) % this.History.length;
    this.History[this.HistoryI] = this.Home.GetBorderSpot(this.Corner);
    return this;
  }
  
  Jumper Draw() {
    for (int i = 0; i < this.History.length-1; i++) {
      this.DrawI(i);
    }
    return this;
  }
  
  Jumper DrawI(int i) {
    int pos1 = (this.HistoryI + i + 1) % this.History.length;
    int pos2 = (this.HistoryI + i + 2) % this.History.length;
    Spot s1 = this.History[pos1];
    Spot s2 = this.History[pos2];
    stroke(this.Gradient[i+1]);
    line(s1.X, s1.Y, s2.X, s2.Y);
    return this;
  }
}
