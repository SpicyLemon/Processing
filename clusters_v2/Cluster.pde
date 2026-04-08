class Cluster {
  Point Center;
  Point[] Satellites;
  Trail[] Trails;
  
  Cluster(float x, float y, int count, Color... colors) {
    this.Center = new Point(x, y).WithMaxSpeed(3.0);
    this.Satellites = new Point[count];
    this.Trails = new Trail[count];
    int ci = 0; // ci = color index.
    for (int i = 0; i < count; i++) {
      Point p = new Point(random(-50, 50), random(-50, 50))
                    .WithVelocity(random(-3.0, 3.0), random(-3.0, 3.0))
                    .WithMaxSpeed(random(3.0));
      this.Satellites[i] = p;
      this.Trails[i] = new Trail(100, colors[ci], x+p.X, y+p.Y);
      ci = (ci + 1) % colors.length;
    }
  }
  
  Cluster Move() {
    // Move the center.
    this.Center.Accelerate(random(-0.5, 0.5), random(-0.5, 0.5))
               .Move()
               .RestrictBounce(50.0, width-50.0, 50.0, height-50.0);
    
    for (int i = 0; i < this.Satellites.length; i++) {
      // Move each satellite, but make sure it stays close.
      float mag = sqrt(this.Satellites[i].X*this.Satellites[i].X + this.Satellites[i].Y*this.Satellites[i].Y);
      if (isZero(mag)) {
        mag = 0.00001;
      }
      float ddx = -this.Satellites[i].X/mag/mag+random(-0.5, 0.5);
      float ddy = -this.Satellites[i].Y/mag/mag+random(-0.5, 0.5);
      this.Satellites[i].Accelerate(ddx, ddy)
                        .Move()
                        .RestrictBounce(-50.0, 50.0, -50.0, 50.0);

      // Add this satellite's actual position to its trail.
      this.Trails[i].ShiftIn(this.Center.X + this.Satellites[i].X, 
                             this.Center.Y + this.Satellites[i].Y);
    }
    
    return this;
  }
  
  Cluster Draw() {
    for (Trail trail : this.Trails) {
      trail.Draw();
    }
    return this;
  }
}
