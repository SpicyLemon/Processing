class SparseGrid<T> {
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
  
  T Get(Vertex v) {
    return this.Get(v.IndexX, v.IndexY);
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
  
  SparseGrid Set(Vertex v, T value) {
    return this.Set(v.IndexX, v.IndexY, value);
  }
  
  boolean Has(int x, int y) {
    return this.grid.containsKey(y) && this.grid.get(y).containsKey(x);
  }
  
  boolean Has(Vertex v) {
    return this.Has(v.IndexX, v.IndexY);
  }
  
  SparseGrid Delete(int x, int y) {
    HashMap<Integer, T> s = this.grid.get(y);
    if (s != null) {
      s.remove(x);
    }
    return this;
  }
  
  SparseGrid Delete(Vertex v) {
    return this.Delete(v.IndexX, v.IndexY);
  }
  
  ArrayList<T> GetAll() {
    ArrayList<T> rv = new ArrayList<T>();
    for (HashMap<Integer, T> s : this.grid.values()) {
      rv.addAll(s.values());
    }
    return rv;
  }
  
  ArrayList<Integer> GetYs() {
    ArrayList<Integer> rv = new ArrayList<Integer>(this.grid.keySet());
    Collections.sort(rv);
    return rv;
  }
  
  ArrayList<Integer> GetXs(Integer y) {
    HashMap<Integer, T> hm = this.grid.get(y);
    if (hm == null) {
      return new ArrayList<Integer>();
    }
    ArrayList<Integer> rv = new ArrayList<Integer>(hm.keySet());
    Collections.sort(rv);
    return rv;
  }
}
