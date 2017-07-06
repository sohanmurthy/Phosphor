//Connects to local Fadecandy server and maps P3LX points to physical pixels 

FadecandyOutput buildOutput() {
  FadecandyOutput output = null;
  int[] pointIndices = buildPoints();
  output = new FadecandyOutput(lx, "127.0.0.1", 7890, pointIndices);
  
  lx.addOutput(output);
  return output;
}


//function that maps point indices to pixels on led strip
int[] buildPoints() {
  int pointIndices[] = new int[400];
  int i = 0;
  for (int strips = 0; strips < 20; strips = strips + 1) {
    for (int pixels_per_strip = 0; pixels_per_strip < 20; pixels_per_strip = pixels_per_strip + 1) {
      if (strips % 2 == 1) { 
          pointIndices[i] = (((30-1)-pixels_per_strip)+(30*strips));
      } else {
          pointIndices[i] = (pixels_per_strip+30*strips);
      }
      i++;
    } 
  }
  return pointIndices; 
}