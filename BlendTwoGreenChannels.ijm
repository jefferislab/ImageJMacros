// Macro which takes two image channels acquired with different gains 
// and blends them together with a changing ratio between the first 
// and second channels as you move through each Z slice.

// THE PROBLEM: you have a brain with bright green stuff at the front
// and dim green stuff at the back.  So you decided to take an image 
// with two green channels, one with high gain and one with low gain.
// The low gain channel will look good for the bright stuff at the front
// of the brain. The high gain channel will look better for the weak
// stuff at the back of the brain. Now you need to blend them. How?
// This is how ...

// Created by Greg and Philip on 11 August 2011

// When running interactively, expects an open image stack with at least 2 channels
// In batch mode, expects the path to an lsm file and an exponent (e.g. in range 1-5)

// 
// run("Close");

arg = getArgument;
if(arg=="") {
	// get images and exponent interactively
	Dialog.create("Blend Channels");
	Dialog.addChoice("Low Gain Image:", newArray("Low"));
	Dialog.addChoice("High Gain Image:", newArray("High"));
	Dialog.addNumber("exponent (1=linear, 3-5 may be good)", 1);
	Dialog.show();
	imglo = Dialog.getChoice();
	imghi = Dialog.getChoice();
	exponent = Dialog.getNumber();
} else {
	args = split(getArgument,",");
	if (args.length!=2) {
		print("Give me 2 arguments please!")
		exit();
	}
	imageFile=args[0];
	exponent=parseFloat(args[1]);  // nb turn from string to numeric
	print("Blending first two channels of image: "+imageFile+" with exponent "+exponent);
	
	// Open the image, split in and make sure we have exactly 2 channels (the first 2) left
	imagesAlreadyOpen=nImages;
	run("Bio-Formats Importer", "open=["+imageFile+"] color_mode=Default split_channels view=[Standard ImageJ] stack_order=Default");
	noImages=nImages-imagesAlreadyOpen;
	print("Finished opening image");

	for(i=noImages;i>2;i--){
		close();
	}
	// 2nd channel should be high gain
	ch2id=getImageID();
	imghi=getTitle();
	print("ch2id="+ch2id);
	print("imghi="+imghi);
	// 
	ch1id=ch2id+1;
	selectImage(ch1id);
	imglo=getTitle();
	print("ch1id="+ch1id);
	print("imglo="+imglo);
}


// how many slices are there?
// convert stack to float?

// select high gain image (imghi)
selectWindow(imghi);
zmax=nSlices-1;
// make a blending function for high gain
//   ... and run that
// something like (z^a/zmax^a)*v where:
//   z is z slice
//   v is pixel value
//   a=exponent
// v=v*(z^a/zmax^a)"
print("Transforming high gain channel");
mathstring="code=v=v*pow(z/"+zmax+","+exponent+") stack";
run("Macro...", mathstring);

// select low gain image (imglo)
selectWindow(imglo);

// make a blending function for low gain
//   ... and run that
mathstring="code=v=v-v*pow(z/"+zmax+","+exponent+") stack";
print("Transforming low gain channel");
run("Macro...", mathstring);

// Add two channels and put output somewhere
// ... (Image Calculator)
print("Blending channels");
imageCalculator("Add create stack", imghi,imglo);
