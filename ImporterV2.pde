
class ImporterV2
{
  BufferedReader reader;
  String Line;
  String fileToRead ;
  int pt_cnt;
  int max_pts ;
  PVector[] pts ;
  PVector[] norms ;
  PVector boxMin, boxMax ;
  float scaleFac ;
  float wid, depth, ht ;
  ArrayList <PVector> baseStartPts;
    ArrayList <PVector> vectorEndPts;
   ArrayList <PVector> states;
float adj;
  


  ImporterV2()
  {
    fileToRead =  "C://points5.csv";
    Line = " 0,0,0 ";
    pt_cnt = 0 ;
    max_pts = 1000000;
    pts = new PVector[max_pts] ;
    scaleFac = 100 ;
    boxMin = new PVector( -500, -500, -500 );
    boxMax = new PVector( -500, -500, -500 );
    wid = ht = depth = 0;
    reader = createReader(fileToRead);
    baseStartPts= new ArrayList <PVector>();
    vectorEndPts= new ArrayList <PVector>();
    states= new ArrayList <PVector>();
  }

  // overloaded constructor 
  ImporterV2( String _fileToRead, int _max_pts, float _scaleFac)
  {

    fileToRead =  _fileToRead ;
    Line = " 0,0,0 ";
    pt_cnt = 0 ;


    max_pts = _max_pts;
    pts = new PVector[max_pts] ;
    norms = new PVector[max_pts] ;
    scaleFac = _scaleFac ;

    boxMin = new PVector( pow(10, 6), pow(10, 6), pow(10, 6) );
    boxMax = new PVector( -1*boxMin.x, -1*boxMin.y, -1*boxMin.z  );
    wid = ht = depth = 0;

    reader = createReader(fileToRead);
       baseStartPts= new ArrayList <PVector>();
    vectorEndPts= new ArrayList <PVector>();
    states= new ArrayList <PVector>();
  }

  // buffered reader - read line-by -line , extract text , convert to and store as points
  void readPts()
  {
    pt_cnt = 0;
    int recursionStack_chk = 0;
    while ( Line != null && recursionStack_chk < max_pts * 2 )
    {
      try 
      {
        Line = reader.readLine();
      } 
      catch (IOException e) 
      {
        e.printStackTrace();
        Line = null;
      }

      recursionStack_chk ++ ;

      if ( Line != null )
      {
        String[] pieces = split(Line, ",");
        int len = pieces.length ;
        if ( len == 10 ){

        float xPos = (float(pieces[0])*scaleFac)+adj ;
        float yPos = float(pieces[1])*scaleFac;
        float zPos = float(pieces[2])*scaleFac;

        float xVec = (float(pieces[3])*scaleFac)+adj;
        float yVec = float(pieces[4])*scaleFac;
        float zVec = float(pieces[5])*scaleFac;

        int iIndex = int(pieces[6]);
        int jIndex = int(pieces[7]);
      int kIndex = int(pieces[8]);

        int state = int(pieces[9]);

//        x *= scaleFac; 
//        y *= scaleFac; 
//        z *= scaleFac ;

        
        if ( pt_cnt < max_pts ){
        {
          pts [pt_cnt] = new PVector(xPos, yPos, zPos);
          baseStartPts.add(pts[pt_cnt]);
          
          pts [pt_cnt] = new PVector(xVec, yVec, zVec);
          vectorEndPts.add(pts[pt_cnt]);
          
          states.add(pts[pt_cnt]);
        }
        }
        

        //  norms [pt_cnt] = new PVector( nx,ny,nz );
        pt_cnt++ ;
        }
                if ( len == 6 ){

        float xPos = (float(pieces[0])*scaleFac)+adj ;
        float yPos = float(pieces[1])*scaleFac;
        float zPos = float(pieces[2])*scaleFac;

        float xVec = (float(pieces[3])*scaleFac)+adj;
        float yVec = float(pieces[4])*scaleFac;
        float zVec = float(pieces[5])*scaleFac;

       
        if ( pt_cnt < max_pts ){
        {
          pts [pt_cnt] = new PVector(xPos, yPos, zPos);
          baseStartPts.add(pts[pt_cnt]);
          
          pts [pt_cnt] = new PVector(xVec, yVec, zVec);
          vectorEndPts.add(pts[pt_cnt]);
          
          //states.add(pts[pt_cnt]);
        }
        }
        

        //  norms [pt_cnt] = new PVector( nx,ny,nz );
        pt_cnt++ ;
        }
        
        
        
        
        
      }
    }
  }

  //pt_cnt-= 1;


void boundingBox()
{
  boxMin = new PVector( pow(10, 10), pow(10, 10), pow(10, 10) );
  boxMax = new PVector( -1*boxMin.x, -1*boxMin.y, -1*boxMin.z  );

  for ( int i =0 ; i < pt_cnt ; i++ )
  {

    if ( pts[i].x < boxMin.x )boxMin.x =  pts[i].x ;
    if ( pts[i].y < boxMin.y )boxMin.y=  pts[i].y ;
    if ( pts[i].z < boxMin.z )boxMin.z =  pts[i].z ;

    if ( pts[i].x > boxMax.x )boxMax.x =  pts[i].x ;
    if ( pts[i].y > boxMax.y )boxMax.y =  pts[i].y ;
    if ( pts[i].z > boxMax.z )boxMax.z =  pts[i].z ;
  }

  boxMin.x -= 25; 
  boxMax.x += 25;
  boxMin.y -= 25; 
  boxMax.y += 25;
  boxMin.z -= 25; 
  boxMax.z += 25;

  wid = boxMax.x - boxMin.x ;
  depth = boxMax.y - boxMin.y ;
  ht = boxMax.z - boxMin.z ;
  //println("wid"+wid+"depth"+depth+"ht"+ht);
}



// display the point cloud ;
void display( boolean normal, float nScale )
{
  beginShape(POINTS);

  for ( int i =0 ; i < pt_cnt ; i++ )
  {
    //if( i == pt_cnt - 1 )stroke(255,0,0);
    vertex( pts[i].x, pts[i].y, pts[i].z );
  }

  endShape();

  /*if( normal )
   {
   beginShape(LINES);
   
   for( int i =0 ; i < pt_cnt ; i++ )
   {
   
   vertex( pts[i].x , pts[i].y , pts[i].z );
   vertex( pts[i].x + norms[i].x * nScale , pts[i].y + norms[i].y * nScale, pts[i].z + norms[i].z * nScale );
   }
   
   endShape();
   }*/
}

PVector lookUpBase(int l){
PVector tmp = baseStartPts.get(l);
return tmp;

}
PVector lookUpVec(int l){
PVector tmp = vectorEndPts.get(l);
return tmp;

}
Integer lookUpBaseSize(){
int i = baseStartPts.size();
return i;

}
Integer lookUpVecSize(){
int i = vectorEndPts.size();
return i;

}
//a function to report the mininmum pvector of the set
PVector reportBoxMin(){
  return boxMin;
}
PVector reportBoxMax(){
  return boxMax;
}

}
