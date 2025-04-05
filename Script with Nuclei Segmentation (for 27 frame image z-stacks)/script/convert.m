%{
Marco Rojas-Cessa
Rothstein Lab
Columbia University

convert.m function

input:
imagejcoords- coords with x,y location retrieved from Results panel in MIJI
(being in the FIJI/ImageJ orientation)

output:
matlabcoords- coords with x,y location with MATLAB orientation
%}

function [matlabcoords] = convert(imagejcoords)

matlabcoords=zeros(length(imagejcoords),2);

for i=1:length(imagejcoords)
    matlabcoords(i,1)=floor(imagejcoords(i,2)+1);
    matlabcoords(i,2)=floor(imagejcoords(i,1)+1);
end

end