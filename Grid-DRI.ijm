//Thank-you to Alireza Dehghan for proposing the idea of automating the DRI and providing primary framework for the DRI macro.

var s_directory, s_name, s_results, s_properties, s_traverses;

s_directory = getInfo("image.directory");
s_name = getInfo("image.filename");
print(s_name);
//s_results = s_directory + replace(s_name, ".tif", "_crackcount.txt");


segments = split(s_name, ".");
segments[lengthOf(segments) - 1] = "_crackcount.txt"; // Replace the last segment

s_results = s_directory + segments[0] + '.' + segments[1]; // Rejoin with '.'

print(s_results);
getDimensions(width, height,channels, slices, frames);

counted=1;
z = 0;
z = getNumber("What is the height of your screen? (in cm): ",z);

setLocation(0, 0); 
getLocationAndSize(x, y, width, height); 

count1=0;
count2=0;
count3=0;
count4=0;
count5=0;
count6=0;
count7=0;

//DRI factors!
FC1=0.25;
FC2=2;
FC3=2;
FC4=3;
FC5=2;
FC6=3;
FC7=3;

s_report="Crack count results for " +s_name+ "\n";

// analysis area selection area dims
var i_a_x,  i_a_y,  i_a_w,  i_a_h;

i_roi_edge = 0; //initialize the variable
i_roi_edge= getNumber ("How many pixels per cm? ", i_roi_edge);


h = getHeight();
getSelectionBounds(i_a_x,  i_a_y,  i_a_w,  i_a_h); // make sure an area has been selected

if (h != i_a_h) {
	// get the area of the selection and divide by the number of samples to establish roi area
	i_selection = i_a_w * i_a_h;
	i_roi_area = i_roi_edge*i_roi_edge; 
	i_x_steps = floor(i_a_w / i_roi_edge); // the number of sample steps in a row
	i_y_steps = floor((i_a_h) / i_roi_edge); // the number of sample steps in a column

	a=screenHeight*100*16/(z*i_roi_edge); //this will set the zoom to 16cm*16cm provided you get your screen measurement right
	temp=a;
	i_samples = i_x_steps*i_y_steps;
	
	showMessage("There are " +i_samples+ " frames.");
	
	// iterate through the sample locations 
	for (var y_step = 0; y_step < i_y_steps; y_step++) {
		for (var x_step = 0; x_step < i_x_steps; x_step++) {

		
			
			x = (i_a_x + x_step * i_roi_edge); // the current x-position
			y = (i_a_y + y_step * i_roi_edge); // the current y-position
			// if this is the very first sample point
			
			if (y_step + x_step == 0) {
				Overlay.addSelection();
			}
			else {
				//move the overlay to the current position
				Overlay.moveSelection(0, x + i_roi_edge, y + i_roi_edge);
			}

					
			makeRectangle(x , y , i_roi_edge, i_roi_edge);
			run("Set... ", "zoom=" +temp+ " x center y center"); // change the zooming to reach 160x160mm grid size on your screen

			waitForUser("Pause", "Press OK to resume");

			
  Dialog.create("Damage Rating Index");

  Dialog.addMessage("What petrographic feature do you observe in this grid?")  // proposed by Sanchez, Fournier, and Josée Duchesne (2015)
  Dialog.addNumber("C1 (Crack in coarse aggregate):", 0);
  Dialog.addNumber("C2 (Opened crack in coarse aggregate):", 0);
  Dialog.addNumber("C3 (Filled crack in coarse aggregate):", 0);
  Dialog.addNumber("C4 (Debonded Coarse aggregate):", 0);
  Dialog.addNumber("C5 (Disaggregated coarse aggregate):", 0);
  Dialog.addNumber("C6 (Opened crack in paste):", 0);
  Dialog.addNumber("C7 (Filled crack in paste):", 0);
  Dialog.addCheckbox ("Check box to save image of frame ", false);
  Dialog.addMessage("Frame " +counted+ " of " +i_samples);
  Dialog.show(); 
  C1 = Dialog.getNumber();
  C2 = Dialog.getNumber();
  C3 = Dialog.getNumber();
  C4 = Dialog.getNumber();
  C5 = Dialog.getNumber();
  C6 = Dialog.getNumber();
  C7 = Dialog.getNumber();
  picture = Dialog.getCheckbox();
  if(C1!=0) count1+=C1;
  if(C2!=0) count2+=C2;
  if(C3!=0) count3+=C3;
  if(C4!=0) count4+=C4;
  if(C5!=0) count5+=C5;
  if(C6!=0) count6+=C6;
  if(C7!=0) count7+=C7;
  if (picture == true){
		run("Duplicate...", " ");
		makeRectangle(x , y , i_roi_edge, i_roi_edge);
		run("Crop");
		saveAs("Tiff", s_directory + replace(s_name, ".tif", "_square" +counted+ ".tif"));	
		close();
  }
  

counted++;
makeLine(x,y,x,y+i_roi_edge);
Roi.setStrokeColor("green");
Roi.setStrokeWidth(2);
Overlay.addSelection();
makeLine(x,y,x+i_roi_edge,y);
Roi.setStrokeColor("green");
Roi.setStrokeWidth(2);
Overlay.addSelection();
makeLine(x,y+i_roi_edge,x+i_roi_edge,y+i_roi_edge);
Roi.setStrokeColor("green");
Roi.setStrokeWidth(2);
Overlay.addSelection();
makeLine(x+i_roi_edge,y,x+i_roi_edge,y+i_roi_edge);
Roi.setStrokeColor("green");
Roi.setStrokeWidth(2);
Overlay.addSelection();


s_report += "Frame: " +(counted-1)+ " of " +i_samples+ "\n";
s_report += "X-coor: " +x+ "\n";
s_report += "Y-coor: " +y+ "\n";
s_report += "C1: " +C1+ "\n";
s_report += "C2: " +C2+ "\n";
s_report += "C3: " +C3+ "\n";
s_report += "C4: " +C4+ "\n";
s_report += "C5: " +C5+ "\n";
s_report += "C6: " +C6+ "\n";
s_report += "C7: " +C7+ "\n";

				}
	}


counted=counted-1;
showMessage("Program is done running. Measured " +counted+ " points");

s_report += "SUMMARY OF RESULTS\n";
s_report += "Total C1: " +count1+ "\n";
s_report += "Total C2: " +count2+ "\n";
s_report += "Total C3: " +count3+ "\n";
s_report += "Total C4: " +count4+ "\n";
s_report += "Total C5: " +count5+ "\n";
s_report += "Total C6: " +count6+ "\n";
s_report += "Total C7: " +count7+ "\n";
s_report += "NORMALIZED RESULTS (per 100 cm^2)\n";
s_report += "Normal C1: " +(count1*100/i_samples)+ "\n";
s_report += "Normal C2: " +(count2*100/i_samples)+ "\n";
s_report += "Normal C3: " +(count3*100/i_samples)+ "\n";
s_report += "Normal C4: " +(count4*100/i_samples)+ "\n";
s_report += "Normal C5: " +(count5*100/i_samples)+ "\n";
s_report += "Normal C6: " +(count6*100/i_samples)+ "\n";
s_report += "Normal C7: " +(count7*100/i_samples)+ "\n";
s_report += "FACTOR MULTIPLIER\n";
s_report += "Factor for C1 (CCA): " +FC1+ "\n";
s_report += "Factor for C2 (OCA): " +FC2+ "\n";
s_report += "Factor for C3 (OCAG): " +FC3+ "\n";
s_report += "Factor for C4 (CAD): " +FC4+ "\n";
s_report += "Factor for C5 (DAP): " +FC5+ "\n";
s_report += "Factor for C6 (CCP): " +FC6+ "\n";
s_report += "Factor for C7 (CCPG): " +FC7+ "\n";
s_report += "FACTORED VALUE\n";
s_report += "Total C1: " +(FC1*count1*100/i_samples)+ "\n";
s_report += "Total C2: " +(FC2*count2*100/i_samples)+ "\n";
s_report += "Total C3: " +(FC3*count3*100/i_samples)+ "\n";
s_report += "Total C4: " +(FC4*count4*100/i_samples)+ "\n";
s_report += "Total C5: " +(FC5*count5*100/i_samples)+ "\n";
s_report += "Total C6: " +(FC6*count6*100/i_samples)+ "\n";
s_report += "Total C7: " +(FC7*count7*100/i_samples)+ "\n";
s_report += "FINAL RESULT: " + (FC1*count1*100/i_samples+FC2*count2*100/i_samples+FC3*count3*100/i_samples+FC4*count4*100/i_samples+FC5*count5*100/i_samples+FC6*count6*100/i_samples+FC7*count7*100/i_samples) + "\n";

f = File.open(s_results);
print(f, s_report);
File.close(f);

}

else if (h == i_a_h) {beep();showMessage("Please select a rectangular area and re-run the macro");}