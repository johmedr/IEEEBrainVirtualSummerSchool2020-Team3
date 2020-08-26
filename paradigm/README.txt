To run the paradigm:
1. Copy and paste your openvibe folder from Programs(x86) to your Desktop
2. Go to Desktop\openvibe\share\openvibe\applications\ssvep-demo and replece the trainer file with the one of this folder
3. Move the xlm files on the ssvep folder on your Desktop
4. Run the openvibe-designer from the openvibe's Desktop folder 
5. Open the xlm files 
6. Click on the "GDF file writer" and add the path to your output directory
7. Run the openvibe-acquisition-server
8. Run the calibration file
9. Run the training file

To open the GDF-files:
1. Unzip biosig-master.zip
2. In the folder “biosig-master”, put the other scripts and functions 
3. Use the following lines:
        addpath('./biosig/');
        install();

        [signal,H] = sload('GDF-filename',[])
