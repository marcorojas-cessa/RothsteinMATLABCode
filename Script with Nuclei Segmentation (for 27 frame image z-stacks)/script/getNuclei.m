%{
Marco Rojas-Cessa
Rothstein Lab
Columbia University

getNuclei.m function

input:
binaryMask- matrix loaded from tiff image of segmented blue channel to
threshold nuclei locations
%}

function [nuclei,labeledNuclei] = getNuclei(binaryMask)

%Label connected components
connectedComponents = bwconncomp(binaryMask);

%remove small objects
%using a diameter of 2 um, that is a volume of 4/3 * pi * 1um^3
%one 3D pixel is .128866 um * .128866 um * .300 um = 0.004982 um^3
% volume of nucleus divided by 3D pixel size = 4/3 * pi / 0.004982 ~= 841
% to get rid of noise, we can set a minimum Size threshold, say around half
% the size of a regular nucleus

%minSize = 100; % Set minimum size threshold for objects
%binaryMaskCleaned = bwareaopen(binaryMask, minSize);
binaryMaskCleaned = binaryMask;

%cpdate connected components after cleaning
connectedComponents = bwconncomp(binaryMaskCleaned);

%compute the distance transform
distanceTransform = -bwdist(~binaryMaskCleaned);

%impose minima to avoid over-segmentation
modifiedDistance = imhmin(distanceTransform, 1);

%perform the watershed transformation
watershedLabels = watershed(modifiedDistance);

%create a mask by keeping only the watershed regions that overlap with nuclei
separatedObjects = (watershedLabels > 0) & binaryMaskCleaned;

%label and analyze separated nuclei
labeledNuclei = bwlabeln(separatedObjects);

%analyze properties of labeled nuclei
nucleiProperties = regionprops3(labeledNuclei, 'Volume', 'Centroid', 'BoundingBox');

%nuclei holds first column as volume, second column as x position,
%third as y, fourth as z
nuclei=table2array(nucleiProperties);
if ~isempty(nuclei)
    nuclei=nuclei(:,1:4);
end
