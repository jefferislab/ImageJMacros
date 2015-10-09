// "BatchConvertAnyToNrrd"
//
// This macro batch all of the files in a folder hierarchy
//   to nrrd format

// Adapted by Greg Jefferis from code at
// http://rsb.info.nih.gov/ij/macros/BatchProcessFolders.txt

// jefferis@gmail.com

// This version will check to see if the image dimensions match the standar Janelia templates
// JFRC2010 1024 512 218 0.62088 x 0.62088 x 0.62088 microns
// JFRC2013 63x 1450 725 436 0.38 x 0.38 x 0.38
// JFRC2013 20x 1184 592 218 0.46 x 0.46 x 0.46

/* Run from the command line as follows
fiji -eval '
runMacro("/Volumes/JData/JPeople/Common/CommonCode/ImageJMacros/BatchConvertAnyToNrrdAddingJaneliaCalibration.ijm",
"/Volumes/JData/JPeople/Sebastian/fruitless/Registration/IS2Reg/images.unsorted/,/Volumes/JData/JPeople/Sebastian/fruitless/Registration/IS2Reg/images.unflipped/SAJ/");
' -batch --headless
*/

requires("1.42k"); 
file = getArgument;
dir=""
outputDir=""

//print("file = "+file);
if (file!=""){
	arg = split(file,",");
		if (arg.length!=2) {
		exit();
	} else if(arg[0]=="" || arg[1]==""){
		exit();
	} else {
		outputDir=arg[1];
		if(!endsWith(outputDir,"/")) outputDir=outputDir+"/";

		if(File.isDirectory(arg[0])) {
			// we're dealing with a directory
			dir=arg[0];
			if(!endsWith(dir,"/")) dir=dir+"/";
		} else {
			// single file
			dir=File.getParent(arg[0])+"/";
			file=File.getName(arg[0]);
			processFile(dir,outputDir,file);
			exit();
		}
	}
}

if(dir=="") dir = getDirectory("stacks directory");
if(outputDir=="") outputDir = getDirectory("output directory");

setBatchMode(true);
count = 0;
countFiles(dir);
print("Total files: "+count);
n = 0;
processFiles(dir, outputDir);

function countFiles(dir) {
	list = getFileList(dir);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], "/"))
            countFiles(""+dir+list[i]);
	else
		count++;
	}
}

function processFiles(dir,outputDir) {
	list = getFileList(dir);
	// Stops multiple processes racing each other to do the same file
	shuffle(list);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], "/"))
			processFiles(""+dir+list[i], outputDir+list[i]);
		else {
			showProgress(n++, count);
			processFile(dir,outputDir,list[i]);
		}
	}
}

function processFile(dir,outputDir,file) {
	lfile=toLowerCase(file);
	if (!endsWith(lfile, ".nrrd")) {
		path = dir+file;
		outfile=substring(file,0,lastIndexOf(file,"."))+'.nrrd';
		outpath=outputDir+outfile;
		lockpath=outputDir+outfile+'.lock';
		if(File.exists(outpath)){
			print("Skipping file: " + file + " since " + outfile + " already exists");
			return;
		}
		if(File.exists(lockpath)){
			print("Skipping file: " + file + " since someone else is working on it");
			return;
		}
		// check that final output dir exists
		lockdir=File.getParent(lockpath);
		if(!File.exists(lockdir)) {
			print("making output dir:"+lockdir);
			recursive_makedir(lockdir);
		}
		
		File.saveString("",lockpath)
		print("Inpath = "+path);
		print("Outpath = "+outpath);
		print("lockpath = "+lockpath);
		open(path);
		processImage();
		// to save in compressed format
		setKeyDown("alt");
		run("Nrrd ... ", "nrrd=[" + outpath + "]");
		setKeyDown("none");
		close();
		File.delete(lockpath);
	}
}

function recursive_makedir(d) {
	exec("mkdir", "-p", d);
}

function identify_template() {
  width = getWidth;
  height = getHeight;
  depth = nSlices;

  if(width==1024 && height==512 && depth==218) return "JFRC2";
  else if(width==1450 && height==725 && depth==436) return "JFRC2013";
  else if(width==1184 && height==592 && depth==218) return "JFRC201320x";
  
  return "unknown";
}

function clear_bad_voxel_size(max) {
	getVoxelSize(width, height, depth, unit); 
	if(width>max || height>max) setVoxelSize(1.0, 1.0, 1.0, "pixels");
}

function set_voxel_size() {
  template = identify_template();

  if(template == "JFRC2") setVoxelSize(0.62088, 0.62088 , 0.62088 , "microns");
  else if(template == "JFRC2013") setVoxelSize(0.38, 0.38 , 0.38 , "microns");
  else if(template == "JFRC201320x") setVoxelSize(0.46, 0.46 , 0.46 , "microns");
  else clear_bad_voxel_size(2.0);
}

function processImage() {
	// You can make any changes to the image that you want in here
	// eg flip, reverse etc
	print("Template is "+identify_template());
    set_voxel_size();
}

function shuffle(array) {
   n = array.length;  // The number of items left to shuffle (loop invariant).
   while (n > 1) {
      k = randomInt(n);     // 0 <= k < n.
      n--;                  // n is now the last pertinent index;
      temp = array[n];  // swap array[n] with array[k] (does nothing if k==n).
      array[n] = array[k];
      array[k] = temp;
   }
}

// returns a random number, 0 <= k < n
function randomInt(n) {
   return n * random();
}
