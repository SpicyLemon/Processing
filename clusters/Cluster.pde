class Cluster {
  Point Center;
  Point[] Satellites;
  Trail[] Trails;
  
  Cluster(float x, float y, int count, Color... colors) {
    this.Center = new Point(x, y).WithMaxSpeed(10.0);
    this.Satellites = new Point[count];
    this.Trails = new Trail[count];
    int ci = 0; // ci = color index.
    for (int i = 0; i < count; i++) {
      Point p = new Point(random(-50, 50), random(-50, 50))
                    .WithVelocity(random(-3.0, 3.0), random(-3.0, 3.0))
                    .WithMaxSpeed(3.0);
      this.Satellites[i] = p;
      this.Trails[i] = new Trail(50, colors[ci], x+p.X, y+p.Y);
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
      this.Satellites[i].Accelerate(random(-1, 1), random(-1, 1))
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
