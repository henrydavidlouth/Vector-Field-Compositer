// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Flow Field Following

class FlowField {

  // A flow field is a two dimensional array of PVectors
  PVector[][] field;
  int cols, rows; // Columns and Rows
  int resolution; // How large is each "cell" of the flow field

  //cyclical
  int tCycle =360*4;
  float [] zValues = new float [tCycle];
  float [] xValues = new float [tCycle];
  float deltaZ = 500;
  float deltaX = 15000;
  int count = 0;

  FlowField(int r) {
    resolution = r;
    // Determine the number of columns and rows based on sketch's width and height
    cols = width/resolution;
    rows =height/resolution*2;
    field = new PVector[cols][rows];
    init();
  }

  void init() {
    // Reseed noise so we get a new flow field every time
    //noiseSeed((int)random(10000));
    //float xoff = 0;
    for (int i = 0; i < cols; i++) {
      //float yoff = 0;
      for (int j = 0; j < rows; j++) {
        //float theta = map(noise(xoff,yoff),0,1,0,TWO_PI);
        // Polar to cartesian coordinate transformation to get x and y components of the vector
        field[i][j] = new PVector(0, 0);
        //yoff += 0.1;
      }
      //xoff += 0.1;
    }
  }

  // Draw every vector
  void display() {
    //float xoff = 0;
    for (int i=0; i<count+1; i++) {
      zValues[i] = cos(4*PI*i/tCycle)*deltaZ;
      xValues[i] = 6*sin(4*PI*i/tCycle)*deltaX;
      for (int j = 0; j < cols; j++) {
        //float yoff = 0;
        for (int k = 0; k < rows; k++) {
          //float theta = map(noise(xoff,yoff),0,1,0,TWO_PI);
          // Polar to cartesian coordinate transformation to get x and y components of the vector
          field[j][k] = new PVector(xValues[i], 0, zValues[i]);
          //yoff += 0.1;
          // Display some info
//          fill(0);
//          text("Velocity X: " + xValues[i], 10, 18);
//          text("Velocity Z: " + zValues[i], 10, 36);
        }
        //xoff += 0.1;
      }

      //println(xValues[i]);
    }
    count++;
    if (count==tCycle-1) {
      count =0;
    }
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        drawVector(field[i][j], i*resolution, j*resolution, 50);
      }
    }
  }

  // Renders a vector object 'v' as an arrow and a location 'x,y'
  void drawVector(PVector v, float x, float y, float scayl) {
    pushMatrix();
    float arrowsize = 4;
    // Translate to location to render vector
    translate(x, y);
    stroke(255, 255,0);
    // Call vector heading function to get direction (note that pointing up is a heading of 0) and rotate
    rotate(v.heading2D());
    // Calculate length of vector & scale it to be bigger or smaller if necessary
    float len = v.mag()*scayl;
    // Draw three lines to make an arrow (draw pointing up since we've rotate to the proper direction)
    for (int j = 0; j < cols; j++) {
      for (int k = 0; k < rows; k++) {

        line(0, 0,0, field[j][k].x ,0, -field[j][k].z );
      }
    }
    popMatrix();
    //line(len,0,len-arrowsize,+arrowsize/2);
    //line(len,0,len-arrowsize,-arrowsize/2);
  }

  PVector lookup(PVector lookup) {
    int column = int(constrain(lookup.x/resolution, 0, cols-1));
    int row = int(constrain(lookup.y/resolution, 0, rows-1));
    return field[column][row].get();
  }
}



