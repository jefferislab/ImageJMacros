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

// Choose the image stack to work with
// Choose the high and low gain channels
// Choose the blending parameter

// run("Bio-Formats Importer", "open=[/Volumes/JData/JPeople/Philip/ConfocalImages/SF131 emission filter.lsm] color_mode=Default display_metadata display_ome-xml split_channels view=[Standard ImageJ] stack_order=Default");
// run("Close");

Dialog.create("Blend Channels");
Dialog.addChoice("Low Gain Image:", newArray("Low"));
Dialog.addChoice("High Gain Image:", newArray("High"));
Dialog.addNumber("exponent (1=linear, 3-5 may be good)", 1);
Dialog.show();
imglo = Dialog.getChoice();
imghi = Dialog.getChoice();
exponent = Dialog.getNumber();

// how many slices are there?
// convert stack to float?

// select high gain image (imghi)
selectWindow(imghi)
zmax=nSlices-1
// make a blending function for high gain
//   ... and run that
// something like (z^a/zmax^a)*v where:
//   z is z slice
//   v is pixel value
//   a=exponent
// v=v*(z^a/zmax^a)"
mathstring="code=v=v*pow(z/"+zmax+","+exponent+") stack"
run("Macro...", mathstring);

// select low gain image (imglo)
selectWindow(imglo)

// make a blending function for low gain
//   ... and run that
mathstring="code=v=v*(1 - pow(z/"+zmax+","+exponent+") ) stack"
mathstring="code=v=v-v*pow(z/"+zmax+","+exponent+") stack"
run("Macro...", mathstring);

// Add two channels and put output somewhere
// ... (Image Calculator)
imageCalculator("Add create stack", imghi,imglo);
