// The color class wraps a native color value in an object so that 
// the colors of multiple things can be updated at the same time.
class Color {
  color Value;
  
  Color(color c) {
    this.Value = c;
  }
  
  Color(int red, int green, int blue) {
    this.Value = color(red, green, blue);
  }
  
  Color(int red, int green, int blue, int alpha) {
    this.Value = color(red, green, blue, alpha);
  }
  
  int Alpha() {
    return this.Value >> 24 & 0xFF;
  }
  
  int Red() {
    return this.Value >> 16 & 0xFF;
  }
  
  int Green() {
    return this.Value >> 8 & 0xFF;
  }
  
  int Blue() {
    return this.Value & 0xFF;
  }
  
  color Opposite() {
    return this.Value ^ 0x00FFFFFF;
  }
  
  Color Set(color col) {
    this.Value = col;
    return this;
  }
  
  Color SetAlpha(int alpha) {
    this.Value = (this.Value & 0x00FFFFFF) | ((alpha & 0xFF) << 24);
    return this;
  }
  
  Color SetRed(int red) {
    this.Value = (this.Value & 0xFF00FFFF) | ((red & 0xFF) << 16);
    return this;
  }
  
  Color SetGreen(int green) {
    this.Value = (this.Value & 0xFFFF00FF) | ((green & 0xFF) << 8);
    return this;
  }
  
  Color SetBlue(int blue) {
    this.Value = (this.Value & 0xFFFFFF00) | (blue & 0xFF);
    return this;
  }

  // AddAlpha adds the provided delta to the alpha value.
  // If the resulting value is less than 0 or more than 255, the result will be either 0 or 255 respectively.
  Color AddAlpha(int delta) {
    return this.SetAlpha(max(min(this.Alpha() + delta, 255), 0));
  }

  // AddRed adds the provided delta to the red value.
  // If the resulting value is less than 0 or more than 255, the result will be either 0 or 255 respectively.
  Color AddRed(int delta) {
    return this.SetRed(max(min(this.Red() + delta, 255), 0));
  }

  // AddGreenm adds the provided delta to the green value.
  // If the resulting value is less than 0 or more than 255, the result will be either 0 or 255 respectively.
  Color AddGreen(int delta) {
    return this.SetGreen(max(min(this.Green() + delta, 255), 0));
  }
  
  // AddBlue adds the provided delta to the blue value.
  // If the resulting value is less than 0 or more than 255, the result will be either 0 or 255 respectively.
  Color AddBlue(int delta) {
    return this.SetBlue(max(min(this.Blue() + delta, 255), 0));
  }
  
  // AddRBG adds the provided deltas to this color.
  // If any resulting value is less than 0 or more than 255, that value ends up being either 0 or 255 respectively.
  Color AddRGB(int dred, int dgreen, int dblue) {
    return this.AddRed(dred).AddGreen(dgreen).AddBlue(dblue);
  }
  
  // AddRGBAlpha adds the provided deltas to this color.
  // If any resulting value is less than 0 or more than 255, that value ends up being either 0 or 255 respectively.
  Color AddRGBAlpha(int dred, int dgreen, int dblue, int dalpha) {
    return this.AddRed(dred).AddGreen(dgreen).AddBlue(dblue).AddAlpha(dalpha);
  }
}

class Point {
  float X;
  float Y;
  Color Col;

  Point(float x, float y, Color col) {
    this.X = x;
    this.Y = y;
    this.Col = col;
  }
}
