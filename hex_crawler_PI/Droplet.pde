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
  
  boolean EqualTo(Droplet that) {
    return this.Home.EqualTo(that.Home)
        && this.GradientI == that.GradientI
        && this.Radius == that.Radius
        && this.FramesLeft == that.FramesLeft
        && this.Gradient[this.GradientI] == that.Gradient[that.GradientI];
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
  int AlphaGradientI;
  int FramesLeft;
  
  VertexDot(Vertex home) {
    this.Home = home;
    this.AlphaGradientI = 0;
    this.FramesLeft = vertexDotFramesPerAlpha;
  }
  
  VertexDot FullyOn() {
    this.AlphaGradientI = vertexDotAlphaGradient.length-1;
    return this;
  }
  
  VertexDot Move() {
    if (this.AlphaGradientI >= vertexDotAlphaGradient.length-1) {
      return this;
    }
    
    this.FramesLeft--;
    if (this.FramesLeft <= 0) {
      this.FramesLeft = vertexDotFramesPerAlpha;
      this.AlphaGradientI++;
    }
    return this;
  }
  
  VertexDot Draw() {
    int alpha = vertexDotAlphaGradient[this.AlphaGradientI];
    strokeWeight(vertexDotBorderWeight);
    stroke(setAlpha(colors[vertexDotBorderColorIdx], alpha));
    fill(setAlpha(vertexDotFillColor, alpha));
    this.Home.DrawBorder(vertexDotRadius);
    return this;
  }
}

class Bubble {
  Vertex Home;
  color[] Gradient;  
  int MaxGradient;
  int MaxRadius;
  
  Bubble(Vertex home, color[] gradient) {
    this.Home = home;
    this.Gradient = gradient;
    this.MaxGradient = 0;
    this.MaxRadius = centerRadiusMax;
  }
  
  Bubble Move() {
    if (this.MaxGradient < this.Gradient.length - 1) {
      this.MaxGradient += bubbleGrowSpeed;
      if (this.MaxGradient >= this.Gradient.length) {
        this.MaxGradient = this.Gradient.length - 1;
      }
    } else {
      this.MaxRadius -= bubbleShrinkSpeed;
      if (this.MaxRadius <= 0) {
        this.MaxRadius = 0;
      }
    }
    return this;
  }
  
  boolean IsDone() {
    return this.MaxRadius <= 0;
  }
  
  Bubble Draw() {
    noStroke();
    if (this.MaxGradient < this.Gradient.length - 1) {
      for (int c = 0; c <= this.MaxGradient; c++) {
        int r = centerRadiusMax - c;
        fill(this.Gradient[c]);
        this.Home.DrawBorder(r);
      }
    } else {
      for (int r = this.MaxRadius; r >= 1; r--) {
        int c = this.MaxRadius - r;
        fill(this.Gradient[c]);
        this.Home.DrawBorder(r);
      }
    }
    return this;
  }
}
