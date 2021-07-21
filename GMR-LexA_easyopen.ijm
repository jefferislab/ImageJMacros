macro "GMR-LexA_easyopen [u]" {
		setSlice(90);
		run("In [+]");
		
		Stack.setChannel(1);
		resetMinAndMax();
		
		Stack.setChannel(2)
		resetMinAndMax();
		run("Make Composite");
		run("Rotate... ", "angle=-30 grid=1 interpolation=Bilinear");
}