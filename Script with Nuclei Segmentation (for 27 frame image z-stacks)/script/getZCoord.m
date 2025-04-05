function finalchannelcoords = getZCoord(channelcoords,channelimages)



finalchannelcoords = [];

for i=1:size(channelcoords,1)
    x = channelcoords(i,1);
    y = channelcoords(i,2);
    zs = channelimages(x,y,:);
    index = find(zs == max(zs));
    if size(index,1) > 1
        index = mean(index);
        index = round(index);
    end
    finalchannelcoords = [finalchannelcoords; [x,y,index]];
%{
figure;
exes=1:27;
zs = squeeze(zs);
scatter(exes,zs);
%}
end

end