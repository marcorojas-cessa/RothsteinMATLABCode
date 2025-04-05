%{
Marco Rojas-Cessa
Rothstein Lab
Columbia University

get3Ddistance.m function

determine distance between two points in 3D space

inputs:
coord1,coord2 - coordinates with x,y,z location

output:
distance - numerical 3D distance in nm
%}

function [distance] = get3Ddistance(coord1,coord2)
%uses a pixel size of 128.866 nm and a z-step of 300 nm

x=((coord1(1)-coord2(1))*128.866)^2;
y=((coord1(2)-coord2(2))*128.866)^2;
z=((coord1(3)-coord2(3))*300)^2;
distance = sqrt(x+y+z);
end