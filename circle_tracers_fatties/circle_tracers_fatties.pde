Palette colors;
Tracer[] tracers;
boolean mouseWasPressed = false;
boolean drawPalette = false;


void setup() {
  fullScreen();
  colors = new Palette(20, #AA0000, #0000FF);
  freshTracers();
}

void draw() {
  background(0);
  for (Tracer tracer : tracers) {
    tracer.Move().Draw();
  }
  
  if (mouseWasPressed) {
    mouseWasPressed = false;
  }
  if (drawPalette) {
    for (int i = 0; i < colors.Size(); i++) {
      noStroke();
      fill(colors.Get(i).Value);
      rect(i*50, 0, 50, 50);
    }
  }
}

void mousePressed() {
  mouseWasPressed = true;
}

void freshTracers() {
  int mult = 3;
  tracers = new Tracer[colors.Size()*mult];
  for (int i = 0; i < colors.Size(); i++) {
    for (int j = 0; j < mult; j++) {
      tracers[i*mult+j] = newRandomTracer(colors.Get(i));
    }
  }
}

Tracer newRandomTracer(Color col) {
  float r = random(height/2.0-5.0)+5.0;
  float speed = random(-8.0, 8.0);
  if (speed < 0) {
    speed -= 2;
  } else {
    speed += 2;
  }
  return new Tracer(random(r, width-r), random(r, height-r))
              .WithRadius(r)
              .WithSpeed(speed)
              .WithAngle(random(TWO_PI))
              .WithTail(10)
              .WithColor(col);
}
