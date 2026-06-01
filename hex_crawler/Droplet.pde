class Droplet {
  Vertex Home;
  color[] Gradient;
  int[] FrameCounts;
  int GradientI;
  int Radius;
  int FramesLeft;
  
  Droplet(Vertex home, color baseColor) {
    this(home, GetDropletGradient(baseColor), dropletFrameCounts);
  }

  Droplet(Vertex home, color[] gradient, int[] frameCounts) {
    this.Home = home;
    this.Gradient = gradient;
    this.FrameCounts = frameCounts;
    this.GradientI = 0;
    this.Radius = dropletRadiusMin;
    this.FramesLeft = this.FrameCounts[0];
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

class VertexDot {
  Vertex Home;
  color[] Gradient;
  int GradientI;
  int FramesLeft;
  
  VertexDot(Vertex home) {
    this.Home = home;
    this.Gradient = vertexDotGradient;
    this.GradientI = 0;
    this.FramesLeft = vertexDotFramesPerColor;
  }
  
  VertexDot FullyOn() {
    this.GradientI = this.Gradient.length-1;
    return this;
  }
  
  VertexDot Move() {
    // If we're on the last color, just stay there.
    if (this.GradientI == this.Gradient.length - 1) {
      return this;
    }
    
    this.FramesLeft--;
    if (this.FramesLeft <= 0) {
      this.FramesLeft = vertexDotFramesPerColor;
      this.GradientI++;
    }
    return this;
  }
  
  VertexDot Draw() {
    noStroke();
    fill(this.Gradient[this.GradientI]);
    this.Home.DrawBorder(vertexDotRadius);
    return this;
  }
}
