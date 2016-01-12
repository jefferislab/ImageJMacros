//"flylight_easyopen" 
//This macro makes compositses of split channel tifs with appropriate channel colours. 
//It also makes a Z projection. Takes some of the edge off manual annotation. 

macro "flylight_easyopen [u]" {
	names= getList("image.titles");
	if (names.length==0) {
		print("no images open");
		return;
	} 
	if (names.length==1) {
		print("only 1 image open");
		return;
	}
	if (names.length>4) {
		print("too many images open");
		return;
	}
	if (names.length==2) {
	//Open the appropriate color for each channel if image is 20xTI;
		for (i=0;i<names.length;i++) {
			if(endsWith(names[i],"c0.tif" )) {
			selectWindow(names[i]);
			rename("venus");
			}
			if(endsWith(names[i],"c1.tif" )) {
			selectWindow(names[i]); 
			rename("neuropil");
			}	
		}
		run("Merge Channels...", "c2=venus c6=neuropil create");
		run("Z Project...", "projection=[Standard Deviation]");
	}
	if (names.length==3) {
	//Open the appropriate color for each channel if image is Polarity;
		for (i=0;i<names.length;i++) {
			if(endsWith(names[i],"c0.tif" )) {
			selectWindow(names[i]);
			rename("sytHA");
			}
			if(endsWith(names[i],"c1.tif" )) {
			selectWindow(names[i]); 
			rename("flag");
			}	
			if(endsWith(names[i],"c2.tif" )) {
			selectWindow(names[i]); 
			rename("neuropil");
			}	
		}
		run("Merge Channels...", "c2=flag c4=sytHA c6=neuropil create");
		run("Z Project...", "projection=[Standard Deviation]");
	}
if (names.length==4) {
	//Open the appropriate color for each channel if image is MCFO;
		for (i=0;i<names.length;i++) {
			if(endsWith(names[i],"c0.tif" )) {
			selectWindow(names[i]);
			rename("stain1");
			}
			if(endsWith(names[i],"c1.tif" )) {
			selectWindow(names[i]); 
			rename("stain2");
			}	
			if(endsWith(names[i],"c2.tif" )) {
			selectWindow(names[i]); 
			rename("stain3");
			}	
			if(endsWith(names[i],"c3.tif" )) {
			selectWindow(names[i]); 
			rename("neuropil");
			}	
		}
		run("Merge Channels...", "c2=stain1 c4=neuropil c6=stain2 c5=stain3 create");
		run("Z Project...", "projection=[Standard Deviation]");
	}
//end
}