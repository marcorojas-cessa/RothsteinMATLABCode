%{
Marco Rojas-Cessa
Rothstein Lab
Columbia University

getIntensity.m function

get intensity values of local maxima signals

input:
coords-coordinate of local maxima signals
channelzstack-compressed 2D image of channel by maximum values

output:
intensity-intensity(ies) of red signal(s)
%}

function intensity = getredintensity(coords,channelzstack)

intensity=[0];
    tempcoord=[round(coords(1)),round(coords(2))];
    %get noise of signal
    tempbkgrd=getBackground(channelzstack,tempcoord);
    x=tempcoord(1);
    y=tempcoord(2);
    %11-by-11 cutout centered at signal maximum
    tempimage=channelzstack(x-5:x+5,y-5:y+5);
    %background correct
    tempimage=tempimage-tempbkgrd;
    %sum all pixel values to represent intensity
    intensity=sum(tempimage,'all');
end

