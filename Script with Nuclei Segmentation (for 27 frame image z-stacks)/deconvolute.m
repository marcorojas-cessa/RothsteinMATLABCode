%{
Marco Rojas-Cessa
Rothstein Lab
Columbia University

deconvolute.m function

inputs:
channel1,channel2,channel3 - image z-stack of respective channel
colororder - string with order of color channels

outputs:
deconvchannel1,deconvchannel2,deconvchannel3 - deconvoluted image z-stack
of respective channel
%}

function [deconvchannel1,deconvchannel2,deconvchannel3] = deconvolute(channel1,channel2,channel3,colororder)
% find and locate color order
redindex = find(colororder=='r');
yellowindex = find(colororder=='y');
blueindex= find(colororder == 'b');

% load color PSFS by locating correct directory
redpsf=loadtiff("C:\Users\umpai\OneDrive\Desktop\Rothstein Labwork\scripting\red PSF.tif");
yellowpsf=loadtiff("C:\Users\umpai\OneDrive\Desktop\Rothstein Labwork\scripting\yellow PSF.tif");
bluepsf=loadtiff("C:\Users\umpai\OneDrive\Desktop\Rothstein Labwork\scripting\blue PSF.tif");

% determine color order numerically and replace channel numbers with r,y or
% b
if redindex == 1
    %ryb
    if yellowindex == 2
        channelr=channel1;
        channely=channel2;
        channelb=channel3;
    %rby
    else
        channelr=channel1;
        channely=channel3;
        channelb=channel2;
    end
elseif yellowindex == 1
    %yrb
    if redindex == 2
        channelr=channel2;
        channely=channel1;
        channelb=channel3;
    %ybr
    else
        channelr=channel3;
        channely=channel1;
        channelb=channel2;
    end
else
    %bry
    if redindex == 2
        channelr=channel2;
        channely=channel3;
        channelb=channel1;
    %byr
    else
        channelr=channel3;
        channely=channel2;
        channelb=channel1;
    end
end

% use DeconvolutionLab2's MATLAB plugin to deconvolute with original
% z-stack, PSF file, and iteration count
deconvchannel1=DL2.RL(channelr,redpsf,10);
deconvchannel2=DL2.RL(channely,yellowpsf,10);
deconvchannel3=DL2.RL(channelb,bluepsf,10);
end