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

// A Palette is a collection of Color objects with some functions for manipulating them.
// The idea is that you store a Color object in your own object to use for drawing.
// Later, you can manipulate all of the things with that color by changing the palette entry for it.
class Palette {
  Color[] Colors;
  
  // Initialize the palette with the given size.
  // Colors are on a gradient from black to white.
  // Set them as needed using .Set(index, color).
  Palette(int size) {
    this(size, #000000, #FFFFFF);
  }
  
  // Create a palette with the given size on a gradient from fromColor to toColor.
  Palette(int size, color fromColor, color toColor) {
    this.Colors = new Color[size];
    this.Colors[0] = new Color(fromColor);
    this.Colors[size-1] = new Color(toColor);
    for (int i = 1; i < size-1; i++) {
      this.Colors[i] = new Color(lerpColor(fromColor, toColor, (float)i / (float)(size-1)));
    }
  }
  
  // Create a palette with the given size on a gradient from fromColor to toColor.
  // All colors will have the given alpha (0 to 255).
  Palette(int size, color fromColor, color toColor, int alpha) {
    this(size, fromColor, toColor);
    for (Color col : this.Colors) {
      col.SetAlpha(alpha);
    }
  }
  
  // Create a palette with the provided colors.
  Palette(color... colors) {
    this.Colors = new Color[colors.length];
    for (int i = 0; i < colors.length; i++) {
      this.Colors[i] = new Color(colors[i]);
    }
  }
  
  // Combine multiple palettes into a new one.
  // The new palette will have new Color instances.
  // Changing one will not affect the other.
  Palette(Palette... palettes) {
    int size = 0;
    for (Palette pal : palettes) {
      size += pal.Size();
    }
    this.Colors = new Color[size];
    int i = 0;
    for (Palette pal : palettes) {
      for (Color col : pal.Colors) {
        this.Colors[i] = new Color(col.Value);
        i++;
      }
    }
  }
  
  // Append will add copies of the colors in the provided palette to the end
  // of this palette. If the last color of this palette equals the first color
  // of the provided palette, that entry is skipped.
  // Returns itself.
  Palette Append(Palette that) {
    int thisLen = this.Colors.length;
    int thatLen = that.Colors.length;
    int newSize = thisLen + thatLen;
    
    boolean skipFirst = thisLen > 0 && thatLen > 0 && this.Colors[thisLen-1].Value == that.Colors[0].Value;
    if (skipFirst) {
      newSize--;
    }
    this.Colors = (Color[])expand(this.Colors, newSize);
    
    int di = thisLen;
    int i = 0;
    if (skipFirst) {
      di--;
      i++;
    }
    for (; i < thatLen; i++) {
      this.Colors[di+i] = new Color(that.Colors[i].Value);
    }
    return this;
  }
  
  // WithAlphaGradient sets the alpha of each color to a gradient as provided.
  Palette WithAlphaGradient(int zerothValue, int lastValue) {
    float mult = ((float)lastValue - (float)zerothValue)/(float)this.Colors.length;
    for (int i = 0; i < this.Colors.length; i++) {
      int alpha = (int)(mult*(float)(i+1.0));
      this.Colors[i].SetAlpha(alpha);
    }
    return this;
  }
  
  // Size returns the number of colors in this palette.
  int Size() {
    return this.Colors.length;
  }
  
  // Get the Color (object) at the given index.
  Color Get(int index) {
    return this.Colors[index];
  }
  
  // Set the given index to the provided color value.
  // Returns itself so that it can be called multiple times in a row.
  Palette Set(int index, color value) {
    this.Colors[index].Value = value;
    return this;
  }

  // SetAlpha will set the alpha value for all colors in this palette.
  // Returns itself.
  Palette SetAlpha(int alpha) {
    for (Color col : this.Colors) {
      col.SetAlpha(alpha);
    }
    return this;
  }
  
  // AddAlpha will add the provided delta to all colors in this palette.
  // Returns itself.
  Palette AddAlpha(int dalpha) {
    for (Color col : this.Colors) {
      col.AddAlpha(dalpha);
    }
    return this;
  }
  
  // RotateLeft moves the first color to the end, and returns itself.
  Palette RotateLeft() {
    color firstValue = this.Colors[0].Value;
    for (int i = 0; i < this.Colors.length - 1; i++) {
      this.Colors[i].Value = this.Colors[i+1].Value;
    }
    this.Colors[this.Colors.length-1].Value = firstValue;
    return this;
  }
  
  // RotateRight moves the last color to the front, and returns itself.
  Palette RotateRight() {
    color lastValue = this.Colors[this.Colors.length-1].Value;
    for (int i = this.Colors.length-1; i > 0; i--) {
      this.Colors[i].Value = this.Colors[i-1].Value;
    }
    this.Colors[0].Value = lastValue;
    return this;
  }
}
