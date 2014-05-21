class voxGrid
{

  int xRes, yRes, zRes ;
  voxel[][][] voxelGrid ;
  int maxCnt ;
  float unitX, unitY, unitZ ;
  PVector boxMin;
  PVector boxMax;
  //PVector boxCenter;
  float vScl;


  PVector[] pts;
  PVector[] ori_pts;
  float[] radii ;
  int[] nearestIds ;
  int pt_cnt ;
  int max_n_cnt ;
  // for neighbor checking
  float minD;
  PVector curPt, leastPoint ;

  int[] allNeighborIds ;
  int nCnt ;


  // constructor       
  voxGrid()
  {
    xRes = yRes = 1 ;
    zRes = 12 ;
    maxCnt = 250000;
    boxMin = new PVector( -500, -500, -500 );
    boxMax = new PVector( 500, 500, 500 );

    //set the init influence influence
    vScl=100;

    voxelGrid = new voxel[xRes][yRes][zRes] ;


    for ( int i =0 ; i < xRes ; i++ )
      for ( int j =0 ; j < yRes ; j++ )
        for ( int k =0 ; k < zRes ; k++ )
        {
          voxelGrid[i][j][k] = new voxel() ;
        }

    max_n_cnt = 1500 ;   
    allNeighborIds = new int[max_n_cnt] ;
  }

  // overloaded constructor 
  voxGrid( int _xRes, int _yRes, int _zRes, int _maxCnt, PVector[] _pts, int _pt_cnt )
  {
    xRes = _xRes ;
    yRes = _yRes ;
    zRes = _zRes ;
    maxCnt = _maxCnt;

    voxelGrid = new voxel[xRes][yRes][zRes] ;
    for ( int i =0 ; i < xRes ; i++ )
      for ( int j =0 ; j < yRes ; j++ )
        for ( int k =0 ; k < zRes ; k++ )
        {
          voxelGrid[i][j][k] = new voxel() ;
        }

    pts = _pts;  

    pt_cnt = _pt_cnt ;
    radii = new float[ _pt_cnt] ;
    for ( int i =0 ; i < pt_cnt ; i++ )radii[i] = 0;

    max_n_cnt = _pt_cnt  ;   
    allNeighborIds = new int[max_n_cnt] ;

    nearestIds = new int[ pt_cnt ];
    for ( int i =0 ; i < pt_cnt ; i++ )nearestIds[i] = -1;

    nCnt = 0;
  }

  // ----------------------------------------------   UPDATE VOXELS _ UTILITY FUNCTION
  int updateVoxelCounts( int u, int v, int n, int i ) 
  {
    if ( u >= xRes || v >= yRes || n >=zRes )return 0 ;
    if ( u < 0 || v < 0 )return 0 ;

    int currentCnt  = voxelGrid[u][v][n].cnt ;

    if (currentCnt >= maxCnt )return 0 ;

    voxelGrid[u][v][n].agentIds[currentCnt] = i ;
    voxelGrid[u][v][n].cnt += 1;

    return 1 ;
  }


  // ----------------------------------------------  BUILD AND UPDATE VOXELS

  void build( float wid, float depth, float ht  )
  {
    for ( int i =0 ; i < xRes ; i++ )
      for ( int j =0 ; j < yRes ; j++ )
        for ( int k =0 ; k < zRes ; k++ )
        {
          voxelGrid[i][j][k].cnt = 0 ;
        }

    unitX = wid / (xRes);
    unitY = depth / (yRes);
    unitZ = ht / (zRes);

    for ( int i =0 ; i < xRes ; i++ )
      for ( int j =0 ; j < yRes ; j++ )
        for ( int k =0 ; k < zRes ; k++ )
        {
          voxelGrid[i][j][k].min.x =  (float)(i) * unitX + boxMin.x  ;
          voxelGrid[i][j][k].min.y = (float)(j) * unitY + boxMin.y;
          voxelGrid[i][j][k].min.z =  (float)(k) * unitZ + boxMin.z;

          voxelGrid[i][j][k].max.x =  (float)(i+1) * unitX + boxMin.x ;
          voxelGrid[i][j][k].max.y =  (float)(j+1) * unitY + boxMin.y;
          voxelGrid[i][j][k].max.z =  (float)(k+1) * unitZ + boxMin.z;
        }

    int u, v, n ;
    for ( int i =0 ; i < compPtCnt ; i++ )
    {
      //u=v=n=0;
      u = floor( (compFlowVecEndPts[i].x - boxMin.x ) / unitX );
      v = floor( (compFlowVecEndPts[i].y - boxMin.y ) / unitY );
      n = floor( (compFlowVecEndPts[i].z - boxMin.z ) / unitZ );

      // update the agent counter per voxel, for current voxel.
      updateVoxelCounts(u, v, n, i);
    }
  }

  // ---------------------------------------------- NEIGHBOR SEARCH _ UTILITY FUNCTION
  int checkNeighborVoxels_lowestZ( int m, int n, int p, int i, float maxR ) 
  {
    int agentId = -1 ;
    // error check : making sure voxel array indices are within bounds
    if ( m >= xRes || n >= yRes || p >= zRes )return 0 ;
    if ( m < 0 || n < 0 || p < 0 )return 0 ;

    int currentCnt  = voxelGrid[m][n][p].cnt ;

    // error check : making sure  agent array indices are within bounds
    if (currentCnt >= maxCnt )return 0 ;
    if (currentCnt == 0 )return 0 ;

    // iterate through agents, calc squared distances;
    for ( int k =0 ; k < currentCnt ; k++ )
    {
      //agent id  
      int id = voxelGrid[m][n][p].agentIds[k] ;

      // error check : making sure agent id is not the same as the current agent
      if ( id == i )continue ;

      // get nBor location
      PVector nBor_AgentPos = pts[id];
      ;

      // calc squared distances ... sqrt is an expensive calculation
      //float sqDis  = pow(curPt.x-nBor_AgentPos.x,2)+pow(curPt.y-nBor_AgentPos.y,2)+pow(curPt.z-nBor_AgentPos.z,2) ;
      float delX = curPt.x-nBor_AgentPos.x ;
      float delY = curPt.y-nBor_AgentPos.y ;

      // update least distance
      if ( ( nBor_AgentPos.z < minD  )  &&  delX < maxR && delY < maxR   )
      {
        minD = nBor_AgentPos.z ;
        leastPoint = nBor_AgentPos ;    
        agentId = id;      
        //println( agentId + " -------- " ) ;
        break;
      }
    }

    return agentId ;
  }

  // ---------------------------------------------- NEIGHBOR SEARCH

  //      PVector lowestPointInNeighborhood( PVector _str , float searchRadius , int nBor_search_ring )
  //      {
  //          PVector str = _str ;
  //          int u = floor( (str.x - worldBoxMin.x ) / unitX );
  //          int v = floor( (str.y - worldBoxMin.y ) / unitY );
  //          int n = floor( (str.z - worldBoxMin.z ) / unitZ );
  //  
  //         leastPoint = str ;
  //         curPt = str ;
  //         minD = str.z ;
  //         int rCnt = 0;
  //         int s ,e ; s = e = 1;
  //
  //         int id = -1;
  //         int chk_id = 0 ;
  //
  //              while( rCnt < nBor_search_ring )
  //              {
  //                
  //                for(int z = n-s; z <= n+e; z++)
  //                  {
  //                    for(int x = u-s; x <=u+e; x++)
  //                    {
  //                        for(int y = v-s; y <=v+e; y++)
  //                        {
  //                            chk_id = checkNeighborVoxels_lowestZ( x,y,z, pts.length + 1, searchRadius );
  //                            
  //                            if( (str.z != leastPoint.z)  ) 
  //                            {
  //                              id = chk_id ;                         
  //                              break ;
  //                            }
  //                        }
  //                     
  //                        if( (str.z != leastPoint.z)  ) break ;
  //
  //                    }
  //                    
  //                    if( (str.z != leastPoint.z)  ) break;
  //                  }
  //        
  //                  if( (str.z != leastPoint.z)  ) 
  //                  {
  //                        if( id != -1 && id != 0 )
  //                        {
  //                          radii[id] += 0.15 ;
  //                          if(radii[id] > 16 )radii[id] = 16 ;
  //                         // println(id + " ---- if" ); 
  //                        }
  //                     
  //                    break ;
  //                  }
  //                
  //                 s += 1;
  //                 
  //                 rCnt++ ;
  //                }
  //                    
  //       return leastPoint ;
  //      
  //      }
  //      

  int nearestPt( PVector _str, int searchRing, int id )
  {
    PVector str = _str ;
    int xId, yId, zId ;
    xId = floor( (str.x - boxMin.x ) / unitX );
    yId = floor( (str.y - boxMin.y ) / unitY );
    zId = floor( (str.z - boxMin.z ) / unitZ );

    nCnt = 0; 

    for ( int u = xId -searchRing ; u <= xId + searchRing ; u++ )
    {
      for ( int v = yId -searchRing ; v <= yId + searchRing ; v++ )
      {
        for ( int n = zId -searchRing ; n <= zId + searchRing ; n++ )
        {
          if ( u >= xRes || v >= yRes || n >= zRes ) continue ;
          if ( u < 0 || v < 0 || n < 0 )continue ;

          int totalNumPtsInBox = spaceDiv.voxelGrid[u][v][n].cnt ;
          if ( totalNumPtsInBox == 0  ) continue ;

          for (int l = 0; l < totalNumPtsInBox ; l ++)
          {  
            int n_id = spaceDiv.voxelGrid[u][v][n].agentIds[l];
            allNeighborIds[nCnt] = n_id ;
            nCnt++ ;
          }
        }
      }
    }

    nCnt-- ;
    minD = pow(10, 10);
    int nearestId = -1; 

    for ( int i = 0; i < nCnt ; i ++ )
    {
      if ( id == allNeighborIds[i] ) continue ;

      PVector pt = pts[ allNeighborIds[i] ] ;
      float sqDis  = pow(str.x-pt.x, 2) + pow(str.y-pt.y, 2) + pow(str.z-pt.z, 2) ;
      // if( sqDis < 10 * 10  ) continue ;

      if ( sqDis < minD &&  pt.z < str.z )
      {
        minD = sqDis;
        nearestId = allNeighborIds[i] ;
      }
    }

    return nearestId ;
  }





  // ---------------------------------------------- RANDOM POINT 1
  int randomPt1( PVector _str, int searchRing, int id )
  {
    PVector str = _str ;
    int xId, yId, zId ;
    xId = floor( (str.x - boxMin.x ) / unitX );
    yId = floor( (str.y - boxMin.y ) / unitY );
    zId = floor( (str.z - boxMin.z ) / unitZ );

    nCnt = 0; 

    for ( int u = xId -searchRing ; u <= xId + searchRing ; u++ )
    {
      for ( int v = yId -searchRing ; v <= yId + searchRing ; v++ )
      {
        for ( int n = zId  -searchRing   ; n <= zId + searchRing    ; n++ )
        {
          if ( u >= xRes || v >= yRes || n >= zRes ) continue ;
          if ( u < 0 || v < 0 || n < 0 )continue ;

          int totalNumPtsInBox = spaceDiv.voxelGrid[u][v][n].cnt ;
          if ( totalNumPtsInBox == 0  ) continue ;

          for (int l = 0; l < totalNumPtsInBox ; l ++)
          {  
            int n_id = spaceDiv.voxelGrid[u][v][n].agentIds[l];
            allNeighborIds[nCnt] = n_id ;
            nCnt++ ;
          }
        }
      }
    }

    nCnt-- ;
    minD = pow(10, 10);
    if ( nCnt == 0 )return -2 ;

    //  return allNeighborIds[ int( random(0,nCnt)) ];

    int nearestId = -1 ;
    for ( int i = 0; i < nCnt ; i ++ )
    {
      nearestId = allNeighborIds[ int( random(0, nCnt)) ];
      PVector pt = pts[ allNeighborIds[nearestId] ] ;
      if ( pt.z < str.z )return nearestId ;
    } 

    return nearestId ;
  }




  // ---------------------------------------------- RANDOM POINT 2
  int randomPt2( PVector _str, int searchRing, int id )
  {
    PVector str = _str ;
    int xId, yId, zId ;
    xId = floor( (str.x - boxMin.x ) / unitX );
    yId = floor( (str.y - boxMin.y ) / unitY );
    zId = floor( (str.z - boxMin.z ) / unitZ );

    nCnt = 0; 

    for ( int u = xId -searchRing ; u <= xId + searchRing ; u++ )
    {
      for ( int v = yId -searchRing ; v <= yId + searchRing ; v++ )
      {
        for ( int n = zId    ; n <= zId + searchRing ; n++ )
        {
          if ( u >= xRes || v >= yRes || n >= zRes ) continue ;
          if ( u < 0 || v < 0 || n < 0 )continue ;

          int totalNumPtsInBox = spaceDiv.voxelGrid[u][v][n].cnt ;
          if ( totalNumPtsInBox == 0  ) continue ;

          for (int l = 0; l < totalNumPtsInBox ; l ++)
          {  
            int n_id = spaceDiv.voxelGrid[u][v][n].agentIds[l];
            allNeighborIds[nCnt] = n_id ;
            nCnt++ ;
          }
        }
      }
    }

    nCnt-- ;
    minD = pow(10, 10);
    if ( nCnt == 0 )return -2 ;

    //  return allNeighborIds[ int( random(0,nCnt)) ];

    int nearestId = -1 ;
    for ( int i = 0; i < nCnt ; i ++ )
    {
      nearestId = allNeighborIds[ int( random(0, nCnt)) ];
      PVector pt = pts[ allNeighborIds[nearestId] ] ;
      if ( pt.z < str.z )return nearestId ;
    } 

    return nearestId ;
  }






  // ---------------------------------------------- RANDOM POINT 3
  int randomPt3( PVector _str, int searchRing, int id )
  {
    PVector str = _str ;
    int xId, yId, zId ;
    xId = floor( (str.x - boxMin.x ) / unitX );
    yId = floor( (str.y - boxMin.y ) / unitY );
    zId = floor( (str.z - boxMin.z ) / unitZ );

    nCnt = 0; 

    for ( int u = xId -searchRing ; u <= xId + searchRing ; u++ )
    {
      for ( int v = yId -searchRing ; v <= yId + searchRing ; v++ )
      {
        for ( int n = zId -searchRing   ; n <= zId   ; n++ )
        {
          if ( u >= xRes || v >= yRes || n >= zRes ) continue ;
          if ( u < 0 || v < 0 || n < 0 )continue ;

          int totalNumPtsInBox = spaceDiv.voxelGrid[u][v][n].cnt ;
          if ( totalNumPtsInBox == 0  ) continue ;

          for (int l = 0; l < totalNumPtsInBox ; l ++)
          {  
            int n_id = spaceDiv.voxelGrid[u][v][n].agentIds[l];
            allNeighborIds[nCnt] = n_id ;
            nCnt++ ;
          }
        }
      }
    }

    nCnt-- ;
    minD = pow(10, 10);
    if ( nCnt == 0 )return -2 ;

    //  return allNeighborIds[ int( random(0,nCnt)) ];

    int nearestId = -1 ;
    for ( int i = 0; i < nCnt ; i ++ )
    {
      nearestId = allNeighborIds[ int( random(0, nCnt)) ];
      PVector pt = pts[ allNeighborIds[nearestId] ] ;
      if ( pt.z < str.z )return nearestId ;
    } 

    return nearestId ;
  }









  // ---------------------------------------------- DISPLAY

  void display( boolean voxDisp, float sw )
  {
    for ( int i =0 ; i < xRes ; i++ )
      for ( int j =0 ; j < yRes ; j++ )
        for ( int k =0 ; k < zRes ; k++ )
        {
          float w = g.strokeWeight;

          float r, g, b ;
          r = map(i, 0, xRes-1, 125, 255) ;
          g = map(j, 0, yRes-1, 125, 255) ;
          b = map(k, 0, zRes-1, 125, 255) ;         
          stroke(255, 255, 0, 255);

          if ( voxDisp )
          {
            strokeWeight(sw); 
            if ( voxelGrid[i][j][k].cnt >  0 ) voxelGrid[i][j][k].draw(sw);
            strokeWeight(sw);
          }
          //                    
          stroke(255, 255, 255, 5);
          beginShape(POINTS);
          for ( int n =0 ; n < voxelGrid[i][j][k].cnt ; n++ )
          {

            PVector pt = pts[ voxelGrid[i][j][k].agentIds[n] ] ;
            //  strokeWeight( radii[ voxelGrid[i][j][k].agentIds[n] ] );
            strokeWeight(sw);


            //vertex( pt.x , pt.y, pt.z ) ;
          }
          endShape();
        }
  }

  //----------------------A FUNCTION TO ADD AND AVERAGE ALL VECtOrS IN All VOCXELs AND MOVE TO A CENTER POINT
  //ook up all the vecotrs in a single voxel
  //5. add them all up; magnitude division by <size> of array used in addition
  void composeVec() {


    {//for each voxel
      for ( int i =0 ; i < xRes ; i++ ) {
        for ( int j =0 ; j < yRes ; j++ ) {
          for ( int k =0 ; k < zRes ; k++ ) {
            PVector tmpMin=voxelGrid[i][j][k].lookUpBMin();
            PVector tmpMax=voxelGrid[i][j][k].lookUpBMax();

            //go through all the vector statrt points make sure in bounds  
            //if so put the vector end snips into an put in a tmp array
            for (int m =0; m<compPtCnt; m++) {
              if (compFlowVecStartPts[m].x>=tmpMin.x ) {
                if (compFlowVecStartPts[m].x<=tmpMax.x) {
                  if (compFlowVecStartPts[m].y>=tmpMin.y ) {
                    if (compFlowVecStartPts[m].y<=tmpMax.y) {
                      if (compFlowVecStartPts[m].z>=tmpMin.z ) {
                        if (compFlowVecStartPts[m].z<=tmpMax.z) {
                          voxelGrid[i][j][k].allVecs.add(compFlowVecEndPts[m]);
                          voxelGrid[i][j][k].allVecsBases.add(compFlowVecStartPts[m]);
                        }
                      }
                    }
                  }
                }
              }
            }
            //5. add them all up; magnitude division by <size> of array used in addition   
            voxelGrid[i][j][k].vecEpsilon();
          }
        }
      }
    }
  }

  void composeSums() {
    for ( int i =0 ; i < xRes ; i++ ) {
      for ( int j =0 ; j < yRes ; j++ ) {
        for ( int k =0 ; k < zRes ; k++ ) {

          voxelGrid[i][j][k].vecSums();
        }
      }
    }
  }


  //  void magnify(float f){
  // //for each voxel
  //    for ( int i =0 ; i < xRes ; i++ ) {
  //      for ( int j =0 ; j < yRes ; j++ ) {
  //        for ( int k =0 ; k < zRes ; k++ ) {
  //          voxelGrid[i][j][k].setScaleVec(f);
  //          
  //        }}}
  //
  //}

  //void reset(){
  //   for ( int i =0 ; i < xRes ; i++ ) {
  //      for ( int j =0 ; j < yRes ; j++ ) {
  //        for ( int k =0 ; k < zRes ; k++ ) {
  //voxelGrid[i][j][k].scaledUnitVec=voxelGrid[i][j][k].UnitVec;
  //}}}}

  void displayCompVecField(int R, int G, int B, int A, float w) {
    //for each voxel
    for ( int i =0 ; i < xRes ; i++ ) {
      for ( int j =0 ; j < yRes ; j++ ) {
        for ( int k =0 ; k < zRes ; k++ ) {



          PVector v1= voxelGrid[i][j][k].lookUpCentroid(); 

          PVector v2= voxelGrid[i][j][k].lookUpXVec(); 

          //println(v2);
          stroke(R, G, B, A);
          strokeWeight(w);
          //strokeWeight(.125);
          //point(v2.x, v2.y, v2.z);
          line (v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);
        }
      }
    }
  }



  PVector lookUpVec(PVector l) {

    PVector p= new PVector(0, 0, 0);




    for ( int i =0 ; i < xRes ; i++ ) {
      for ( int j =0 ; j < yRes ; j++ ) {
        for ( int k =0 ; k < zRes ; k++ ) {
          PVector tmpMin=voxelGrid[i][j][k].lookUpBMin();
          PVector tmpMax=voxelGrid[i][j][k].lookUpBMax();

          //go through all the vector statrt points make sure in bounds  
          //if so put the vector end snips into an put in a tmp array

          if (l.x>=tmpMin.x ) {
            if (l.x<=tmpMax.x) {
              if (l.y>=tmpMin.y ) {
                if (l.y<=tmpMax.y) {
                  if (l.z>=tmpMin.z ) {
                    if (l.z<=tmpMax.z) {
                      p = voxelGrid[i][j][k].UnitVec;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    //boolean isNaN(p.x){return p != p;}
    if (p.x==p.x) {

      return p;
    }
    else {
      return new PVector (0, 0, 0);
    }
  }

  PVector lookUpIndex(PVector l) {

    PVector p= new PVector(0, 0, 0);

    for ( int i =0 ; i < xRes ; i++ ) {
      for ( int j =0 ; j < yRes ; j++ ) {
        for ( int k =0 ; k < zRes ; k++ ) {
          PVector tmpMin=voxelGrid[i][j][k].lookUpBMin();
          PVector tmpMax=voxelGrid[i][j][k].lookUpBMax();

          //go through all the vector statrt points make sure in bounds  
          //if so put the vector end snips into an put in a tmp array

          if (l.x>=tmpMin.x ) {
            if (l.x<=tmpMax.x) {
              if (l.y>=tmpMin.y ) {
                if (l.y<=tmpMax.y) {
                  if (l.z>=tmpMin.z ) {
                    if (l.z<=tmpMax.z) {
                      p = new PVector(i, j, k);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    //boolean isNaN(p.x){return p != p;}
    if (p.x==p.x) {

      return p;
    }
    else {
      return new PVector (0, 0, 0);
    }
  }




  //boolean lookupState(Vec3D loc){
  //PVector tmp= new PVector(loc.x,loc.y,loc.z);
  //
  //
  //
  //
  //
  //}


  //      
  //      int i = floor(l.x*unitX);
  //    int j = floor(l.y*unitY);
  //    int k =  floor(l.z*unitZ);
  //   
  //   if (i<xRes && j < yRes && k < zRes){
  //   return voxelGrid[i][j][k].UnitVec;
  //      }
  //        else{
  //      return new PVector (0,0,0);
  //      }
  //      }
  //      
  //      
  //      else{
  //      return new PVector (0,0,0);
  //      }
}



