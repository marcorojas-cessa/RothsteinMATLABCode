%{
Marco Rojas-Cessa
Rothstein Lab
Columbia University

procedure2.m script
%}

pick = input("What type of fitting? \n 1. distorted 3D Gaussian \n 2. 3D Gaussian \n 3. 2D X,Y Gaussian + 1D Z Gaussian\n> ");
if pick ~= 3
    rwidth = input("RED: How many voxels from signal local max for fitting? (Background uses voxels from 1 + this number)\n> ");
    ywidth = input("YELLOW: How many voxels from signal local max for fitting? (Background uses voxels from 1 + this number)\n> ");
    bwidth = input("BLUE: How many voxels from signal local max for fitting? (Background uses voxels from 1 + this number)\n> ");
    rwidth2=0;
    ywidth2=0;
    bwidth2= 0;
else
    rwidth = input("RED: How many pixels from signal local max for XY fitting? (Background uses pixels from 1 + this number)\n> ");
    rwidth2 = input("RED: How many z-frames from signal local max for Z fitting? (Background uses z-frames from 1 + this number)\n> ");
    ywidth = input("YELLOW: How many pixels from signal local max for XY fitting? (Background uses pixels from 1 + this number)\n> ");
    ywidth2 = input("YELLOW: How many pixels from signal local max for Z fitting (Background uses z-frames from 1 + this number)\n> ");
    bwidth = input("BLUE: How many pixels from signal local max for XY fitting? (Background uses pixels from 1 + this number)\n> ");
    bwidth2 = input("BLUE: How many pixels from signal local max for Z fitting? (Background uses z-frames from 1 + this number)\n> ");
end
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

[channel1coords,fits1] = getInfo(pixelchannel1coords,channel1images,rwidth,rwidth2,pick);
[channel2coords,fits2] = getInfo(pixelchannel2coords,channel2images,ywidth,ywidth2,pick);
[channel3coords,fits3] = getInfo(pixelchannel3coords,channel3images,bwidth,bwidth2,pick);

nucleisegment

for i = 1:size(totalcelldata, 1)        % loop over rows
    for j = 2:4                        % loop over target columns
        xyz = totalcelldata{i, j};      % get the matrix
        if ~isempty(xyz)
            xyz(:,1:2) = xyz(:,1:2) - 1;   % subtract 1 from x and y
            totalcelldata{i, j} = xyz;      % store it back
        end
    end
end

distancedendrogram

for i = 1:size(totalcelldata2, 1)        % loop over rows
    for j = 2:4                        % loop over target columns
        xyz = totalcelldata2{i, j};      % get the matrix
        if ~isempty(xyz)
            xyz(:,1:2) = xyz(:,1:2) - 1;   % subtract 1 from x and y
            totalcelldata2{i, j} = xyz;      % store it back
        end
    end
end

%write totalcelldata cell to a CSV file
columnHeadings = {'Color Code','R Locations (pixels)','Y Locations (pixels)','B Locations (pixels)','R Intensities (au)','Y Intensities (au)','B Intensities (au)','R Gaussian Data (Amplitude XY(/)Z, Sigma_x, Sigma_y, Sigma_z, and R-squared value(s) of fit(s) [XY(/)Z])','Y Gaussian Data','B Gaussian Data','RR Distances (nm)','YY Distances (nm)','BB Distances (nm)','RY Distances (nm)','RB Distances (nm)','YB Distances (nm)','Nuclei Centroid Location (pixels)','Nuclei Volume (3D pixels)'};
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
columnHeadings = {'Color Code','R Locations (pixels)','Y Locations (pixels)','B Locations (pixels)','R Intensities (au)','Y Intensities (au)','B Intensities (au)','R Gaussian Data (Amplitude XY(/)Z, Sigma_x, Sigma_y, Sigma_z, and R-squared value(s) of fit(s) [XY(/)Z])','Y Gaussian Data','B Gaussian Data','RR Distances (nm)','YY Distances (nm)','BB Distances (nm)','RY Distances (nm)','RB Distances (nm)','YB Distances (nm)'};
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