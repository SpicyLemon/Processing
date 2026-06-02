class Crawler {
  Vertex Head;
  CircleCrossing HeadDir;
  float HeadLen;
  CircleCrossing HeadToTail;
  Vertex Tail;
  CircleCrossing TailDir;
  float TailLen;
  color[] Gradient;
  
  Spot _Nose;
  Spot _TailTip;
  
  Crawler() {}
  
  Crawler WithColor(color startColor, color endColor, int gradientSize) {
    // Since we draw from tail to head, it's easier if the gradient is "backwards".
    // So the tail color will be at 0, and head at count-1.
    this.Gradient = new color[gradientSize];
    int cutoff = 3;
    int gradientCount = gradientSize - 1 - cutoff;
    for (int i = 0; i <= gradientCount; i++) {
      this.Gradient[i] = lerpColor(endColor, startColor, (float)i / gradientCount);
    }
    for (int i = gradientCount+1; i < gradientSize; i++) {
      this.Gradient[i] = startColor;
    }
    return this;
  }
  
  Crawler WithHead(Vertex head, CircleCrossing headDir, float headLen) {
    this.Head = head;
    this.HeadDir = headDir;
    this.HeadLen = headLen;
    return this;
  }
  
  Crawler WithTail(CircleCrossing headToTail, Vertex tail, CircleCrossing tailDir, float tailLen) {
    this.HeadToTail = headToTail;
    this.Tail = tail;
    this.TailDir = tailDir;
    this.TailLen = tailLen;
    return this;
  }

  Droplet Move() {
    this.HeadLen += crawlerSpeed;
    this.TailLen -= crawlerSpeed;

    Vertex newDropletAround = null;
    if (this.HeadLen >= hexRadius) {
      this.HeadLen -= hexRadius;
      this.TailLen += hexRadius;
      newDropletAround = this.Tail;
      this.TailDir = this.HeadToTail;
      this.Tail = this.Head;
      this.Head = this.Head.Go(this.HeadDir);
      this.HeadToTail = this.HeadDir.Opposite();
      this.HeadDir = this.Head.RandomNeighborDir(this.HeadToTail);
    }

    this._Nose = CalculateRadialSpot(this.Head, this.HeadDir, this.HeadLen);
    this._TailTip = CalculateRadialSpot(this.Tail, this.TailDir, this.TailLen);

    if (newDropletAround == null) {
      return null;
    }
    
    return new Droplet(newDropletAround, this.Gradient[0]);
  }
  
  Crawler DrawSimple() {
    stroke(this.Gradient[0]);
    strokeWeight(crawlerWeightTail);
    beginShape();
    if (this.HeadLen > 0) {
      vertex(this._Nose.X, this._Nose.Y);
    }
    vertex(this.Head.X, this.Head.Y);
    vertex(this.Tail.X, this.Tail.Y);
    if (this.TailLen > 0) {
      vertex(this._TailTip.X, this._TailTip.Y);
    }
    endShape();
    return this;
  }
  
  Crawler Draw() {
    // Build the list of points from tail to head.
    ArrayList<Spot> spots = new ArrayList<Spot>();
    ArrayList<Float> segmentLengths = new ArrayList<Float>();
    if (this.TailLen > 0) {
      spots.add(this._TailTip);
      segmentLengths.add(this.TailLen);
    }
    spots.add(this.Tail.AsSpot());
    segmentLengths.add(hexRadius);
    spots.add(this.Head.AsSpot());
    if (this.HeadLen > 0) {
      spots.add(this._Nose);
      segmentLengths.add(this.HeadLen);
    }
    
    // Draw each segment with interpolated colors.
    float totalLength = hexRadius * 2;
    float distanceSoFar = 0;
    for (int i = 0; i < spots.size() - 1; i++) {
      Spot s1 = spots.get(i);
      Spot s2 = spots.get(i+1);
      float segmentLength = segmentLengths.get(i);
      
      // Subdivide each segment for smooth gradient.
      int subdivisions = max(1, int(segmentLength));
      for (int j = 0; j < subdivisions; j++) {
        float t1 = (float)j / subdivisions;
        float t2 = (float)(j + 1) / subdivisions;
        float pos = (distanceSoFar + segmentLength * t1) / totalLength;
        
        // Get the color from the gradient.
        int gi = constrain(int(pos * (this.Gradient.length - 1)), 0, this.Gradient.length - 1);
        stroke(this.Gradient[gi]);
        strokeWeight(map(gi, 0, this.Gradient.length-1, crawlerWeightTail, crawlerWeightHead));
        
        float x1 = lerp(s1.X, s2.X, t1);
        float y1 = lerp(s1.Y, s2.Y, t1);
        float x2 = lerp(s1.X, s2.X, t2);
        float y2 = lerp(s1.Y, s2.Y, t2);
        line(x1, y1, x2, y2);
      }
      distanceSoFar += segmentLength;
    }
    
    return this;
  }
}
