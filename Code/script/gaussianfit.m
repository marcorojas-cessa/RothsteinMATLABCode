%{
Marco Rojas-Cessa
Rothstein Lab
Columbia University

gaussianfit.m function

this is simply the extracted code from the Curve Fitting App in MATLAB of a
Gaussian Fit
%}

function [fitresult, gof] = createFit(x, zvalues)

[xData, yData] = prepareCurveData( x, zvalues );

% Set up fittype and options.
ft = fittype( '1*exp(-(x-b)^2/c)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.149294005559057 0.257508254123736];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
%{
% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h = plot( fitresult, xData, yData );
legend( h, 'zvalues vs. x', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 'x', 'Interpreter', 'none' );
ylabel( 'zvalues', 'Interpreter', 'none' );
grid on
%}


