function [refinedchannelcoords,fits] = getInfo(channelcoords,channelimages,length,length2,pick)
    
    % Define search window size
    if pick ~= 3
        x_range = length;  
        y_range = length;  
        z_range = length; 
    else
        x_range = length;
        y_range = length;
        z_range = length2;
    end

    [Nx, Ny, Nz] = size(channelimages);  % Image dimensions

    refinedchannelcoords=[];
    fits={};

for i=1:size(channelcoords,1)
    X = channelcoords(i,1);
    Y = channelcoords(i,2);
    Z = channelcoords(i,3);

    % Define the cropping boundaries ensuring they are within the image
    x_min = max(X - x_range, 1);
    x_max = min(X + x_range, Nx);
    y_min = max(Y - y_range, 1);
    y_max = min(Y + y_range, Ny);
    z_min = max(Z - z_range, 1);
    z_max = min(Z + z_range, Nz);
    tempimage = channelimages(x_min:x_max, y_min:y_max, z_min:z_max);
    tempimage = double(tempimage);
    X_cut = X - x_min + 1;
    Y_cut = Y - y_min + 1;
    Z_cut = Z - z_min + 1;
    guesscoord = [X_cut,Y_cut,Z_cut];

    if pick == 1
        [tempcoord,fitinfo] = fitdistorted3DGaussian(tempimage,guesscoord,channelimages,channelcoords(i,:),length);
    elseif pick == 2
        [tempcoord,fitinfo] = fit3DGaussian(tempimage,guesscoord,channelimages,channelcoords(i,:),length);
    else
        [tempcoord,fitinfo] = fit2D1DGaussian(tempimage,guesscoord,channelimages,channelcoords(i,:),length,length2);
    end
    tempcoord = [X+tempcoord(1),Y+tempcoord(2),Z+tempcoord(3)];
    refinedchannelcoords = [refinedchannelcoords;tempcoord];
    fits(end+1,:) = fitinfo;
    end
end