class Agent {


	Vec3D acc;
	Vec3D vel;
	Vec3D loc;
	float maxSpeed = 1.25f;  //1.0f;
	float maxForce = 1.25f;  // 1.0f;
	float r = 0;
	float g = 255;
	float b = 255;
	float a = 50;
	ArrayList<Vec3D> trail;
	int trailSize = 30;  //30 //12;  //30
	int trailFreq = 2;  //2
	boolean outside = false;
float angle = 0;

	Agent(Vec3D _loc, Vec3D _vel) {
		//p5 = _p5;
		loc = _loc;
		vel = _vel;
		acc = new Vec3D(0, 0, 0);
		trail = new ArrayList<Vec3D>();
	}

	public void run() {

		outside = outsideOfTheRiver(spaceDiv);

		if (outside)
			deathAndRebirth();

		followField(spaceDiv, 0.4f);
		update();
		//bordersFlowField(flowerfield, true);
		render();

	}

	public void applyForce(Vec3D force) {
		// To add mass to the equation Acc = Force / Mass
		acc.addSelf(force);
	}

	void followField(voxGrid spaceDiv , float flowFieldStrength) {
                PVector tt=new PVector (loc.x, loc.y, loc.z);
  
                PVector tmp=spaceDiv.lookUpVec(tt);
		Vec3D desired = new Vec3D(tmp.x, tmp.y,tmp.z);

		desired.scaleSelf(flowFieldStrength * maxSpeed);

		desired.limit(maxForce);

		applyForce(desired);
	}

	public void update() {
		vel.addSelf(acc);
		vel.limit(maxSpeed);
		loc.addSelf(vel);
		acc.clear();
	}

	public void render() {
		drawTrail(10);

	}

	public void dropTrail(int every, int limit) {
		if (trail.size() < limit) {
			if (frameCount % every == 0) {
				trail.add(loc.copy());
			}
		}

		if (trail.size() == limit) {
			trail.remove(trail.get(0));
		}
	}

	public void drawTrail(float thresh) {

		dropTrail(trailFreq, trailSize);

		if (trail.size() > 1) {
			for (int i = 1; i < trail.size(); i++) {
				Vec3D v1 = (Vec3D) trail.get(i);
				Vec3D v2 = (Vec3D) trail.get(i - 1);

//                                PVector v11 = new PVector(v1.x, v1.y,v1.z);
//                                PVector v22 = new PVector(v2.x, v2.y,v2.z); 
//                                float a = PVector.angleBetween(v11, v22);
//                                float aa= round(degrees(a));
//                                float e=map(aa,-180,180,0,255);
                                PVector velP = new PVector (vel.x, vel.y, vel.z);
                             float vm=velP.mag();
                             
                                   PVector accP = new PVector (acc.x, acc.y, acc.z);
                             float am=accP.mag();
                             
                             PVector v22= new PVector(v2.x,v2.y,v2.z);
                        PVector v11= new PVector(v1.x,v1.y,v1.z);



				float colorR = r / (trail.size()) * i;
				float colorG = g-(200*vm)/ (trail.size()) * i;
				float colorB = b/ (trail.size()) * i;
				float colorA = a / trail.size() * i;

				float d = v1.distanceTo(v2);
				if (d < thresh) {

                                float angl = degrees(PVector.angleBetween( v11, v22));
                                float ang = angl % 180;
                                float an = map(ang, 0,180, 0, 50);
                                
					strokeWeight(ang);  //.75f+

					stroke(colorR, colorG, colorB, colorA+(ang*2));
if(ang>.4 && ang <80 ){
					line(v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);

				}    }
			}
		}
	}

//	void bordersFlowField(ImporterJa flowfieldcorners, boolean bounce) {
//
//		if (bounce) {
//
//			if (loc.x < flowfieldcorners.corner1.x)
//				vel.x = vel.x*-1;
//			if (loc.y < flowfieldcorners.corner1.y)
//				vel.y = vel.y*-1;
//			if (loc.x > flowfieldcorners.corner2.x)
//				vel.x = vel.x*-1;
//			if (loc.y > flowfieldcorners.corner2.y)
//				vel.y = vel.y*-1;
//			if (loc.z < flowfieldcorners.corner1.z)
//				vel.z = vel.z*-1;
//			if (loc.z > flowfieldcorners.corner2.z)
//				vel.z = vel.z*-1;
//		}
//
//		else {
//
//			if (loc.x < flowfieldcorners.corner1.x
//					|| loc.y < flowfieldcorners.corner1.y
//					|| loc.x > flowfieldcorners.corner2.x
//					|| loc.y > flowfieldcorners.corner2.y
//					|| loc.z < flowfieldcorners.corner1.z
//					|| loc.z > flowfieldcorners.corner2.z) {
//
//				deathAndRebirth();
//			}
//		}
//	}

	boolean outsideOfTheRiver(voxGrid spaceDiv) {
boolean check = false;

  PVector t= new PVector(loc.x,loc.y,loc.z);
  PVector tmp=spaceDiv.lookUpIndex(t);
  int i = int(tmp.x);
  int j = int(tmp.y);
  int k = int(tmp.z);

if ( spaceDiv.voxelGrid[i][j][k].cnt >  0   ){  //&&  spaceDiv.voxelGrid[i][j][k].UnitVec.x> 0
  
  	check = false;
}
else{
			check = true;}

		return check;

	}

	void deathAndRebirth() {

		agents.remove(this);

     
int rndm = int( floor(random(0, actingVoxels.size())));

      PVector tmp=(PVector) actingVoxels.get(rndm);
     // PVector cen=spaceDiv.voxelGrid[int(tmp.x)][int(tmp.y)][int(tmp.z)].lookUpCentroid();
        PVector mi=spaceDiv.voxelGrid[int(tmp.x)][int(tmp.y)][int(tmp.z)].lookUpBMin();
      PVector ma=spaceDiv.voxelGrid[int(tmp.x)][int(tmp.y)][int(tmp.z)].lookUpBMax();
      
      float mX=random(mi.x, ma.x);
      float mY=random(mi.y, ma.y);
      float mZ=random(mi.z, ma.z);
  

      Vec3D iniPos = new Vec3D (mX,mY,mZ);

      //Vec3D iniPos = new Vec3D (cen.x, cen.y, cen.z);

      Vec3D iniVel = new Vec3D(0,0,0);


            
    

          Agent a = new Agent( iniPos, iniVel);

          agents.add(a);

	}
}
