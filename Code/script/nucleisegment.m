%{
initiate variable totalcelldata, which represents the results:
a cell's data is represented by a row
matrix column order:
1. cell color
2. r loc
3. y loc
4. b loc
5. r intensity
6. y intensity
7. b intensity
8. rr dis
9. yy dis
10. bb dis
11. ry dis
12. rb dis
13. yb dis
%}

totalcelldata={};

%load binary mask
binaryMask = loadtiff('channel3_binaryMask.tif');
binaryMask = double(binaryMask);

%label each nuclei
[nuclei,labeledNuclei] = getNuclei(binaryMask);
nuclei_Centroids=[];
nuclei_Volumes=[];
if ~isempty(nuclei)
    nuclei_Centroids = nuclei(:,2:4);
    nuclei_Volumes = nuclei(:,1);
end

%only look at nuclei with centroids in the middle half of the z-stack
for i=1:size(nuclei,1)
    %{
    for jah=1:size(removedcoords,1)
        %get rid of nuclei whose signals were removed because they were too
        %close to the edges
        if binaryMask(removedcoords(jah,:)) > 0 && i == labeledNuclei(removedcoords(jah,:))
        
        
        else
    %}
    nucleicentroid = nuclei_Centroids(i,:);
    nucleivolume = nuclei_Volumes(i);
    %{
            %get rid of nuclei too close to the edges
            pixels= ceil(boundarydistance/128.866);
            centroidtooclose = nucleicentroid(1) < pixels || nucleicentroid(1) > 672 - pixels || nucleicentroid(2) < pixels || nucleicentroid(2) > 512 - pixels;
            %get rid of nuclei outside Z window
            if nuclei(i,4) > zframeno*((1-zprop)/2) && nuclei(i,4) < zframeno*(1-((1-zprop)/2)) && ~centroidtooclose
    %}
    cellcolor="";
    cellrloc=[];
    cellrintensity=[];
    cellyloc=[];
    cellyintensity=[];
    cellbloc=[];
    cellbintensity=[];
    ramplitude=[];
    rsigma=[];
    rrsquared=[];
    yamplitude=[];
    ysigma=[];
    yrsquared=[];
    bamplitude=[];
    bsigma=[];
    brsquared=[];

    %red channel
    for m=1:size(channel1coords,1)
        x = channel1coords(m,1);
        y = channel1coords(m,2);
        z = channel1coords(m,3);
        %{
                    %make sure sub-z location of signal was estimated within bounds of z-stack
                    iszgood = z <= 27 && z >= 1;
                    %if iszgood and signal lies within the current nucleus
                    if iszgood && binaryMask(round(x),round(y),round(z)) > 0 && i == labeledNuclei(round(x),round(y),round(z))
        %}
        [x_s,y_s,z_s] = simplify([x,y,z],size(channel1images,3));
        if binaryMask(x_s,y_s,z_s) > 0 && i == labeledNuclei(x_s,y_s,z_s)
            %populate results
            cellcolor=cellcolor+"R";
            cellrloc=vertcat(cellrloc,[x.*128.866,y.*128.866,z.*300]);
            %redintensity=getIntensity([x,y,z],channel1zstack);
            fitinfo = fits1(m,:);
            fitinfo = cell2mat(fitinfo);
            redintensity = fitinfo(1)*(2*pi)^(3/2)*fitinfo(2)*fitinfo(3)*fitinfo(4);
            cellrintensity=vertcat(cellrintensity,redintensity);
            %z position gaussian fit data
            ramplitude=vertcat(ramplitude,fits1(m,1));
            rsigma=vertcat(rsigma,fits1(m,2:4));
            rrsquared=vertcat(rrsquared,fits1(m,5));
        end
    end

    %yellow channel
    for n=1:size(channel2coords,1)
        x = channel2coords(n,1);
        y = channel2coords(n,2);
        z = channel2coords(n,3);
        [x_s,y_s,z_s] = simplify([x,y,z],size(channel1images,3));
        iszgood = z <= 27 && z >= 1;
        if binaryMask(x_s,y_s,z_s) > 0 && i == labeledNuclei(x_s,y_s,z_s)
            cellcolor=cellcolor+"Y";
            cellyloc=vertcat(cellyloc,[x.*128.866,y.*128.866,z.*300]);
            %yintensity=getIntensity([x,y,z],channel2zstack);
            fitinfo = fits2(n,:);
            fitinfo = cell2mat(fitinfo);
            yintensity = fitinfo(1)*(2*pi)^(3/2)*fitinfo(2)*fitinfo(3)*fitinfo(4);
            cellyintensity=vertcat(cellyintensity,yintensity);
            %z position gaussian fit data
            yamplitude=vertcat(yamplitude,fits2(n,1));
            ysigma=vertcat(ysigma,fits2(n,2:4));
            yrsquared=vertcat(yrsquared,fits2(n,5));
        end
    end

    %blue channel
    for p=1:size(channel3coords,1)
        x = channel3coords(p,1);
        y = channel3coords(p,2);
        z = channel3coords(p,3);
        [x_s,y_s,z_s] = simplify([x,y,z],size(channel1images,3));
        iszgood = z <= 27 && z >= 1;
        if binaryMask(x_s,y_s,z_s) > 0 && i == labeledNuclei(x_s,y_s,z_s)
            cellcolor=cellcolor+"B";
            cellbloc=vertcat(cellbloc,[x.*128.866,y.*128.866,z.*300]);
            %bintensity=getIntensity([x,y,z],channel3zstack);
            fitinfo = fits3(p,:);
            fitinfo = cell2mat(fitinfo);
            bintensity = fitinfo(1)*(2*pi)^(3/2)*fitinfo(2)*fitinfo(3)*fitinfo(4);
            cellbintensity=vertcat(cellbintensity,bintensity);

            %z position gaussian fit data
            bamplitude=vertcat(bamplitude,fits3(p,1));
            bsigma=vertcat(bsigma,fits3(p,2:4));
            brsquared=vertcat(brsquared,fits3(p,5));
        end
    end

    rgaussdata = horzcat(ramplitude,rsigma,rrsquared);
    ygaussdata = horzcat(yamplitude,ysigma,yrsquared);
    bgaussdata = horzcat(bamplitude,bsigma,brsquared);


    %compute all pairwise distances
    if ~isempty(cellrloc)
        RR = pdist2(cellrloc, cellrloc); % Distances between red points
    else
        RR = [];
    end
    if ~isempty(cellyloc)
        YY = pdist2(cellyloc, cellyloc); % Distances between yellow points
    else
        YY = [];
    end
    if ~isempty(cellbloc)
        BB = pdist2(cellbloc, cellbloc); % Distances between blue points
    else
        BB = [];
    end
    if ~isempty(cellrloc) && ~isempty(cellyloc)
        RY = pdist2(cellrloc, cellyloc); % Distances between red and yellow points
    else
        RY = [];
    end
    if ~isempty(cellrloc) && ~isempty(cellbloc)
        RB = pdist2(cellrloc, cellbloc); % Distances between red and blue points
    else
        RB = [];
    end
    if ~isempty(cellyloc) && ~isempty(cellbloc)
        YB = pdist2(cellyloc, cellbloc); % Distances between yellow and blue points
    else
        YB=[];
    end

    %remove self-distances and duplicate entries for same-color pairs
    RR = triu(RR, 1); % Extract upper triangular part (excluding diagonal)
    YY = triu(YY, 1);
    BB = triu(BB, 1);

    %flatten non-zero elements (non-NaN) for same-color distances
    RR = nonzeros(RR); % Unique RR distances
    YY = nonzeros(YY); % Unique YY distances
    BB = nonzeros(BB); % Unique BB distances

    %store distances in a cell array
    distanceCell = {
        RR(:), ... % RR distances
        YY(:), ... % YY distances
        BB(:), ... % BB distances
        RY(:), ... % RY distances
        RB(:), ... % RB distances
        YB(:)      % YB distances
        };

    %replace empty arrays with [] to cut
    for i = 1:length(distanceCell)
        if isempty(distanceCell{i})
            distanceCell{i} = [];
        end
    end


    if ~isempty(cellrloc)
        cellrloc(:,1:2) = cellrloc(:,1:2)./128.866;
        cellrloc(:,3) = cellrloc(:,3)./300;
    end
    if ~isempty(cellyloc)
        cellyloc(:,1:2) = cellyloc(:,1:2)./128.866;
        cellyloc(:,3) = cellyloc(:,3)./300;
    end
    if ~isempty(cellbloc)
        cellbloc(:,1:2) = cellbloc(:,1:2)./128.866;
        cellbloc(:,3) = cellbloc(:,3)./300;
    end

    cellentry = {cellcolor,cellrloc,cellyloc,cellbloc,cellrintensity,cellyintensity,cellbintensity,rgaussdata,ygaussdata,bgaussdata};
    cellentry(end+1:end+6) = distanceCell;
    cellentry(end+1) = {nucleicentroid};
    cellentry(end+1) = {nucleivolume};
    if isempty(totalcelldata)
        totalcelldata = cellentry;
    else
        totalcelldata(end+1,:) = cellentry;
    end
end