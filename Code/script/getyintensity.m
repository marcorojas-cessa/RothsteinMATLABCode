%{
Marco Rojas-Cessa
Rothstein Lab
Columbia University

getyintensity.m function

get the intensities of the yellow spots

input:
ycoords - coordinates of the yellow local maxima signals
class - string representation of genotype class of the cell
channel2zstack - compressed 2D image of the yellow channel by maximum
values

output:
yclass - returning the same class string
yintensity - intensity of y signal(s)
%}

function [yclass,yintensity] = getyintensity(ycoords,class,channel2zstack)

yclass=class;
tempycoord=[round(ycoords(1)),round(ycoords(2))];
%get noise level of signal
tempbkgrd=getBackground(channel2zstack,tempycoord);
x=tempycoord(1);
y=tempycoord(2);
%calculate signal based off a 11-by-11 pixel cut out centered at the
%signal's maximum
tempimage=channel2zstack(x-5:x+5,y-5:y+5);
%background correct
tempimage=tempimage-tempbkgrd;
%add all pixel values within the cut out to represent intensity
yintensity=sum(tempimage,'all');
end

