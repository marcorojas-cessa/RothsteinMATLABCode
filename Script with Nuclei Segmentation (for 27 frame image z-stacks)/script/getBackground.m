%{
Marco Rojas-Cessa
Rothstein Lab
Columbia University

getBackground.m function

determine noise/background value by averaging the pixel values around a
certain location

input:
image- 2D compressed channel image by maximum values
coords - array representing x,y,z location of local maxima signal

output:
background - value of noise/background
%}

function [background] = getBackground(image,coords)

background=0;
x =round(coords(1));
y=round(coords(2));

%11-by-11 pixel cut out centered at coords
tempimage=image(x-5:x+5,y-5:y+5);
%sum of pixel values along perimeter
perimeter_sum= sum(tempimage(1,:)) + sum(tempimage(11,:)) + sum(tempimage(:,1)) + sum (tempimage(:,11)) - tempimage(1,1) - tempimage(1,11) - tempimage(11,1) - tempimage(11,11);
%average perimeter value
background=perimeter_sum/40;
end