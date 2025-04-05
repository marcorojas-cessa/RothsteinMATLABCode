%{
Marco Rojas-Cessa
Rothstein Lab
Columbia University

mijistartup.m script

get MIJI running and deconvolute image z-stacks
%}

%locate MIJI, PSFGenerator, and DeconvolutionLab2 plugins for use in MATLAB
javaaddpath 'C:\Program Files\MATLAB\R2023a\java\mij.jar'
javaaddpath 'C:\Program Files\MATLAB\R2023a\java\ij.jar'
javaaddpath 'C:\Program Files\MATLAB\R2023a\java\PSFGenerator.jar'
javaaddpath 'C:\Program Files\MATLAB\R2023a\java\DeconvolutionLab_2.jar'

%prompt user to type in the file name of the entire image tiff file to be
%analyzed
filename=input('What is the file name (including extension)? ','s')
images=loadtiff(filename);

%separate tiff file into respective channel image z-stacks
channela=images(:,:,28:54);
channelb=images(:,:,55:81);
channelc=images(:,:,82:108);

%prompt the user to input the color order that the images were taken in
colororder=input('What is the color channel order (eg. ryb)? ','s');

%deconvolute and normalize channel1 to red, channel2 to yellow, and
%channel3 to blue
[deconvchannel1,deconvchannel2,deconvchannel3]=deconvolute(channela,channelb,channelc,colororder);

%create matrix variables to represent the deconvoluted tiff images
for p = 1 : size(deconvchannel1, 3)
    imwrite(uint16(deconvchannel1(:,:,p)), 'deconvchannel1.tif' , 'WriteMode' , 'append');
    imwrite(uint16(deconvchannel2(:,:,p)), 'deconvchannel2.tif' , 'WriteMode' , 'append');
    imwrite(uint16(deconvchannel3(:,:,p)), 'deconvchannel3.tif' , 'WriteMode' , 'append');
end

%command to start up MIJI
MIJ.start

