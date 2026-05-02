class CenterSpot {
  float X;
  float Y;
  int IndexX;
  int IndexY;
  HashMap<CircleCrossing, HashMap<CircleDir, Boolean>> CannotChange;
  HashMap<CircleCrossing, Boolean> MustChange;
  boolean IsEdge;
  
  CenterSpot(float x, float y) {
    this.X = x;
    this.Y = y;
    this.CannotChange = new HashMap<CircleCrossing, HashMap<CircleDir, Boolean>>();
    this.MustChange = new HashMap<CircleCrossing, Boolean>(); 
  }
  
  CenterSpot WithIndex(int indexX, int indexY) {
    this.IndexX = indexX;
    this.IndexY = indexY;
    return this;
  }
  
  CenterSpot SetMustChange(CircleCrossing cc, boolean value) {
    this.MustChange.put(cc, value);
    return this;
  }
  
  boolean IsMustChange(CircleCrossing cc) {
    Boolean rv = this.MustChange.get(cc);
    return rv != null && rv;
  }
  
  CenterSpot SetCannotChange(CircleCrossing cc, CircleDir cd, boolean value) {
    HashMap<CircleDir, Boolean> inner = this.CannotChange.get(cc);
    if (inner == null) {
      inner = new HashMap<CircleDir, Boolean>();
      this.CannotChange.put(cc, inner);
    }
    inner.put(cd, value);
    return this;
  }
  
  boolean CanChange(CircleCrossing cc, CircleDir cd) {
    HashMap<CircleDir, Boolean> inner = this.CannotChange.get(cc);
    if (inner == null) {
      return true;
    }
    Boolean noChange = inner.get(cd);
    return noChange == null || !noChange;
  }
  
  CenterSpot SetIsEdge(boolean val) {
    this.IsEdge = val;
    return this;
  }
  
  CenterSpot GetNext(CircleCrossing cc) {
    return GetNextCenter(this.IndexX, this.IndexY, cc);
  }
  
  Spot AsSpot() {
    return new Spot(this.X, this.Y);
  }
  
  CenterSpot Draw() {
    if (this.IsEdge) {
      pg.stroke(#AAAAAA);
    } else {
      pg.stroke(#FFFFFF);
    }
    strokeWeight(2.0);
    if (this.IsEdge || !this.MustChange.isEmpty()) {
      pg.fill(#FFFFFF);
    } else if (!this.CannotChange.isEmpty()) {
      pg.fill(#555555);
    } else {
      pg.noFill();
    }
    pg.circle(this.X, this.Y, radius*2);

    // Draw red marks where we cannot change.
    for (Map.Entry<CircleCrossing, HashMap<CircleDir, Boolean>> outerEntry : this.CannotChange.entrySet()) {
      for (Map.Entry<CircleDir, Boolean> innerEntry : outerEntry.getValue().entrySet()) {
        if (Boolean.TRUE.equals(innerEntry.getValue())) {
          float angle = outerEntry.getKey().Radians();
          float x1 = this.X + (radius*0.70)*cos(angle);
          float x2 = this.X + (radius*0.99)*cos(angle);
          float y1 = this.Y + (radius*0.70)*sin(angle);
          float y2 = this.Y + (radius*0.99)*sin(angle);
          pg.stroke(#FF0000);
          pg.line(x1, y1, x2, y2);
          
          angle += (innerEntry.getKey() == CW) ? -.1 : .1;
          x1 = this.X + (radius*0.85)*cos(angle);
          x2 = this.X + (radius*0.99)*cos(angle);
          y1 = this.Y + (radius*0.85)*sin(angle);
          y2 = this.Y + (radius*0.99)*sin(angle);
          pg.stroke(#AA0000);
          pg.line(x1, y1, x2, y2);       
        }
      }
    }
    
    // Draw blue ticks where the runners MUST change.
    for (Map.Entry<CircleCrossing, Boolean> entry : this.MustChange.entrySet()) {
      if (Boolean.TRUE.equals(entry.getValue())) {
        float angle = entry.getKey().Radians();
        float x1 = this.X + (radius*0.80)*cos(angle);
        float x2 = this.X + (radius*0.99)*cos(angle);
        float y1 = this.Y + (radius*0.80)*sin(angle);
        float y2 = this.Y + (radius*0.99)*sin(angle);
        pg.stroke(#0000FF);
        pg.line(x1, y1, x2, y2);
      }
    }
    
    return this;
  }
}
