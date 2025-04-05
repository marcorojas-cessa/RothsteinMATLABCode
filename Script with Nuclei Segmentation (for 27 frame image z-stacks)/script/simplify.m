function [x,y,z] = simplify(coord,zframeno)

if coord(1) <= 1
    x = 1;
elseif coord(1) >= 510
    x = 510;
else
    x = round(coord(1));
end

if coord(2) <= 1
    y = 1;
elseif coord(2) >= 672
    y = 672;
else
    y = round(coord(2));
end

if coord(3) <= 1
    z = 1;
elseif coord(3) >= zframeno
    z = zframeno;
else
    z = round(coord(3));
end


end