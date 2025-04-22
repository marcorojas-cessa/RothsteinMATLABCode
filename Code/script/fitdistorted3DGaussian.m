function [refinedcoords, fitinfo] = fit3DGaussian(intensityMatrix, guesscoords, channelimage, coords,length)
% Get the size of the matrix
[Nx, Ny, Nz] = size(intensityMatrix);

% Corrected background calculation
background = calcBackground(channelimage, coords,length,0);

% Subtract background
intensityMatrix = intensityMatrix - background;

% Generate coordinate grids
[X, Y, Z] = meshgrid(1:Nx, 1:Ny, 1:Nz);

% Convert data to vectors for fitting
xData = [X(:), Y(:), Z(:)];
yData = intensityMatrix(:);

% Initial guess: find approximate center and spread
[~, maxIdx] = max(yData);
[xPeak, yPeak, zPeak] = ind2sub(size(intensityMatrix), maxIdx);

A0 = max(yData);
sigmaX0 = Nx / 4; sigmaY0 = Ny / 4; sigmaZ0 = Nz / 4;

% Initial parameter vector: A, x0, sx, y0, sy, z0, sz, rho_xy, rho_xz, rho_yz
initParams = [A0, xPeak, sigmaX0, yPeak, sigmaY0, zPeak, sigmaZ0, 0.0, 0.0, 0.0];

% Define bounds
lowerBounds = [0, 0, 0.00001, 0, 0.00001, 0, 0.00001, -0.9999, -0.9999, -0.9999];
upperBounds = [Inf, Inf, Inf, Inf, Inf, Inf, Inf, 0.9999, 0.9999, 0.9999];

% Distorted 3D Gaussian function with cross-terms
gauss3D = @(params, xyz) ...
    params(1) * exp(-1 / (2 * (1 - params(8)^2 - params(9)^2 - params(10)^2 + ...
    2 * params(8) * params(9) * params(10))) * ( ...
    ((xyz(:,1) - params(2)).^2) / (params(3)^2) + ...
    ((xyz(:,2) - params(4)).^2) / (params(5)^2) + ...
    ((xyz(:,3) - params(6)).^2) / (params(7)^2) - ...
    2 * params(8) * (xyz(:,1) - params(2)) .* (xyz(:,2) - params(4)) / (params(3) * params(5)) - ...
    2 * params(9) * (xyz(:,1) - params(2)) .* (xyz(:,3) - params(6)) / (params(3) * params(7)) - ...
    2 * params(10) * (xyz(:,2) - params(4)) .* (xyz(:,3) - params(6)) / (params(5) * params(7)) ));

% Fit the model
Bestoptions = optimoptions('lsqcurvefit', ...
    'MaxIterations', 2000, 'MaxFunctionEvaluations', 3500, ...
    'FunctionTolerance', 1e-10, 'OptimalityTolerance', 1e-10);

fittedParams = lsqcurvefit(gauss3D, initParams, xData, yData, lowerBounds, upperBounds, [], [], [], [], [], Bestoptions);

% Extract results
A_fit = fittedParams(1);
mu_x = fittedParams(2);
sigma_x = fittedParams(3);
mu_y = fittedParams(4);
sigma_y = fittedParams(5);
mu_z = fittedParams(6);
sigma_z = fittedParams(7);
rho_xy = fittedParams(8);
rho_xz = fittedParams(9);
rho_yz = fittedParams(10);

% Compute predicted values from the fitted model
yPredicted = gauss3D(fittedParams, xData);

% Compute R-squared
SS_res = sum((yData - yPredicted).^2);
SS_tot = sum((yData - mean(yData)).^2);
R_squared = 1 - (SS_res / SS_tot);

% Compute refined coordinates
origx = guesscoords(1);
origy = guesscoords(2);
origz = guesscoords(3);
refinedcoords = [mu_x - origx, mu_y - origy, mu_z - origz];
fitinfo = {A_fit, sigma_x, sigma_y, sigma_z, R_squared};
%{
% Visualization
figure;
slice(X, Y, Z, intensityMatrix, round(mu_x), round(mu_y), round(mu_z));
colormap jet; shading interp;
title('Fitted Distorted 3D Gaussian PSF');
xlabel('X'); ylabel('Y'); zlabel('Z');
hold on;
scatter3(mu_x, mu_y, mu_z, 100, 'w', 'filled');

% High-res grid for visualizing the Gaussian fit
[xFit, yFit, zFit] = meshgrid(1:0.5:Nx, 1:0.5:Ny, 1:0.5:Nz);
xVec = [xFit(:), yFit(:), zFit(:)];
gaussVals = gauss3D(fittedParams, xVec);
gaussVol = reshape(gaussVals, size(xFit));

isosurfaceLevel = 0.5 * A_fit;
h = patch(isosurface(xFit, yFit, zFit, gaussVol, isosurfaceLevel));
isonormals(xFit, yFit, zFit, gaussVol, h);
set(h, 'FaceColor', 'cyan', 'EdgeColor', 'none', 'FaceAlpha', 0.3);
camlight; lighting gouraud;
view(3); axis tight; daspect([1 1 1]);
%}
end





%{
function [refinedcoords, fitinfo] = fit3DGaussian(intensityMatrix,guesscoords,channelimage,coords)
% Get the size of the matrix
[Nx, Ny, Nz] = size(intensityMatrix);

% Corrected background calculation
background = calcBackground(channelimage,coords);

% Subtract background
intensityMatrix = intensityMatrix - background;

% Generate coordinate grids
[X, Y, Z] = meshgrid(1:Nx, 1:Ny, 1:Nz);

% Convert data to vectors for fitting
xData = [X(:), Y(:), Z(:)];
yData = intensityMatrix(:);

% Initial guess: find approximate center and spread
[~, maxIdx] = max(yData);  % Find peak intensity
[xPeak, yPeak, zPeak] = ind2sub(size(intensityMatrix), maxIdx);

A0 = max(yData); % Initial amplitude
sigmaX0 = Nx / 4; sigmaY0 = Ny / 4; sigmaZ0 = Nz / 4; % Rough sigma estimates

% Initial parameter vector
initParams = [A0, xPeak, sigmaX0, yPeak, sigmaY0, zPeak, sigmaZ0];

% Define lower and upper bounds
lowerBounds = [0, 0, 0.00001, 0, 0.00001, 0, 0.00001]; % Amplitude > 0, sigmas > 0.1
upperBounds = [Inf, Inf, Inf, Inf, Inf, Inf, Inf]; % Center within bounds, reasonable sigmas

% Define 3D Gaussian function
gauss3D = @(params, xyz) params(1) * exp(-((xyz(:,1)-params(2)).^2 / (2*params(3)^2) + ...
    (xyz(:,2)-params(4)).^2 / (2*params(5)^2) + ...
    (xyz(:,3)-params(6)).^2 / (2*params(7)^2)));

% Ensure all inputs are double
initParams = double(initParams);
xData = double(xData);
yData = double(yData);
lowerBounds = double(lowerBounds);
upperBounds = double(upperBounds);

% Define optimization options

Bestoptions = optimoptions('lsqcurvefit', ...
    'MaxIterations', 2000, ...            % Increase the max iterations
    'MaxFunctionEvaluations', 3500, ...   % Increase function evaluations
    'FunctionTolerance', 1e-10, ...       % Improve convergence criteria
    'OptimalityTolerance', 1e-10);                   % Show iteration progress

% Perform the fitting with bounds
fittedParams = lsqcurvefit(gauss3D, initParams, xData, yData, lowerBounds, upperBounds,[],[],[],[],[],Bestoptions);

% Extract results
A_fit = fittedParams(1);
mu_x = fittedParams(2);
sigma_x = fittedParams(3);
mu_y = fittedParams(4);
sigma_y = fittedParams(5);
mu_z = fittedParams(6);
sigma_z = fittedParams(7);

%{
% Display results
fprintf('Fitted Center: (%.2f, %.2f, %.2f)\n', mu_x, mu_y, mu_z);
fprintf('Sigma Values: (σ_x = %.2f, σ_y = %.2f, σ_z = %.2f)\n', sigma_x, sigma_y, sigma_z);
fprintf('Amplitude: %.2f', A_fit);
%}
% Compute predicted values from the fitted model
yPredicted = gauss3D(fittedParams, xData);

% Compute R-squared
SS_res = sum((yData - yPredicted).^2);   % Residual sum of squares
SS_tot = sum((yData - mean(yData)).^2);  % Total sum of squares
R_squared = 1 - (SS_res / SS_tot);


% Display R-squared
%fprintf('\nR-squared: %.4f\n', R_squared);

origx = guesscoords(1);
origy = guesscoords(2);
origz = guesscoords(3);
refinedcoords = [mu_x-origx,mu_y-origy,mu_z-origz];
fitinfo = {A_fit,sigma_x,sigma_y,sigma_z,R_squared};


% Visualization
R_squared
figure;
slice(X, Y, Z, intensityMatrix, round(mu_x), round(mu_y), round(mu_z));
colormap jet; shading interp;
title('Fitted 3D Gaussian PSF');
xlabel('X'); ylabel('Y'); zlabel('Z');
hold on;
scatter3(mu_x, mu_y, mu_z, 100, 'w', 'filled'); % Mark the center


% Create a high-resolution grid for smooth visualization
[xFit, yFit, zFit] = meshgrid(1:0.5:Nx, 1:0.5:Ny, 1:0.5:Nz);
xVec = [xFit(:), yFit(:), zFit(:)];

% Evaluate the fitted 3D Gaussian on the grid
gaussVals = gauss3D(fittedParams, xVec);
gaussVol = reshape(gaussVals, size(xFit));

% Add the isosurface
isosurfaceLevel = 0.5 * A_fit; % Choose an appropriate level (e.g., half max)
h = patch(isosurface(xFit, yFit, zFit, gaussVol, isosurfaceLevel));
isonormals(xFit, yFit, zFit, gaussVol, h);
set(h, 'FaceColor', 'cyan', 'EdgeColor', 'none', 'FaceAlpha', 0.3); % Transparent cyan
camlight; lighting gouraud;

% Adjust the view
view(3); axis tight; daspect([1 1 1]);


end
%}