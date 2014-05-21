class voxel
{


  PVector min ; // min point of bounding box
  PVector max ; // max point of bounding box
  int cnt ; // number of agents in voxel 
  int[] agentIds; // array to hold all agent ids in voxel 
  int maxCnt ; // max. number of agents allowed per voxel ;
  PVector boxCenter;
  PVector compVector;
    PVector compVectorBase;
    PVector XlatedVec;
    PVector UnitVec;
    PVector scaledUnitVec;
    

  ArrayList <PVector> allVecs;
  ArrayList <PVector> allVecsBases;
  
  PVector voxSum;
    ArrayList <PVector> allSums;


  

  
  
  // default constructor
  voxel()
  {
    min = new PVector(0,0,0);
    max = new PVector(0,0,0);
    
    boxCenter = new PVector(0,0,0);
        voxSum = new PVector(0,0,0);

      allSums = new ArrayList <PVector> ();


    allVecs = new ArrayList <PVector> ();
     allVecsBases = new ArrayList <PVector> ();
    compVector = new PVector(0,0,0);
        compVectorBase = new PVector(0,0,0);
  XlatedVec = new PVector(0,0,0);
 UnitVec = new PVector(0,0,0);
 scaledUnitVec = new PVector(0,0,0);

//sum=0;

    
    maxCnt = 250000;
    agentIds = new int[maxCnt] ;
    min.x = 0 ;min.y = 0 ;min.z = 0 ;
    max.x = 1 ;max.y = 1 ;max.z = 0 ;
    
        cnt = 0;
    
 

     //   mX.sub(mN);
//          v2.div(2);
//       v2.add(min);  
      // boxCenter=v4;
        

  }

  // alternate / over-loaded constructor
  voxel( PVector _min , PVector _max , int _maxCnt )
  {  
    max = _max; min = _min ;
    
    maxCnt = _maxCnt ;
    
    
    
  }

//--------------------------SEND INFO OUTSIDE CLASS
  PVector lookUpBMin(){
    return min;
  }
    PVector lookUpBMax(){
    return max;
  }
// void setScaleVec(float f){
// scaledUnitVec=UnitVec;
// 
// float fpercent = f/100;
// scaledUnitVec.mult(fpercent);
//         
// }
  
  PVector lookUpXVec(){
 PVector v1 = UnitVec;//we are going to alter this later based on a fixed skelton value
  PVector v2 = PVector.add(v1,boxCenter);
   XlatedVec = v2;
  
  return XlatedVec;
  }
  
  PVector lookUpUVec(){
 
  return UnitVec;
  }
  
  //FUNCTION TO MAKE  A BOX CENTER
     PVector lookUpCentroid(){

          //reate box center
 PVector mX=max;
 PVector mN=min;
 PVector v2= new PVector(0,0,0);
   PVector v3 = PVector.sub(mX, mN);
   v3.mult(.5);
   boxCenter = PVector.add(mN, v3);
   

 return boxCenter;
  }
 
 
 //----------------add the sets for this flowfield 
  void vecSums(){
  for (int i=0; i<allSums.size(); i++){
  PVector tmp= (PVector) allSums.get(i);
  UnitVec.add(tmp);
  
    PVector v1 = UnitVec;
//we are going to alter this later based on a fixed skelton value
v1.mult(A_INF/100);
scaledUnitVec=v1;
  }
  }
  
  
  
  // a function to add up all the vectors and take an average
  //** NOTE THEY WERE WEIGHTED PRIOR TO THIS GLOBALLY
  void vecEpsilon(){

    for (int i=0; i<allVecs.size(); i++){
      
      //add the states on off here?
    PVector tmp=allVecs.get(i);
   PVector tmpB=allVecsBases.get(i);
    compVector.add(tmp);
    compVectorBase.add(tmpB);
      }
      //it is still gloabal coordinates here
      compVector.div(allVecs.size());
      compVectorBase.div(allVecs.size());
       UnitVec = PVector.sub(compVector, compVectorBase);
       
voxSum=UnitVec;
allSums.add(voxSum);
       
     

allVecs = new ArrayList <PVector> ();
     allVecsBases = new ArrayList <PVector> ();
   
 UnitVec = new PVector(0,0,0);


      
      //make it local here
      //PVector v3 = PVector.sub(compVector, compVectorBase);

      
      //now make it glbal to the base point of the center
     //compVector = PVector.add(boxCenter, v3);
  }
  
  
  
  void draw(float sw)
  {

    noFill();
    float w = g.strokeWeight;
    strokeWeight(sw);
    
    beginShape(QUADS);
       
            vertex( min.x , min.y , min.z );
            vertex( min.x , max.y , min.z );
            vertex( max.x , max.y , min.z );
            vertex( max.x , min.y , min.z );
              
    endShape();
          
    beginShape(QUADS);
      
            vertex( min.x , min.y , max.z );
            vertex( min.x , max.y , max.z );
            vertex( max.x , max.y , max.z );
            vertex( max.x , min.y , max.z );
      
    endShape(CLOSE);
      
    beginShape(LINES) ;
            vertex( min.x , min.y , min.z );
                vertex( min.x , min.y , max.z );
            vertex( min.x , max.y , min.z );
                vertex( min.x , max.y , max.z );
            vertex( max.x , max.y , min.z );
              vertex( max.x , max.y , max.z );
            vertex( max.x , min.y , min.z );
              vertex( max.x , min.y , max.z );
    endShape(CLOSE);
    
    strokeWeight(w);
    fill(255);
  }
}

