// A Palette is a collection of Color objects with some functions for manipulating them.
// The idea is that you store a Color object in your own object to use for drawing.
// Later, you can manipulate all of the things with that color by changing the palette entry for it.
class Palette {
  Color[] Colors;
  int colShift;
  
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
    if (this.colShift == 0) {
      return this.Colors[index];
    }
    int i = (index + this.colShift) % this.Colors.length;
    return this.Colors[i];
  }
  
  // Get a random Color (object) from this palette.
  Color Random() {
    return this.Colors[int(random(this.Colors.length))];
  }
  
  // Set the given index to the provided color value.
  // Returns itself so that it can be called multiple times in a row.
  Palette Set(int index, color value) {
    if (this.colShift == 0) {
      this.Colors[index].Value = value;
    } else {
      int i = (index + this.colShift) % this.Colors.length;
      this.Colors[i].Value = value;
    }
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
    this.colShift += 1;
    if (this.colShift > this.Colors.length) {
      this.colShift = 0;
    }
    return this;
  }
  
  // RotateRight moves the last color to the front, and returns itself.
  Palette RotateRight() {
    this.colShift -= 1;
    if (this.colShift < 0) {
      this.colShift += this.Colors.length;
    }
    return this;
  }
}
