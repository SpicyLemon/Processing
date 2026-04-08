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
}
