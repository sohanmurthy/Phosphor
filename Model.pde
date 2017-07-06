//Defines the model

static class Model extends LXModel {
  
  public Model() {
    super(new Fixture());
  }
  
  private static class Fixture extends LXAbstractFixture {
    
    private static final int MATRIX_SIZE = 20;
    private static final float SPACING = 2.5*INCHES;
    
    private Fixture() {
      // Generate positions of points on model
      for (int x = 0; x < MATRIX_SIZE; ++x) {
        for (int y = 0; y < MATRIX_SIZE; ++y) {       
            // Adds points to the fixture
            addPoint(new LXPoint(x*SPACING, y*SPACING));          
        }
      }
    }
  }
}