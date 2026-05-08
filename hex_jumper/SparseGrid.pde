class SparseGrid<T extends Comparable<T>> {
  HashMap<Integer, HashMap<Integer, T>> grid;
  
  SparseGrid() {
    this.grid = new HashMap<Integer, HashMap<Integer, T>>();
  }
  
  T Get(int x, int y) {
    HashMap<Integer, T> s = this.grid.get(y);
    if (s == null) {
      return null;
    }
    return s.get(x);
  }
  
  SparseGrid Set(int x, int y, T value) {
    HashMap<Integer, T> s = this.grid.get(y);
    if (s == null) {
      s = new HashMap<Integer, T>();
      this.grid.put(y, s);
    }
    s.put(x, value);
    return this;
  }
  
  boolean Has(int x, int y) {
    return this.grid.containsKey(y) && this.grid.get(y).containsKey(x);
  }
  
  ArrayList<T> GetAll() {
    ArrayList<T> rv = new ArrayList<T>();
    for (HashMap<Integer, T> s : this.grid.values()) {
      rv.addAll(s.values());
    }
    Collections.sort(rv);
    return rv;
  }
}
