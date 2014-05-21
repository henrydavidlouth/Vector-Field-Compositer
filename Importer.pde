
class Importer
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
  ArrayList <PVector> readerPts;
  

  


  Importer()
  {
    fileToRead =  "C://points5.csv";
    Line = " 0,0,0 ";
    pt_cnt = 0 ;
    max_pts = 25000;
    pts = new PVector[max_pts] ;
    scaleFac = 100 ;
    boxMin = new PVector( -500, -500, -500 );
    boxMax = new PVector( -500, -500, -500 );
    wid = ht = depth = 0;
    reader = createReader(fileToRead);
    readerPts= new ArrayList <PVector>();
  }

  // overloaded constructor 
  Importer( String _fileToRead, int _max_pts, float _scaleFac )
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
        readerPts= new ArrayList <PVector>();
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
        if ( len != 3 )continue ;

        float x = float(pieces[0]);
        float y = float(pieces[1]);
        float z = float(pieces[2]);

        //        float r = float(pieces[3])*1;

        //      float nx = float(pieces[4])*1;
        //      float ny = float(pieces[5])*1;
        //     float nz = float(pieces[6])*1;

        x *= scaleFac; 
        y *= scaleFac; 
        z *= scaleFac ;

        if ( pt_cnt < max_pts )
        {
          pts [pt_cnt] = new PVector( x, y, z );
          readerPts.add(pts[pt_cnt]);
        }


        //  norms [pt_cnt] = new PVector( nx,ny,nz );
        pt_cnt++ ;
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

PVector lookUpIndex(int l){
PVector tmp = readerPts.get(l);
return tmp;

}
Integer lookUpInt(){
int i = readerPts.size();
return i;

}

}
