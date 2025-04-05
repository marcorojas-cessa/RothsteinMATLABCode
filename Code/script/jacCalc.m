function jacindex = jacCalc(cell1,cell2)
% cell1 and cell2 are 3-column matrices where each column
% represents coordinates (x, y, z) for R, Y, B spots respectively.

% Calculate Jaccard Index for Red spots
if isempty(cell2mat(cell1(2))) || isempty(cell2mat(cell2(2)))
    redIntersection = 0;
    redUnion = max([size(cell2mat(cell1(2)),1), size(cell2mat(cell2(2)),1)]);
else
    redIntersection = size(intersect(cell2mat(cell1(2)), cell2mat(cell2(2)), 'rows'),1);
    redUnion = size(unique([cell2mat(cell1(2)); cell2mat(cell2(2))], 'rows'),1);
end
redJaccard = redIntersection / redUnion;

% Calculate Jaccard Index for Yellow spots
if isempty(cell2mat(cell1(3))) || isempty(cell2mat(cell2(3)))
    yellowIntersection = 0;
    yellowUnion = max([size(cell2mat(cell1(3)),1), size(cell2mat(cell2(3)),1)]);
else
    yellowIntersection = size(intersect(cell2mat(cell1(3)), cell2mat(cell2(3)), 'rows'),1);
    yellowUnion = size(unique([cell2mat(cell1(3)); cell2mat(cell2(3))], 'rows'),1);
end
yellowJaccard = yellowIntersection / yellowUnion;

% Calculate Jaccard Index for Blue spots
if isempty(cell2mat(cell1(4))) || isempty(cell2mat(cell2(4)))
    blueIntersection = 0;
    blueUnion = max([size(cell2mat(cell1(4)),1), size(cell2mat(cell2(4)),1)]);
else
    blueIntersection = size(intersect(cell2mat(cell1(4)), cell2mat(cell2(4)), 'rows'),1);
    blueUnion = size(unique([cell2mat(cell1(4)); cell2mat(cell2(4))], 'rows'),1);
end
blueJaccard = blueIntersection / blueUnion;

% Mean Jaccard Index for R, Y, B
tally =[isnan(redJaccard);isnan(yellowJaccard);isnan(blueJaccard)];
tally = sum(tally);
if isnan(redJaccard)
    redJaccard = 0;
end
if isnan(yellowJaccard)
    yellowJaccard = 0;
end
if isnan(blueJaccard)
    blueJaccard = 0;
end

jacindex = (redJaccard + yellowJaccard + blueJaccard) / (3-tally);

end


