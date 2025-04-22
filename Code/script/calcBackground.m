function bg_noise = calcBackground(channelimage, coord,length,length2)
    % Define search window size
    x_range = length+1; 
    y_range = length+1;
    if length2 == 0
        z_range = length+1;
    else
        z_range = length2+1;
    end
    X = coord(1);
    Y = coord(2);
    Z = coord(3);

    [Nx, Ny, Nz] = size(channelimage);  % Image dimensions

    % Define the cropping boundaries ensuring they are within the image
    x_min = max(X - x_range, 1);
    x_max = min(X + x_range, Nx);
    y_min = max(Y - y_range, 1);
    y_max = min(Y + y_range, Ny);
    z_min = max(Z - z_range, 1);
    z_max = min(Z + z_range, Nz);

    % Extract the 3D subvolume
    subvolume = channelimage(x_min:x_max, y_min:y_max, z_min:z_max);
    mask = false(size(subvolume));

    % Check which faces are touching the boundaries
    touch_x_min = (x_min == 1);
    touch_x_max = (x_max == Nx);
    touch_y_min = (y_min == 1);
    touch_y_max = (y_max == Ny);
    touch_z_min = (z_min == 1);
    touch_z_max = (z_max == Nz);

    % Apply masks only for faces that DO NOT touch boundaries
    if ~touch_x_min, mask(1, :, :) = true; end  % Left face
    if ~touch_x_max, mask(end, :, :) = true; end  % Right face

    if ~touch_y_min, mask(:, 1, :) = true; end  % Top face
    if ~touch_y_max, mask(:, end, :) = true; end  % Bottom face

    if ~touch_z_min, mask(:, :, 1) = true; end  % Front face
    if ~touch_z_max, mask(:, :, end) = true; end  % Back face

    % Extract background voxels from valid faces only
    background_voxels = subvolume(mask);
    background_voxels = double(background_voxels);

    % Compute background noise level (handle empty case)
    if isempty(background_voxels)
        bg_noise = NaN; % No valid background region
    else
        bg_noise = mean(background_voxels); % Mean of unique valid perimeter voxels
    end
end