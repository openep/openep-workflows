xmlFile1 = '/Users/steven/Dropbox/Matlab_Code/workingdir/openep-workflows/def/getVoltageMaps.xml';
xmlFile2 = '/Users/steven/Dropbox/Matlab_Code/workingdir/openep-workflows/def/loadUserdata.xml';

% create the building blocks
bb1 = OpenEpBuildingBlock(xmlFile1);
bb2 = OpenEpBuildingBlock(xmlFile2);

% chain the building blocks together
bb2.setPrevious = bb1;

% execute
bb2.execute();
