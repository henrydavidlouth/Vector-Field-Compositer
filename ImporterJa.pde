class ImporterJa {

	String fileToImport;
	//fVector[][][] field;
	int cols, rows, levels;
	Vec3D corner1;
	Vec3D corner2;
	float scaleFactor = 4;

	ImporterJa() {
		//p5 = _p5;
		//fileToImport = _fileToImport;
		//importData();
                corner1 = new Vec3D (fMin.x, fMin.y, fMin.z);   //field[0][0][levels-1].loc;
		corner2 = new Vec3D (fMax.x, fMax.y, fMax.z);  //field[cols-1][rows-1][0].loc;

	}

	void display() {

		for (int i = 0; i < cols; i++) {
			for (int j = 0; j < rows; j++) {
				for (int k = 0; k < levels; k++) {
                                        
                                         PVector tmpc=spaceDiv.voxelGrid[i][j][k].lookUpCentroid();
                                        PVector tmpb=spaceDiv.voxelGrid[i][j][k].lookUpXVec();
                                     
					Vec3D a = new Vec3D(tmpc.x, tmpc.y, tmpc.z);
					Vec3D b = new Vec3D(tmpb.x, tmpb.y, tmpb.z);

					strokeWeight(.7f);
//					if (field[i][j][k].state == 1){
						stroke(255, 0, 0,50);
					line(a.x, a.y, a.z, b.x, b.y, b.z);
//					}

				}
			}
		}
		
		stroke(255,255,0);
		strokeWeight(5);
		point(corner1.x,corner1.y,corner1.z);
		point(corner2.x,corner2.y,corner2.z);
	}

//	void importData() {
//
////		String[] data = loadStrings(fileToImport);
////		String conc = new String();
////
////		for (int i = 0; i < data.length; i++) {
////			conc = conc + data[i];
////		}
////
////		String[] temp = PApplet.split(conc, ";");
////
////		String[] matrix = PApplet.split(temp[temp.length - 2], ",");
////
////		cols = Integer.valueOf(matrix[6]).intValue()+1;
////		rows = Integer.valueOf(matrix[7]).intValue()+1;
////		levels = Integer.valueOf(matrix[8]).intValue()+1;
//
//		//field = new fVector[(int) xRes][(int) yRes][(int) zRes];
//
//		//PApplet.println(cols);
//		//PApplet.println(rows);
//		//PApplet.println(levels);
//
////		for (int i = 0; i < temp.length - 1; i++) { // Loop through the Array
////			String[] temp2 = PApplet.split(temp[i], ",");
////
////			if (temp2.length > 1) {
////
////				float xPos = Float.valueOf(temp2[0]).floatValue()*scaleFactor;
////				float yPos = Float.valueOf(temp2[1]).floatValue()*scaleFactor;
////				float zPos = Float.valueOf(temp2[2]).floatValue()*scaleFactor;
////
////				float xVec = Float.valueOf(temp2[3]).floatValue();
////				float yVec = Float.valueOf(temp2[4]).floatValue();
////				float zVec = Float.valueOf(temp2[5]).floatValue();
////
////				int iIndex = Integer.valueOf(temp2[6]).intValue();
////				int jIndex = Integer.valueOf(temp2[7]).intValue();
////				int kIndex = Integer.valueOf(temp2[8]).intValue();
////
////				int state = Integer.valueOf(temp2[9]).intValue();
//
//for ( int i =0 ; i < xRes ; i++ ) {
//        for ( int j =0 ; j < yRes ; j++ ) {
//          for ( int k =0 ; k < zRes ; k++ ) {
//   PVector b = spaceDiv.voxelGrid[i][j][k].compVectorBase;
//         PVector c = spaceDiv.voxelGrid[i][j][k].compVector;
//                  
// 
//
//				Vec3D loc = new Vec3D(b.x, b.y, b.z);
//				Vec3D vec = new Vec3D(c.x, c.y, c.z);
//
//				int[] index = new int[3];
//				index[0] = i;
//				index[1] = j;
//				index[2] = k;
//
//				fVector vector = new fVector( loc, vec, index, 0);
//
//				field[i][j][k] = vector;
//          }}}
//
//			}
		

	

//	fVector lookup(Vec3D lookup) {
//
//		float XDim = ((corner2.x - corner1.x));
//		float colsRes = XDim / cols;
//
//		float YDim = ((corner2.y - corner1.y));
//		float rowsRes = YDim / rows;
//
//		float ZDim = ((corner2.z - corner1.z));
//		float levelsRes = ZDim / levels;
//	
//
//		int column = (int) PApplet.constrain(lookup.x / colsRes, 0, cols - 1);
//		int row = (int) PApplet.constrain(lookup.y / rowsRes, 0, rows - 1);
//		int level = (int) PApplet.constrain(lookup.z / levelsRes, 0, levels - 1);
//	
//		
//		Vec3D a = field[column][row][level].loc;
//		Vec3D b = field[column][row][level].loc.add(field[column][row][level].vec);
//		
////		strokeWeight(3);
////		stroke(255,255,0);
////		
////		line(a.x, a.y, a.z, b.x,b.y,b.z);
//
//		return field[column][row][level];
//	}

}

