%{
Marco Rojas-Cessa
Rothstein Lab
Columbia University

procedure.m script
%}

%boundary distance from edge of view in nm to exclude points
boundarydistance = 2000;

%proportion of z view to exclude nuclei centroids outside of  (taken from
%the center)
zprop = 2/3;

%load fiji coordinates
%convert the fijichannel coords to MATLAB-oriented coords
%fijitable1 = readtable('pointsC1.csv');
%fc1 = table2array(fijitable1);
%fijichannel1 = fc1(:,2:3);

%fijichannel1 = csvread('pointsC1.csv');
fc1 = table2array(readtable('pointsC1.csv'));
fijichannel1 = fc1(:,2:3);
%fijichannel2 = csvread('pointsC2.csv');
fc2 = table2array(readtable('pointsC2.csv'));
fijichannel2 = fc2(:,2:3);
%fijichannel3 = csvread('pointsC3.csv');
fc3 = table2array(readtable('pointsC3.csv'));
fijichannel3 = fc3(:,2:3);

tempchannel1coords=convert(fijichannel1);
tempchannel2coords=convert(fijichannel2);
tempchannel3coords=convert(fijichannel3);
%{

%get rid of coords too close to the boundary
[tempchannel1coords,removed1coords]=cleanCoords(tempchannel1coords,boundarydistance);
[tempchannel2coords,removed2coords]=cleanCoords(tempchannel2coords,boundarydistance);
[tempchannel3coords,removed3coords]=cleanCoords(tempchannel3coords,boundarydistance);
%}

%load images, image z-stacks and compressed 2D channel images by maximum
%values
channel1images=loadtiff('channel1deconv.tif');
channel2images=loadtiff('channel2deconv.tif');
channel3images=loadtiff('channel3deconv.tif');
channel1zstack=loadtiff('channel1_maxProj.tif');
channel2zstack=loadtiff('channel2_maxProj.tif');
channel3zstack=loadtiff('channel3_maxProj.tif');

channel1coords = getZCoord(tempchannel1coords,channel1images);
channel2coords = getZCoord(tempchannel2coords,channel2images);
channel3coords = getZCoord(tempchannel3coords,channel3images);

%{
%for later removal of associated nuclei in nuclei segmentation protocol
removed1coords = getZCoord(removed1coords,channel1images);
removed2coords = getZCoord(removed2coords,channel2images);
removed3coords = getZCoord(removed3coords,channel3images);

removedcoords = [removed1coords;removed2coords;removed3coords];
%}

[channel1coords,fits1] = getInfo(channel1coords,channel1images);
[channel2coords,fits2] = getInfo(channel2coords,channel2images);
[channel3coords,fits3] = getInfo(channel3coords,channel3images);

%{
%Find sub-z location of each local maxima signal
[channel1coords,fits1]=getzpositions(tempchannel1coords,channel1images,zframeno);
[channel2coords,fits2]=getzpositions(tempchannel2coords,channel2images,zframeno);
[channel3coords,fits3]=getzpositions(tempchannel3coords,channel3images,zframeno);
%}

nucleisegment

distancedendrogram

%{
if isempty(totalcelldata) || isempty(totalcelldata2)
    jaccardindices=[];
    meanjaccard=0;
else
    [jaccardindices,meanjaccard] = meanJaccardIndex(totalcelldata,totalcelldata2)
end
%}


