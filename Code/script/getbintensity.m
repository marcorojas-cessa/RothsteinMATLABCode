%{
Marco Rojas-Cessa
Rothstein Lab
Columbia University

getbintensity.m function

get intensity values of blue local maxima signals

input:
bcoords-coordinate of blue local maxima signals
class-string representing genotype class of the cell
channel3zstack-compressed 2D image of blue channel by maximum values

output:
bclass-returning same class string
bintensity-intensity(ies) of blue signal(s)
%}

function [bclass,bintensity] = getbintensity(bcoords,class,channel3zstack)

bclass=class;
bintensity=[0];
    tempbcoord=[round(bcoords(1)),round(bcoords(2))];
    %get noise of signal
    tempbkgrd=getBackground(channel3zstack,tempbcoord);
    x=tempbcoord(1);
    y=tempbcoord(2);
    %11-by-11 cutout centered at signal maximum
    tempimage=channel3zstack(x-5:x+5,y-5:y+5);
    %background correct
    tempimage=tempimage-tempbkgrd;
    %sum all pixel values to represent intensity
    bintensity=sum(tempimage,'all');
end

