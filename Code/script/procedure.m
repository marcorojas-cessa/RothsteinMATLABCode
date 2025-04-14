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

pixelchannel1coords = getZCoord(tempchannel1coords,channel1images);
pixelchannel2coords = getZCoord(tempchannel2coords,channel2images);
pixelchannel3coords = getZCoord(tempchannel3coords,channel3images);

%{
%for later removal of associated nuclei in nuclei segmentation protocol
removed1coords = getZCoord(removed1coords,channel1images);
removed2coords = getZCoord(removed2coords,channel2images);
removed3coords = getZCoord(removed3coords,channel3images);

removedcoords = [removed1coords;removed2coords;removed3coords];
%}

[channel1coords,fits1] = getInfo(pixelchannel1coords,channel1images,3);
[channel2coords,fits2] = getInfo(pixelchannel2coords,channel2images,2);
[channel3coords,fits3] = getInfo(pixelchannel3coords,channel3images,2);

%{
%Find sub-z location of each local maxima signal
[channel1coords,fits1]=getzpositions(tempchannel1coords,channel1images,zframeno);
[channel2coords,fits2]=getzpositions(tempchannel2coords,channel2images,zframeno);
[channel3coords,fits3]=getzpositions(tempchannel3coords,channel3images,zframeno);
%}

nucleisegment

distancedendrogram

%write totalcelldata cell to a CSV file
columnHeadings = {'Color Code','R Locations (pixels)','Y Locations (pixels)','B Locations (pixels)','R Intensities (au)','Y Intensities (au)','B Intensities (au)','R 3D Gaussian Data (Amplitude, Sigma_x, Sigma_y, Sigma_z, and R-squared value of fit)','Y 3D Gaussian Data','B 3D Gaussian Data','RR Distances (nm)','YY Distances (nm)','BB Distances (nm)','RY Distances (nm)','RB Distances (nm)','YB Distances (nm)','Nuclei Centroid Location (pixels)','Nuclei Volume (3D pixels)'};
[nRows,nCols] = size(totalcelldata);
outputCell = cell(nRows + 1, nCols);
if ~isempty(outputCell)
    outputCell(1,:) = columnHeadings;
end

for row = 1:nRows
    for col = 1:nCols
        % Convert each entry to a string representation
        if isempty(totalcelldata{row, col})
            outputCell{row + 1, col} = ''; % Keep empty
        elseif ischar(totalcelldata{row, col})
            outputCell{row + 1, col} = totalcelldata{row, col}; % Keep string
        else
            % Convert numerical arrays or single values to strings
            if ismatrix(totalcelldata{row, col}) && ~isscalar(totalcelldata{row, col})
                % Convert row-wise by transposing first
                outputCell{row + 1, col} = strjoin(string(totalcelldata{row, col}.'), ', ');
            else
                outputCell{row + 1, col} = strjoin(string(totalcelldata{row, col}), ', ');
            end
        end
    end
end

writecell(outputCell, 'totalcelldata.csv');

%write totalcelldata2 cell to a CSV file
columnHeadings = {'Color Code','R Locations (pixels)','Y Locations (pixels)','B Locations (pixels)','R Intensities (au)','Y Intensities (au)','B Intensities (au)','R 3D Gaussian Data (Amplitude, Sigma_x, Sigma_y, Sigma_z, and R-squared value of fit)','Y 3D Gaussian Data','B 3D Gaussian Data','RR Distances (nm)','YY Distances (nm)','BB Distances (nm)','RY Distances (nm)','RB Distances (nm)','YB Distances (nm)'};
[nRows,nCols] = size(totalcelldata2);
outputCell = cell(nRows + 1, nCols);
outputCell(1,:) = columnHeadings;

for row = 1:nRows
    for col = 1:nCols
        % Convert each entry to a string representation
        if isempty(totalcelldata2{row, col})
            outputCell{row + 1, col} = ''; % Keep empty
        elseif ischar(totalcelldata2{row, col})
            outputCell{row + 1, col} = totalcelldata2{row, col}; % Keep string
        else
            % Convert numerical arrays or single values to strings
            if ismatrix(totalcelldata2{row, col}) && ~isscalar(totalcelldata2{row, col})
                % Convert row-wise by transposing first
                outputCell{row + 1, col} = strjoin(string(totalcelldata2{row, col}.'), ', ');
            else
                outputCell{row + 1, col} = strjoin(string(totalcelldata2{row, col}), ', ');
            end
        end
    end
end

writecell(outputCell, 'totalcelldata2.csv');



