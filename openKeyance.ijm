//openKeyance.ijm
//Mike Dolan

//Code to extract images from the RGB stacks from the Keyance
//This will extract the channels and save them as Tifs in the "FinalImage" directory.
//Will also create a composite in the main (raw) directory 

//Note need to have a main (raw) directory full of individual sample directories (directory named by sample). 
//Within each sample directory there are the channels 

//Note if there are existing FinalImage directories, will throw error. Remove and restart the macro

//Get Input directory 
RawDir=getDirectory("Choose the parent directory of the experiment containing sample images"); //Samples must be brain1, brain2, etc 
list=getFileList(RawDir); //Get all samples in the main directory 
close("*"); //Ensure all images are closed 

//Open each image, run RGB color and then convert to 16bit greyscale composite and save 
for (i=0; i<list.length; i++) { 
	channels=getFileList(RawDir+"/"+list[i]); //List all the channels in the directory 
	File.makeDirectory(RawDir+"/"+list[i]+"/"+"FinalImages"); //Make a directory to save the new files 
	for(j=0; j<channels.length; j++){   //Go through each channel (separate image with Keyance) 
		open(RawDir+"/"+list[i]+"/"+ channels[j]); 
		if(endsWith(getTitle(), "Overlay.tif" )) {
			close("*"); //Close this overlay file 
			continue;
		}
		run("RGB Color");
		run("16-bit");	
		saveAs("Tiff", RawDir+"/"+list[i]+"/"+"FinalImages"+"/"+getTitle());
		close("*"); //Close all images 		
	}
	open(RawDir+"/"+list[i]+"/"+"FinalImages"+"/"); //Open each channel 
	run("Make Composite", "display=Composite"); //Create a composite  
	sampleName=replace(list[i], "/", "");
	saveAs("Tiff", RawDir+"/"+sampleName+".tif"); //save this in the main "raw" directory.
	close("*"); //Close all images 		
}


	


	

