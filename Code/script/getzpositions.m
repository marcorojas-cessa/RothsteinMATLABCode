%{
Marco Rojas-Cessa
Rothstein Lab
Columbia University

getzpositions.m function

determine sub-z locations of local maxima signals

input:
matlabcoords - matrix representing coords of a certain color of local
maxima signals in MATLAB-oriented coords
images - deconvoluted image z-stack of the same color channel

output:
finalcoords - coords with sub-z locations
%}

function [finalcoords,fitdata] = getzpositions(matlabcoords,images,zframeno)

zlocation=zeros(size(matlabcoords,1),1);
fitdata=zeros(size(matlabcoords,1),3);

%as a first measure, make the z location the z frame with the greatest
%value
for m=1:1:size(matlabcoords,1)
    maxZ=0;
    templocation=0;
    for n=1:1:size(images,3)
        if images(matlabcoords(m,1),matlabcoords(m,2),n) > maxZ
            maxZ = images(matlabcoords(m,1),matlabcoords(m,2),n);
            templocation=n;
        end
    end
    zlocation(m)=templocation;
end

%edges cases if the z-location is towards the top or bottom
%look through 6 frames from both sides of the max z frame as input data for
%Gaussian fitting
for m=1:1:length(zlocation)
    if zlocation(m) > zframeno-6
        zvalues=images(matlabcoords(m,1),matlabcoords(m,2),zlocation(m)-6:zframeno);
        x=-6:1:zframeno-zlocation(m);
    elseif zlocation(m) <= 6
        zvalues=images(matlabcoords(m,1),matlabcoords(m,2),1:zlocation(m)+6);
        x=(zlocation(m)-1)*-1:1:6;
    else
        x=-6:1:6;
        zvalues=images(matlabcoords(m,1),matlabcoords(m,2),zlocation(m)-6:zlocation(m)+6);
    end

    zvalues=squeeze(zvalues);
    %this is using a gaussian with arbitrary amplitude
    zvalues=zvalues-min(zvalues);
    maxValue = max(zvalues);
    zvalues=zvalues./maxValue;
    [fitresult,gof]=gaussianfit2(x,zvalues);
    zlocation(m) = zlocation(m)+fitresult.b1;
    amplitude = fitresult.a1*maxValue;
    sigma = fitresult.c1 / sqrt(2);
    rsquared = gof.rsquare;
    fitdata(m,:)=[amplitude,sigma,rsquared];

    %this is using a normalized 1 amplitude gaussian
    %{
    normamplitude=range(zvalues);
    %normalize to fit a Gaussian with an amplitude of 1
    normzvalues=double((zvalues-min(zvalues)))./double(normamplitude);
    %fit gaussian and return fitting results
    [fitresult,gof]=gaussianfit(x,normzvalues);
    %fitresult.b represents how deviated from the center the Gaussian's
    %center is, recalculate zlocation to represent sub-z frame location
    zlocation(m)=zlocation(m)+fitresult.b;  
    %}
end

%get rid of bad fits with r^2 below 0.8

indices = find(fitdata(:,3) < 0.8);
matlabcoords(indices,:)=[];
zlocation(indices,:)=[];
fitdata(indices,:)=[];

finalcoords=zeros(size(matlabcoords,1),3);

for p=1:1:size(finalcoords,1)
    finalcoords(p,1)=matlabcoords(p,1);
    finalcoords(p,2)=matlabcoords(p,2);
    finalcoords(p,3)=zlocation(p);

end

end