%{
Marco Rojas-Cessa
Rothstein Lab
Columbia University

cleanCoords.m function

get rid of coordinates that are less than some distance to the edges

input:
coords - matrix of coords in matlab X,Y
distance - distance in nm from boundary to exclude points

output:
coords_edited - matrix of coords that exclude those too close to the edges
%}

function [coords_edited,coords_removed] = cleanCoords(coords, distance)

boundarylength = ceil(distance/128.866);
coords_edited=[];
coords_removed=[];

lowlim = boundarylength;
upperlim1 = 512-boundarylength;
upperlim2 = 672-boundarylength;

for i=1:size(coords,1)
    x = coords(i,1);
    y = coords(i,2);
    if x <= lowlim || x >= upperlim1 || y <= lowlim || y >= upperlim2
        coords_removed=[coords_removed; coords(i,:)];
    else
        coords_edited=[coords_edited;coords(i,:)];
    end
end
end