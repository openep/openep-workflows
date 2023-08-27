% OpenEP WorkFlow File v1.0.0

% META-DATA
% Title: Divide userdata
% Description: Divide userdata into two sections
% Target: openep-examples
% Author: Steven Williams
% Date: 25/11/2021
% License: CC BY 4.0

% DEPENDENCIES
% https://github.com/openep/openep-core/tree/feature/hole_cutting
% https://github.com/openep/openep-examples
% https://uk.mathworks.com/matlabcentral/fileexchange/27991-tight_subplot-nh-nw-gap-marg_h-marg_w

% PARAMETERS
egmSamplingDensity = 0.5;
voltageScale = [0 5];

% WORKFLOW

% load data and downsample
load openep_dataset_1.mat
userdata = downSampleDataset(userdata, egmSamplingDensity);

% use cut mesh to select a region of the mesh
newUserdata = cutMesh(userdata);

% create a figure
figure
[ha, pos] = tight_subplot(2,2,[.01 .03],[.1 .01],[.01 .01]) ;

% plot the subdivided shells
axes(ha(1)); drawMap(newUserdata{1}, 'type', 'bip', 'coloraxis', voltageScale)
axes(ha(2)); drawMap(newUserdata{2}, 'type', 'bip', 'coloraxis', voltageScale)

% plot the subdivided electrogram recording locations
axes(ha(3)); 
hSurf(1) = drawMap(newUserdata{1}, 'type', 'none');
hold on;
plotTag(newUserdata{1},'pointnum',1:getNumPts(newUserdata{1}))
axes(ha(4)); 
hSurf(2) = drawMap(newUserdata{2}, 'type', 'none');
hold on;
plotTag(newUserdata{2},'pointnum',1:getNumPts(newUserdata{2}))
set(hSurf, 'facealpha', 0.5)

% link axes
Link = linkprop(ha,{'CameraUpVector', 'CameraPosition', 'CameraTarget', 'XLim', 'YLim', 'ZLim'});
setappdata(gcf, 'StoreTheLink', Link);