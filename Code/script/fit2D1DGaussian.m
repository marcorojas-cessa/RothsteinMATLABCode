function [refinedcoords, fitinfo] = fit2D1DGaussian(intensityMatrix, guesscoords, channelimage, coords, length, length2)

% Step 0: Subtract background using full cube
background = calcBackground(channelimage, coords, length,length2);
intensityMatrix = intensityMatrix - background;

[x_fit, y_fit, ampXY, sigmaX, sigmaY,r2xy] = fit2DGaussian(intensityMatrix(:,:,guesscoords(3)), guesscoords(1:2));

% Step 2: 1D Gaussian fit in Z at (x_guess, y_guess)
zline=intensityMatrix(guesscoords(1),guesscoords(2),:);
[A_z,z_fit,sigmaZ,r2z] = fit1DGaussianZ(zline, guesscoords(3));

% Final sub-pixel shift
refinedcoords = [x_fit - guesscoords(1), y_fit - guesscoords(2), z_fit - guesscoords(3)];
fitinfo = {ampXY, A_z, sigmaX, sigmaY, sigmaZ,r2xy,r2z};
end



function [x0, y0, A, sigma_x, sigma_y,r2] = fit2DGaussian(img2D, guessXY)
    [Ny, Nx] = size(img2D);
    [X, Y] = meshgrid(1:Nx, 1:Ny);

    x0_init = guessXY(1);
    y0_init = guessXY(2);
    A_init = max(img2D(:));
    sigma_x_init = 1.5;
    sigma_y_init = 1.5;

    gaussian2D = @(p, xy) ...
        p(1) * exp(-((xy(:,1)-p(2)).^2 / (2*p(4)^2) + (xy(:,2)-p(3)).^2 / (2*p(5)^2)));

    xdata = [X(:), Y(:)];
    ydata = img2D(:);

    initParams = [A_init, x0_init, y0_init, sigma_x_init, sigma_y_init];

    options = optimoptions('lsqcurvefit', 'Display', 'final');
    fitParams = lsqcurvefit(gaussian2D, initParams, xdata, ydata, [], [], options);

    A = fitParams(1);
    x0 = fitParams(2);
    y0 = fitParams(3);
    sigma_x = fitParams(4);
    sigma_y = fitParams(5);

    % Compute fitted values
    yfit = gaussian2D(fitParams, xdata);

    % R² calculation
    SS_res = sum((ydata - yfit).^2);
    SS_tot = sum((ydata - mean(ydata)).^2);
    r2 = 1 - SS_res / SS_tot;

    %{
    % 📈 Visualization
    fitted2D = reshape(gaussian2D(fitParams, xdata), size(img2D));
    figure;
    subplot(1,2,1);
    imagesc(img2D); axis image; title('Original XY Slice'); hold on;
    scatter(x0, y0, 50, 'r', 'filled');
    subplot(1,2,2);
    imagesc(fitted2D); axis image; title('Fitted 2D Gaussian');
    hold on; scatter(x0, y0, 50, 'r', 'filled');
    %}

end



function [A_z,z0,sigmaz,r2] = fit1DGaussianZ(zline, zguesscoord)
    Nz = length(zline);
    Z = meshgrid(1:Nz,1);

    intensities = zline;

    % Initial parameters
    A_init = max(intensities);
    z0_init = zguesscoord;
    sigma_init = 1.5;

    gauss1D = @(p, z) p(1) * exp(-((z - p(2)).^2) / (2*p(3)^2));
    initParams = [A_init, z0_init(1), sigma_init];
    options = optimoptions('lsqcurvefit', 'Display', 'final');
    fitParams = lsqcurvefit(gauss1D, initParams, Z, squeeze(intensities)', [], [], options);
    A_z = fitParams(1);
    z0 = fitParams(2);
    sigmaz = fitParams(3);

    % Compute fitted values
    yfit = gauss1D(fitParams, Z);
    ydata = squeeze(intensities)';

    % R² calculation
    SS_res = sum((ydata - yfit).^2);
    SS_tot = sum((ydata - mean(ydata)).^2);
    r2 = 1 - SS_res / SS_tot;

    %{
    % 📈 Visualization
    fittedZ = gauss1D(fitParams, Z);
    plot(Z, squeeze(intensities)', 'ko', 'MarkerSize', 6); hold on;
    plot(Z, fittedZ, 'r-', 'LineWidth', 2);
    title('1D Gaussian Fit in Z');
    xlabel('Z'); ylabel('Intensity');
    legend('Raw', 'Fit');
    xline(z0, '--r', 'Center');
    %}

end