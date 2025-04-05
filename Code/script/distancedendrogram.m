rintensities=[];
yintensities=[];
bintensities=[];
for i=1:size(channel1coords,1)
    %rintensity=getIntensity(channel1coords(i,:),channel1zstack);
    fitinfo = fits1(i,:);
    fitinfo = cell2mat(fitinfo);
    rintensity = fitinfo(1)*(2*pi)^(3/2)*fitinfo(2)*fitinfo(3)*fitinfo(4);
    rintensities=vertcat(rintensities,rintensity);
end
for i=1:size(channel2coords,1)
    %yintensity=getIntensity(channel2coords(i,:),channel2zstack);
    fitinfo = fits2(i,:);
    fitinfo = cell2mat(fitinfo);
    yintensity = fitinfo(1)*(2*pi)^(3/2)*fitinfo(2)*fitinfo(3)*fitinfo(4);
    yintensities=vertcat(yintensities,yintensity);
end
for i=1:size(channel3coords,1)
    %bintensity=getIntensity(channel3coords(i,:),channel3zstack);
    fitinfo = fits3(i,:);
    fitinfo = cell2mat(fitinfo);
    bintensity = fitinfo(1)*(2*pi)^(3/2)*fitinfo(2)*fitinfo(3)*fitinfo(4);
    bintensities=vertcat(bintensities,bintensity);
end

% coords, intensities, z gaussian data (amplitude, sigma, r^2)
rsignals=horzcat(channel1coords,rintensities,cell2mat(fits1));
ysignals=horzcat(channel2coords,yintensities,cell2mat(fits2));
bsignals=horzcat(channel3coords,bintensities,cell2mat(fits3));

%centroid location, volume
nucleisignals=horzcat(nuclei_Centroids,nuclei_Volumes);


% Define four sets of coordinates (example points for each group)
red_points = rsignals(:,1:3);
yellow_points = ysignals(:,1:3);
blue_points = bsignals(:,1:3);
if ~isempty(nucleisignals)
    nuclei_centroids = nucleisignals(:,1:3);
end

% Combine all points
all_points = [red_points; blue_points; yellow_points];
all_points(:,1:2)=all_points(:,1:2).*128.866;
all_points(:,3)=all_points(:,3).*300;

% Extract intensity values (4th column)
red_intensities = rsignals(:,4);
yellow_intensities = ysignals(:,4);
blue_intensities = bsignals(:,4);

% =============================
% Perform Hierarchical Clustering
% =============================

% Compute pairwise Euclidean distances
distance_matrix = pdist(all_points, 'euclidean');

% Perform hierarchical clustering using Ward’s method
linkage_matrix = linkage(distance_matrix, 'ward');

% Plot dendrogram
figure;
dendrogram(linkage_matrix);
title('Dendrogram of Spot Clustering (Excluding Nuclei)');
xlabel('Spot Index');
ylabel('Distance');

% =============================
% Identify Cells by Cutting Dendrogram
% =============================

% Define a cutoff distance based on expected cell size
cutoff_distance = 2000; % Adjust as needed
cell_labels = cluster(linkage_matrix, 'Cutoff', cutoff_distance, 'Criterion', 'distance');

% Number of identified cells
num_cells = numel(unique(cell_labels));
disp(['Identified ', num2str(num_cells), ' cells']);

% =============================
% Construct totalcelldata2
% =============================

% Initialize the 2D cell array
totalcelldata2 = cell(num_cells, 16); 

% Get the number of spots for each category
num_red = size(red_points,1);
num_blue = size(blue_points,1);
num_yellow = size(yellow_points,1);

% Scaling factors for real-world distances
xy_scale = 128.866; % nm per pixel in x and y
z_scale = 300;      % nm per pixel in z

% Loop through each identified cell
for i = 1:num_cells
    % Find spots belonging to the current cell
    cell_spot_indices = find(cell_labels == i);
    
    % Extract spots by color
    red_indices = cell_spot_indices(cell_spot_indices <= num_red);
    blue_indices = cell_spot_indices(cell_spot_indices > num_red & cell_spot_indices <= num_red + num_blue) - num_red;
    yellow_indices = cell_spot_indices(cell_spot_indices > num_red + num_blue) - (num_red + num_blue);

    red_spots = red_points(red_indices, :);
    blue_spots = blue_points(blue_indices, :);
    yellow_spots = yellow_points(yellow_indices, :);

    % ===========================
    % Compute Intra-Color Distances (WITH SCALING)
    % ===========================

    % Function to scale distances
    scale_distances = @(pts) squareform(pdist(pts .* [xy_scale, xy_scale, z_scale], 'euclidean'));

    if size(red_spots,1) > 1
        red_distances = scale_distances(red_spots);
        red_distances = red_distances(triu(true(size(red_distances)), 1)); % Keep only upper triangle
    else
        red_distances = [];
    end

    if size(yellow_spots,1) > 1
        yellow_distances = scale_distances(yellow_spots);
        yellow_distances = yellow_distances(triu(true(size(yellow_distances)), 1)); % Keep only upper triangle
    else
        yellow_distances = [];
    end

    if size(blue_spots,1) > 1
        blue_distances = scale_distances(blue_spots);
        blue_distances = blue_distances(triu(true(size(blue_distances)), 1)); % Keep only upper triangle
    else
        blue_distances = [];
    end

    % ===========================
    % Compute Intra-Cell Inter-Color Distances (WITH SCALING)
    % ===========================

    if ~isempty(red_spots) && ~isempty(yellow_spots)
        RY_distances = pdist2(red_spots .* [xy_scale, xy_scale, z_scale], ...
                              yellow_spots .* [xy_scale, xy_scale, z_scale], 'euclidean');
    else
        RY_distances = [];
    end

    if ~isempty(red_spots) && ~isempty(blue_spots)
        RB_distances = pdist2(red_spots .* [xy_scale, xy_scale, z_scale], ...
                              blue_spots .* [xy_scale, xy_scale, z_scale], 'euclidean');
    else
        RB_distances = [];
    end

    if ~isempty(yellow_spots) && ~isempty(blue_spots)
        YB_distances = pdist2(yellow_spots .* [xy_scale, xy_scale, z_scale], ...
                              blue_spots .* [xy_scale, xy_scale, z_scale], 'euclidean');
    else
        YB_distances = [];
    end

    % Construct the color code string (repeat letters for each spot)
    color_code = [repmat('R', 1, size(red_spots,1)), ...
                  repmat('Y', 1, size(yellow_spots,1)), ...
                  repmat('B', 1, size(blue_spots,1))];

    % Store results in totalcelldata2
    totalcelldata2{i, 1} = color_code;       % Color composition string
    totalcelldata2{i, 2} = red_spots;        % Red spot coordinates
    totalcelldata2{i, 3} = yellow_spots;     % Yellow spot coordinates
    totalcelldata2{i, 4} = blue_spots;       % Blue spot coordinates
    totalcelldata2{i, 5} = red_intensities(red_indices);  % Red spot intensities
    totalcelldata2{i, 6} = yellow_intensities(yellow_indices); % Yellow spot intensities
    totalcelldata2{i, 7} = blue_intensities(blue_indices);  % Blue spot intensities
    totalcelldata2{i,8} = rsignals(red_indices,5:end);
    totalcelldata2{i,9} = ysignals(yellow_indices,5:end);
    totalcelldata2{i,10} = bsignals(blue_indices,5:end);
    totalcelldata2{i, 11} = red_distances;    % Red-to-Red distances
    totalcelldata2{i, 12} = yellow_distances; % Yellow-to-Yellow distances
    totalcelldata2{i, 13} = blue_distances;   % Blue-to-Blue distances
    totalcelldata2{i, 14} = RY_distances;     % Red-to-Yellow distances
    totalcelldata2{i, 15} = RB_distances;     % Red-to-Blue distances
    totalcelldata2{i, 16} = YB_distances;    % Yellow-to-Blue distances
end

indices=[];
for i=1:size(totalcelldata2,1)
    avgcoord = getAverageXYZ(totalcelldata2(i,:));
    if (avgcoord(3) <= 27/6) || (avgcoord(3) >= 27*5/6)
        indices=[indices;i];
    end
end
totalcelldata2(indices,:)=[];


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
