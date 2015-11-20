// "BatchSmoothTifToAmira"
//
// This macro batch processes all the tif files
// in a folder and any subfolders in that folder.
// It then saves them in the Amiramesh format using the Amira_Writer plugin
// The new filename will end in smooth.am

// (Slightly) Adapted by Greg Jefferis from code at
// http://rsb.info.nih.gov/ij/macros/BatchProcessFolders.txt

// jefferis@gmail.com

requires("1.33s");
dir = getDirectory("Choose a Directory ");
setBatchMode(true);
count = 0;
countFiles(dir);
n = 0;
processFiles(dir);
//print(count+" files processed");

function countFiles(dir) {
	list = getFileList(dir);
    for (i=0; i<list.length; i++) {
        if (endsWith(list[i], "/"))
            countFiles(""+dir+list[i]);
        else
            count++;
    }
}

function processFiles(dir) {
	list = getFileList(dir);
    for (i=0; i<list.length; i++) {
        if (endsWith(list[i], "/"))
            processFiles(""+dir+list[i]);
        else {
           showProgress(n++, count);
           //path = dir+list[i];
           processFile(dir,list[i]);
        }
    }
}

function processFile(dir,file) {
    if (endsWith(file, ".tif") && !endsWith(file, "-stackreg.tif")) {
        path = dir+file;
        open(path);
        newpath=replace(path,".tif","-stackreg.tif");
        run("Stack to Hyperstack...", "order=xyztc channels=1 slices=7 frames=16 display=Color");
        run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]");
        run("StackReg", "transformation=Translation");
        run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]");
        saveAs("Tiff", newpath);
        close();
	}
}
