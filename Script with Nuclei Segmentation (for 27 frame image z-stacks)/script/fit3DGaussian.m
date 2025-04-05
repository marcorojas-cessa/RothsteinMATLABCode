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

% Display results
fprintf('Fitted Center: (%.2f, %.2f, %.2f)\n', mu_x, mu_y, mu_z);
fprintf('Sigma Values: (σ_x = %.2f, σ_y = %.2f, σ_z = %.2f)\n', sigma_x, sigma_y, sigma_z);
fprintf('Amplitude: %.2f', A_fit);

% Compute predicted values from the fitted model
yPredicted = gauss3D(fittedParams, xData);

% Compute R-squared
SS_res = sum((yData - yPredicted).^2);   % Residual sum of squares
SS_tot = sum((yData - mean(yData)).^2);  % Total sum of squares
R_squared = 1 - (SS_res / SS_tot);

% Display R-squared
fprintf('\nR-squared: %.4f\n', R_squared);

origx = guesscoords(1);
origy = guesscoords(2);
origz = guesscoords(3);
refinedcoords = [mu_x-origx,mu_y-origy,mu_z-origz];
fitinfo = {A_fit,sigma_x,sigma_y,sigma_z,R_squared};

%{
% Visualization
figure;
slice(X, Y, Z, intensityMatrix, round(mu_x), round(mu_y), round(mu_z));
colormap jet; shading interp;
title('Fitted 3D Gaussian PSF');
xlabel('X'); ylabel('Y'); zlabel('Z');
hold on;
scatter3(mu_x, mu_y, mu_z, 100, 'w', 'filled'); % Mark the center
%}
end