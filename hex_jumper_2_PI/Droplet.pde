class Droplet {
  BigHex Home;
  color[] Gradient;
  int[] FrameCounts;
  int GradientI;
  int Radius;
  int FramesLeft;
  
  Droplet(BigHex home, color baseColor) {
    this(home, GetDropletGradient(baseColor), dropletFrameCounts);
  }
  
  Droplet(BigHex home, color[] gradient, int[] frameCounts) {
    this.Home = home;
    this.Gradient = gradient;
    this.FrameCounts = frameCounts;
    this.GradientI = 0;
    this.Radius = bigHexRadiusMin;
    this.FramesLeft = 1;
  }
  
  Droplet Move() {
    this.FramesLeft--;
    if (this.FramesLeft > 0) {
      return this;
    }
    
    this.GradientI++;
    if (this.GradientI >= this.Gradient.length) {
      return this;
    }
    
    this.Radius++;
    this.FramesLeft = this.FrameCounts[this.GradientI];
    return this;
  }
  
  boolean IsDone() {
    return this.GradientI >= this.Gradient.length;
  }
  
  Droplet Draw() {
    noStroke();
    fill(this.Gradient[this.GradientI]);
    this.Home.DrawBorder(this.Radius);
    return this;
  }
}
