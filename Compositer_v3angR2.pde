// SWIM THAMES 2014
// Author: HENRY DAVID LOUTH

//Compositer_v1c fixed the MAX PTS voxelized
//Compositer_v1d fixed param controller colors
//compositer_v1f fixed influence at SETUP only
//compositer_v1h fixed importer for 6 and 10 values
//compositer_v1k fixed agent load and display (looping problem);
//compositer_v1n fixed boundary and outside/kill/rebirth in vfields;
//compositer_v1p fixed perspective camera settings
//compositer_v1r fixed exporter
//compositer_v1s fixed debugger display options
//compositer_v1t clean up main comments
//compositer_v1v automater working through a domain
//compositer_v1x transparency added to the save png as PGrahpsics object /fixed perspective/ twekaed agent params
//compositer_v2b added creation per active voxel
//v2bb   fixed persecptive to realistic gabriels
//v2e fixed creation in a vector that have magnitude of "0" threshold above

//v2f fixed random creation in voxels active
//v2g  fixed stabilized fow fiel d visual

//v3-----fixed vector summation of individual flow giuelds prior to esilon sum; weighting equilized





//libraries
import peasy.*;

//vec3d lib
import toxi.geom.*;


//CONTROL THE P5
import toxi.color.*;
import controlP5.*;

voxel[][][] voxelGridActing;


float vizScale=2;
int rez=6;

float followScale=1f;

boolean displayFlowfield = false;
boolean displayCompositeFields= false;

//DECLARATIONS
PeasyCam cam;

ArrayList<FlowFieldV2> flowfields;
PVector fMin, fMax;
PVector[] compFlowVecEndPts ;
PVector[] compFlowVecStartPts ;
int compPtCnt;
ArrayList<Agent> agents;

ImporterJa flowerfield;

String encoding;
float increment=200  ;
float domainMin=0;
float domainMax=1000;
float iteration=0;
int startFrame = 150;
int xprtFrame = startFrame/15;


int particlesPerVox = 50;


//--------------------------variables TO CONTROL PERHAPS CONTROLLER
float A_INF= 200 ;  //moorings 200
float B_INF = 800;  //programme 50
float C_INF = 1000;  //bridges 200
float D_INF = 800; //foreshore
float E_INF = domainMin;

//----------------------transperency of image
PGraphics frameToSave;
boolean bSaveToFile = false;
int hw, hh;


ControlP5 ui;
//Context bldgStart, bldgEnd, embankStart, embankEnd, trees, riverbed;
FlowFieldV2 flowfieldA, flowfieldB, flowfieldC, flowfieldD, flowfieldE;

// -------------------------- VOXELS
voxGrid spaceDiv ;
int xRes, yRes, zRes;
float ht, wid, depth;
float unitX, unitY, unitZ;
float radius = 0.1 ; // why this controlls the resolutuon i dont really know
PVector worldBoxMin, worldBoxMax ;
int resLim = 25  ;
int MAX_PTS = 1000000;
float MAX_DIS = radius * 100 ; 


// -------------------------- EXPORTER WRITER
ArrayList pointList;     // arraylist to store the points in
PrintWriter OUTPUT; // an instantiation of the JAVA PrintWriter object.
//SAVING AUTOMATION EXTENSIONS
String name;
boolean doSave=false;
int index=0, first, last, count;


ArrayList actingVoxels; //for the acting indexes


//-----------------------------inits
void setup() {
  size(1280, 720, P3D);
  hw = width/2;
  hh = height/2;


  ui = new ControlP5(this);
  ui.setAutoDraw(false);
  ui.setColorLabel(200);


  //automater
  //number of flowfields give length of encoding
  //encoding = "0,0,0,0,0";


  //EXPORT POINTS
  //pointList = new ArrayList();    // instantiate an ArrayList

  initContainers();





  //  bldgStart = new Context("/Users/hlouth/Documents/Processing/Stabilizer_v13/POINTS/BLDGSTART.txt");
  //  bldgEnd = new Context("/Users/hlouth/Documents/Processing/Stabilizer_v13/POINTS/BLDGEND.txt");
  //  embankStart = new Context("/Users/hlouth/Documents/Processing/Stabilizer_v13/POINTS/EMBANKSTART.txt");
  //  embankEnd= new Context("/Users/hlouth/Documents/Processing/Stabilizer_v13/POINTS/EMBANKEND.txt");
  //  trees = new Context("/Users/hlouth/Documents/Processing/Stabilizer_v13/POINTS/TREES.txt" );
  //  riverbed = new Context("/Users/hlouth/Documents/Processing/Stabilizer_v13/POINTS/RIVERBED.txt" );

  resetAll();




  //--------------CAMERA PERSPECTIVE
  //------------set cam dimensions after the voxels have been established 
  cam = new PeasyCam(this, wid/2-225, depth/2-50, ht/2-60, 200); //(parent, double lookAtX, double lookAtY, double lookAtZ, double distance);
  cam.rotateZ(radians(-215));  // rotate around the z-axis passing through the subject
  cam.rotateX(radians(135));  // rotate around the x-axis passing through the subject
  cam.rotateY(radians(-0));  // rotate around the y-axis passing through the subject

  cam.setMinimumDistance( 0.001 );
  cam.setMaximumDistance(  32 * ( 1000) );


  //--------------CAMERA PLAN VIEW
  //------------set cam dimensions after the voxels have been established 
  //cam = new PeasyCam(this, wid/2-225, depth/2-50, ht/2-50, 200); //(parent, double lookAtX, double lookAtY, double lookAtZ, double distance);
  //cam.rotateZ(radians(60));  // rotate around the z-axis passing through the subject
  //cam.rotateX(radians(-68));  // rotate around the x-axis passing through the subject
  //cam.rotateY(radians(-0));  // rotate around the y-axis passing through the subject

  cam.setMinimumDistance( 0.001 );
  cam.setMaximumDistance(  32 * ( 1000) );



  resetControllers();

  //voxelGridActing = new voxel[xRes][yRes][zRes] ;
  //
}

void draw() {
  //directionalLight(100, 100, 100, 0, 0, -1);
  //directionalLight(100, 100, 100, 0, 0, 1);
  //ambientLight(150, 150, 150);
  if (frameCount % xprtFrame == 0) {
    bSaveToFile=true;
    saveFrame( "frame_#####.png");
  }
  background(255);


  //make the filename for this iteration
  name=getIncrementalFilename("Compositer_v1x-####.png");


  //make transparent pgraphics to save out
  if (bSaveToFile)
  {

//    frameToSave = createGraphics(width, height, P3D);
//    frameToSave.beginDraw();
//    frameToSave.noFill();
    //     translate(hw, hh);
    //    frameToSave.translate(hw, hh);
  }
  //------go through agents and do shit
  for ( int i = 0; i < agents.size(); i ++) {

    if (agents.size()<=80000) agents.get(i).run();
    else agents.remove(i);
  }



  //---------------go through the context and render it
  //bldgStart.renderLines(bldgEnd, 255, 255, 255, 255);
  //embankStart.renderLines(embankEnd, 255, 255, 255, 255);
  //trees.displayPts(0, 255, 255, 75, 1f);
  //riverbed.displayPts(0, 255, 255, 75, 1f);
  //println(spaceDiv.voxelGrid[5][5][5].UnitVec);

  if (displayFlowfield) {
    flowfieldC.display(0, 255, 0, 255);
    flowfieldA.display(255, 0, 0, 255);
    flowfieldB.display(0, 0, 255, 255);

    flowfieldD.display(0, 255, 255, 255);
    //flowfieldE.display(255, 255, 0, 255);
  }

  if (displayCompositeFields) {
    spaceDiv.displayCompVecField(0, 120, 120, 255, .5); //(int R, int G, int B, int A, strokeweight)
    spaceDiv.display(true, .25);
  }

  if (ui.window(this).isMouseOver()) {
    cam.setActive(false);
  } 
  else {
    cam.setActive(true);
  }

  gui();

  if (bSaveToFile)
  {

//    frameToSave.endDraw();
//    frameToSave.save(name);
  }
  
//  if (frameCount % startFrame/10 == 0) {
//  saveFrame(name);
//  exportIteration();
//}

  if (frameCount % xprtFrame == 0) {
    bSaveToFile=false;
  }

 if (frameCount % startFrame == 0) {
    exportIteration();

    nextIteration();
    initContainers();
    resetAll();
    resetControllers();
    bSaveToFile=false;
  }
}



//-------------------------------------function to make the resoultion for voxelaed magique! 
void divide(float wid, float ht, float depth) { //setup the new works here

  zRes=rez;
  xRes=zRes*4;
  yRes=zRes*2;

  unitX = wid / (xRes);
  unitY = depth / (yRes);
  unitZ = ht / (zRes);
}

void gui() {
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  ui.draw();

  fill(0, 0, 0, 255);
  textSize(8);
  text("NUMBER PARTICLES = " + agents.size(), width-100, 20);
  text("VOXEL RESOLUTION " + rez, width-100, 30);
    text("X DIM :  " + unitX, width-100, 40);
        text("Y DIM :  " + unitY, width-100, 50);
            text("Z DIM :  " + unitZ, width-100, 60);

  textSize(11);
  text("EXPRESSION COMPOSITE", 20, 10);

  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}



public String getIncrementalFilename(String what) {
  int cntr=0;
  String s="", prefix, suffix, padstr, numstr;
  int index=first, last, count;
  File f;
  boolean ok;

  first=what.indexOf('#');
  last=what.lastIndexOf('#');
  count=last-first+1;

  if ( (first!=-1)&& (last-first>0)) {
    prefix=what.substring(0, first);
    suffix=what.substring(last+1);

    // Comment out if you want to use absolute paths
    // or if you're not using this inside PApplet
    if (sketchPath!=null) prefix=savePath(prefix);

    index=0;
    ok=false;

    do {
      padstr="";
      numstr=""+index;
      for (int i=0; i<count-numstr.length(); i++) padstr+="0";       
      s=prefix+padstr+numstr+suffix;

      f=new File(s);
      ok=!f.exists();
      cntr++;
      if (cntr==2) {
        index++;
        cntr=0;
      }

      // Provide a panic button. If index > 10000 chances are it's an 
      // invalid filename.
      if (index>10000) ok=true;
    } 
    while (!ok);

    // Panic button - comment out if you know what you're doing
    if (index>10000) {
      println("getIncrementalFilename thinks there is a problem - Is there "+
        " more than 10000 files already in the sequence or is the filename invalid?");
      return prefix+"ERR"+suffix;
    }
  }

  return s;
}


public void keyPressed() {
  if (key == ' ') {

    addAgents();
  }

  if (key == 'r') {
    resetAll();
  }

  if (key == 'p') {
    exportIteration();
  }


  if (key == 'd') {
    displayFlowfield = !displayFlowfield;
  }
  if (key == 'c') {
    displayCompositeFields = !displayCompositeFields;
  }


  //    if(key == 'r') record = !record;
}

void nextIteration() {
  //  String[] pieces = split(encoding, ",");
  //        int len = pieces.length ;
  //
  //        float a = float(pieces[0]);
  //        float b = float(pieces[1]);
  //        float c = float(pieces[2]);
  //        float d = float(pieces[3]);
  //        float e = float(pieces[4]);


  //----------------increase variables per the encoding
  A_INF=A_INF+increment;
  if (A_INF>domainMax) {
    A_INF=domainMin;
    B_INF=B_INF+increment;

    if (B_INF>domainMax) {
      B_INF=domainMin;
      C_INF=C_INF+increment;

      if (C_INF>domainMax) {
        C_INF=domainMin;
        D_INF=D_INF+increment;

        if (D_INF>domainMax) { 
          D_INF=domainMin;
          E_INF=E_INF+increment;

          if (E_INF>domainMax) { 
            E_INF=domainMin;
          }
        }
      }
    }
  }
} 

void exportIteration () {
  //--------------------------transparent frame save





  //-------output the text gile
  OUTPUT = createWriter(frameCount+".txt");          //file name
  for ( int i = 0; i < agents.size(); i ++) {
    Agent agent = agents.get(i);

    if (agent.trail.size() > 1) {
      for (int j = 1; j < agent.trail.size(); j++) {
        Vec3D v1 = (Vec3D) agent.trail.get(j);
        Vec3D v2 = (Vec3D) agent.trail.get(j - 1);
        
         PVector v22= new PVector(v2.x,v2.y,v2.z);
                        PVector v11= new PVector(v1.x,v1.y,v1.z);
        float d = v1.distanceTo(v2);
        if (d < 5) {
          
          
          
        
          float angl = degrees(PVector.angleBetween( v11, v22));
                                float ang = angl % 180;
                               // float an = map(ang, 0,180, 0, 50);
                                
        

if(ang>.4 && ang <80 ){

          OUTPUT.println(v1.x +","+v1.y+","+v1.z);
          OUTPUT.println(v2.x +","+v2.y+","+v2.z);
          ////        // export the integer
        }
        }
      }
    }
  }

  OUTPUT.flush();
  OUTPUT.close();
}

void resetAll() {
  flowfieldA = new FlowFieldV2("/Users/hlouth/Documents/Processing/Compositer_v3angR/FLOWFIELDS/MOORINGREAL.txt", A_INF);  //these are controlled in P5 live
  flowfieldB = new FlowFieldV2("/Users/hlouth/Documents/Processing/Compositer_v3angR/FLOWFIELDS/pleaseWork.txt", B_INF);
  flowfieldC = new FlowFieldV2("/Users/hlouth/Documents/Processing/Compositer_v3angR/FLOWFIELDS/BRIDGEALL.txt", C_INF);
  
  flowfieldD = new FlowFieldV2("/Users/hlouth/Documents/Processing/Compositer_v3angR/FLOWFIELDS/1635VEC.txt", D_INF);
  //flowfieldE = new FlowFieldV2("/Users/hlouth/Documents/Processing/Compositer_v1x/FLOWFIELDS/MATERIAL-T.txt", E_INF);

  flowfields.add(flowfieldA);
  flowfields.add(flowfieldB);
  flowfields.add(flowfieldC);
  flowfields.add(flowfieldD);
  // flowfields.add(flowfieldE);

  //function to compare box min and max of flowfields to set th max voxelization area
  //do some operations on the flowfields to get that bounding box extennts!!
  fMin = new PVector();
  fMax = new PVector();
  for (int i =0; i<flowfields.size(); i++) {
    FlowFieldV2 flowfield = flowfields.get(i);
    flowfield.ptsReader.boundingBox();
    PVector tmpMin=flowfield.ptsReader.reportBoxMin();
    PVector tmpMax=flowfield.ptsReader.reportBoxMax();

    if (i>=1) {
      if ( fMin.x < tmpMin.x )tmpMin.x =  fMin.x ;
      if ( fMin.y < tmpMin.y )tmpMin.y=  fMin.y ;
      if ( fMin.z < tmpMin.z )tmpMin.z =  fMin.z ;

      if ( fMax.x > tmpMax.x )tmpMax.x =  fMax.x ;
      if ( fMax.y > tmpMax.y )tmpMax.y =  fMax.y ;
      if ( fMax.z > tmpMax.z )tmpMax.z =  fMax.z ;
    }
    fMin=tmpMin;
    fMax=tmpMax;
  }
  wid = fMax.x - fMin.x ;
  depth = fMax.y - fMin.y ;
  ht = fMax.z - fMin.z ;

  divide(wid, ht, depth);


 
  
  
  
  //2. put all the vectors in a massive vector arraylist "composite" array
  for (int i =0; i<flowfields.size(); i++) {
    FlowFieldV2 flowfield = flowfields.get(i);
    for (int j=0; j<flowfield.vectorStartPts.size(); j++) {
      PVector tmp = flowfield.vectorEndPts.get(j);
      PVector tmpStart =flowfield.vectorStartPts.get(j);
      if ( compPtCnt < MAX_PTS )
      {
        compFlowVecEndPts [compPtCnt] = tmp;
        compFlowVecStartPts [compPtCnt] = tmpStart;


        //pprintln(tmp);
        compPtCnt++ ;
      }
    }
    spaceDiv = new voxGrid( xRes, yRes, zRes, MAX_PTS, compFlowVecEndPts, i) ;
  spaceDiv.boxMin = fMin ;
  spaceDiv.boxMax = fMax ;
  //3. MAKE A SPACE DIVISION HERE

  spaceDiv.build( wid, depth, ht) ;
  
    //5. add them all up; magnitude division by <size> of array used in addition
  spaceDiv.composeVec(); 

  spaceDiv.composeSums();
    
  }
    

 



  //------------
  actingVoxels= new ArrayList <PVector>();

  for ( int i =0 ; i < xRes ; i++ )
    for ( int j =0 ; j < yRes ; j++ )
      for ( int k =0 ; k < zRes ; k++ )
      {
        if ( spaceDiv.voxelGrid[i][j][k].cnt >  0 ) {
          if (spaceDiv.voxelGrid[i][j][k].UnitVec.x> .0025) {
            PVector tmp = new PVector (i, j, k);
            actingVoxels.add(tmp);
          }
        }
      }

  addAgents();
}

void addAgents() {

  for ( int i =0 ; i < actingVoxels.size() ; i++ ) {


    PVector tmp=(PVector)actingVoxels.get(i);
    //PVector cen=spaceDiv.voxelGrid[int(tmp.x)][int(tmp.y)][int(tmp.z)].lookUpCentroid();

    PVector mi=spaceDiv.voxelGrid[int(tmp.x)][int(tmp.y)][int(tmp.z)].lookUpBMin();
    PVector ma=spaceDiv.voxelGrid[int(tmp.x)][int(tmp.y)][int(tmp.z)].lookUpBMax();

    float mX=random(mi.x, ma.x);
    float mY=random(mi.y, ma.y);
    float mZ=random(mi.z, ma.z);


    Vec3D iniPos = new Vec3D (mX, mY, mZ);

    Vec3D iniVel = new Vec3D(0, 0, 0);


    for (int l=0; l<particlesPerVox; l++) {
      Agent a = new Agent( iniPos, iniVel);

      agents.add(a);
    }
  }
}

void resetControllers() {
  //CONTROL p5 SLider add ons
  ui.addSlider("A_INF", domainMin, domainMax, A_INF, 20, 20, 200, 9).setLabel(" : MOORING REVITALIZATION");   
  ui.addSlider("B_INF", domainMin, domainMax, B_INF, 20, 30, 200, 9).setLabel(" : PROGRAMME CONFIGURATION");
  ui.addSlider("C_INF", domainMin, domainMax, C_INF, 20, 40, 200, 9).setLabel(" : BANK BRIDGING");

  ui.addSlider("D_INF", domainMin, domainMax, D_INF, 20, 55, 200, 9).setLabel(" : TIDAL FORESHORE");
  ui.addSlider("E_INF", domainMin, domainMax, E_INF, 20, 65, 200, 9).setLabel(" : MATERIAL LOGIC");
}

void initContainers() {
  //-----ageency
  agents = new ArrayList<Agent>();
  //flow field init start here to redo an iteration
  flowfields = new ArrayList <FlowFieldV2> ();
  compFlowVecEndPts = new PVector[MAX_PTS] ;
  compFlowVecStartPts = new PVector[MAX_PTS] ;
  compPtCnt=0;
}

