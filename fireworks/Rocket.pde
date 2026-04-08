class Rocket {
  Palette PalTrail;
  Palette PalDots;
  float X;
  float Y;
  float Dx;
  float Dy;
  ArrayList<Dot> Trail = new ArrayList<>();
  Dot[] Dots;
  int Stage;
  int StageAge;
  int Stage1Life;
  int Stage2Life;
  
  Rocket(Palette palTrail, float x, float y) {
    this.PalTrail = palTrail;
    this.X = x;
    this.Y = y;
    this.Stage1Life = 50;
    this.Stage2Life = 25;
  }
  
  Rocket WithVelocity(float dx, float dy) {
    this.Dx = dx;
    this.Dy = dy;
    return this;
  }
  
  Rocket WithExplosion(Palette palDots) {
    this.PalDots = palDots;
    return this;
  }
  
  Rocket WithStageLife(int stage1Life, int stage2Life) {
    this.Stage1Life = stage1Life;
    this.Stage2Life = stage2Life;
    return this;
  }
  
  Rocket Move() {
    switch (this.Stage) {
      case 0:
        // Launch
        this.Dy += 0.1;
        this.X += this.Dx;
        this.Y += this.Dy;
        this.Trail.add(new Dot(this.X, this.Y));
        while (this.Trail.size() > this.PalTrail.Colors.length) {
          this.Trail.remove(0);
        }
        break;
      case 1:
        // Invisible glide
        this.Dy += 0.1;
        this.X += this.Dx;
        this.Y += this.Dy;
        if (this.Trail.size() > 0) {
          this.Trail.remove(0);
        }
        break;
      case 2:
        // Explosion!
        for (Dot dot : this.Dots) {
          dot.Accelerate(random(-1, 1), random(-1, 1));
          dot.Move();
        }
        break;
    }

    return this;
  }
  
  Rocket Draw() {
    switch (this.Stage) {
      case 0:
      case 1:
        // Launch.
        int cutoff = this.Trail.size() - 3;
        for (int i = 0; i < this.Trail.size(); i++) {
          // first will be size 1, 3rd to last will have size 6
          // 2nd to last 4, last 2.
          // (0, 1) - (cutoff, 6)
          // m = (6 - 1)/(cutoff - 1) = 5/cutoff
          // b = 1.
          float size = 1.0 + (float)i * 5.0/(float)cutoff;
          if (i >= cutoff) {
            size = (float)(1 + this.Trail.size() - i) * 2;
          }
          noStroke();
          fill(this.PalTrail.Colors[i].Value);
          ellipse(this.Trail.get(i).X, this.Trail.get(i).Y, size, size);        
        }
        break;
      case 2:
        // Explosion!
        for (Dot dot : this.Dots) {
          dot.GetOlder();
          dot.Draw();
        }
        break;
    }
    
    return this;
  }
  
  boolean IsDead() {
    this.StageAge++;
    switch (this.Stage) {
      case 0:
        if (this.StageAge >= this.Stage1Life) {
          this.StageAge = 0;
          this.Stage++;
        }
        return false;
      case 1:
        if (this.StageAge >= this.Stage2Life || this.Dy > 0.1 || this.Y < 15) {
          this.StageAge = 0;
          this.Stage++;
          int count = int(random(80))+20;
          this.Dots = new Dot[count];
          for (int i = 0; i < count; i++) {
            this.Dots[i] = new Dot(this.PalDots, this.X, this.Y, 20 + int(random(40)));
          }
        }
        return false;
      case 2:
        for (Dot dot : dots) {
          if (!dot.IsDead()) {
            return false;
          }
        }
        return true;
    }
    return true; // Unknown stage; just kill it.
  }
}
