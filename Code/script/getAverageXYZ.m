function coord = getAverageXYZ(cellrow)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%get all coords
allcoord=[];
red = cell2mat(cellrow(2));
yellow = cell2mat(cellrow(3));
blue = cell2mat(cellrow(4));
allcoord=vertcat(allcoord,red,yellow,blue);
if isempty(allcoord)
    coord = [];
else
    x = mean(allcoord(:,1));
    y = mean(allcoord(:,2));
    z = mean(allcoord(:,3));
    coord = [x,y,z];
end
end