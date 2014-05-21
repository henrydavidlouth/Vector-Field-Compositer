// ****SWIM THAMES 2013 AADRL
// 1. IMPORTS A SERIES OF BASEPOINTS
// 2. IMPORTS A SERIES OF FLOW VECTORS FROM THOSE POINTS
// 3. VOXELIZES THE BASEPOINTS ONLY (HEADINGS WILL FALL IN OUTHER VOXLS)
// 4. INFLUENCE - TAKE PROPORTION OF MAGNITUDE EST IN GLOBAL VARIABLES AS A COPY
// 5. GO THROUGH EVERY VOXEL ADD ALL THE AVAILABLE VECTORS TOGETHER
// 6. TRANSLATE TO CEENTER OF VOXEL
// 7. ESTABLISH A lookup() TO GET THAT PVECTOR FOR FOLLOWING
// 8. ----MAKE MAGIC


  // A flow field is a set of basepoints imported and offset by their requisiite vector values
  
class FlowFieldV2 {

  // READER 
int MAX_PTS = 1000000;
ImporterV2 ptsReader;
float influence;

//localized class variable
ArrayList <PVector> baseStartPts;
ArrayList <PVector> baseEndPts;
    ArrayList <PVector> vectorEndPts;
     ArrayList <PVector> vectorStartPts;
    






  FlowFieldV2(String fileToRead, float p) {
    baseStartPts= new ArrayList <PVector>();
    baseEndPts= new ArrayList <PVector>();
    vectorEndPts= new ArrayList <PVector>();
    vectorStartPts= new ArrayList <PVector>();
    
    ptsReader = new ImporterV2( fileToRead, MAX_PTS, 1);

influence=p;
    init();
    loadPts();
    globalise();
    localise();

  }

  void init() {
 ptsReader.readPts() ;
  }
  

void loadPts(){
  for (int i=0; i<ptsReader.lookUpBaseSize(); i++){
      PVector v1= ptsReader.lookUpBase(i);
      baseStartPts.add(v1);
  }
  for (int j=0; j<ptsReader.lookUpVecSize(); j++){
      PVector v2= ptsReader.lookUpVec(j);
      v2.mult(influence/100);
      vectorEndPts.add(v2);
  }
 
  
}


void globalise(){
 for (int i=0; i<baseStartPts.size(); i++){
      PVector tmp1=baseStartPts.get(i);
      PVector tmp2=vectorEndPts.get(i);
      tmp2.add(tmp1);
      baseEndPts.add(tmp2);
  }

}

void localise(){
vectorStartPts=baseStartPts;
}


void display(int R, int G, int B, int A) {
     for (int i=0; i<baseStartPts.size(); i++){
      PVector v1= baseStartPts.get(i);
      PVector v2= vectorEndPts.get(i);
      stroke(R,G,B,A);
      strokeWeight(.25);
      line (v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);
      }
    
    
  }

  
  void drawVector(PVector v, float x, float y, float scayl) {
    
}
 

}



