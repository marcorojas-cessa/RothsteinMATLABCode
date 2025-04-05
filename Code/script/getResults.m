%{
Marco Rojas-Cessa
Rothstein Lab
Columbia University

getResults.m script
%}

classi={};
classii={};
classiii={};
classiv={};
other={};
for i=1:size(Ztotalcelldata,1)
    %if cell has 1 R, 2 Y, and 1 B
    if string(Ztotalcelldata(i,1)) == "RYYB"
        ry = cell2mat(Ztotalcelldata(i,11));
        rb = cell2mat(Ztotalcelldata(i,12));
        yb = cell2mat(Ztotalcelldata(i,13));
        ry1 = ry(1);
        ry2 = ry(2);
        yb1 = yb(1);
        yb2 = yb(2);
        %if the yellows are each closer to a red/blue than the other
        if ry1 < ry2 && yb2 < yb1
            rydis = ry1;
            rbdis = rb;
            ybdis = yb2;
            data = Ztotalcelldata(i,1:10);
            data(end+1:end+3) = {rydis, rbdis, ybdis};

            %after passing these criteria, the cell is grouped into classi
            %category

            if isempty(classi)
                classi = data;
            else
                classi(end+1,:) = data;
            end
        elseif ry2 < ry1 && yb1 < yb2
            rydis = ry2;
            rbdis = rb;
            ybdis = yb1;
            data = Ztotalcelldata(i,1:10);
            data(end+1:end+3) = {rydis, rbdis, ybdis};
            if isempty(classi)
                classi = data;
            else
                classi(end+1,:) = data;
            end
        else
            if isempty(other)
                other = Ztotalcelldata(i,1:13);
            else
                other(end+1,:) = Ztotalcelldata(i,1:13);
            end
        end
        %if cell has 1 R and 1 B
    elseif string(Ztotalcelldata(i,1)) == "RB"
        %group into class ii data
        if isempty(classii)
            classii = Ztotalcelldata(i,1:13);
        else
            classii(end+1,:) = Ztotalcelldata(i,1:13);
        end
    %if cell has 1 R, 1 Y, and 1 B
    elseif string(Ztotalcelldata(i,1)) == "RYB"
        ry = cell2mat(Ztotalcelldata(i,11));
        rb = cell2mat(Ztotalcelldata(i,12));
        yb = cell2mat(Ztotalcelldata(i,13));
        dis = [ry,rb,yb];
        %if RY distance is the smallest, classify as class iii
        if min(dis) == ry
            if isempty(classiii)
                classiii = Ztotalcelldata(i,1:13);
            else
                classiii(end+1,:) = Ztotalcelldata(i,1:13);
            end
        %if YB distance is the smallest, classify as class iv
        elseif min(dis) == yb
            if isempty(classiv)
                classiv = Ztotalcelldata(i,1:13);
            else
                classiv(end+1,:) = Ztotalcelldata(i,1:13);
            end
        %if not these cases, put into other category for now
        else
            if isempty(other)
                other = Ztotalcelldata(i,1:13);
            else
                other(end+1,:) = Ztotalcelldata(i,1:13);
            end
        end
    %all other cases go into other category
    else
        if isempty(other)
            other = Ztotalcelldata(i,1:13);
        else
            other(end+1,:) = Ztotalcelldata(i,1:13);
        end
    end
end

%plotting preliminary results
if ~isempty(classi)
    edges=0:250:3000;
    subplot(2,3,1)
    histogram(cell2mat(classi(:,11)),edges);
    ylabel('freq');
    xlabel('RY distance (nm)');

    subplot(2,3,2)
    histogram(cell2mat(classi(:,12)),edges);
    hold on
    histogram(cell2mat(classi(:,9)),edges);
    xlabel("RB and YY distance (nm)");
    legend("RB","YY");
    title('class i');
    hold off

    subplot(2,3,3)
    histogram(cell2mat(classi(:,13)),edges);
    xlabel('YB distance (nm)');

    subplot(2,3,4)
    edges=0:1250:25000;
    histogram(cell2mat(classi(:,5)),edges);
    ylabel('freq');
    xlabel('R intensity');

    subplot(2,3,5)
    edges = 0:2500:45000;
    histogram(cell2mat(classi(:,6)),edges);
    xlabel('Y intensity');

    subplot(2,3,6)
    edges=0:5000;100000;
    histogram(cell2mat(classi(:,7)),edges);
    xlabel('B intensity');

end
figure;
%class ii

if ~isempty(classii)
    edges=0:250:3000;
    subplot(2,3,1)
    histogram(cell2mat(classii(:,11)),edges);
    ylabel('freq');
    xlabel('RY distance (nm)');

    subplot(2,3,2)
    histogram(cell2mat(classii(:,12)),edges);
    xlabel("RB distance (nm)");
    title('class ii');

    subplot(2,3,3)
    histogram(cell2mat(classii(:,13)),edges);
    xlabel('YB distance (nm)');

    subplot(2,3,4)
    edges=0:2500:25000;
    histogram(cell2mat(classii(:,5)),edges);
    ylabel('freq');
    xlabel('R intensity');

    subplot(2,3,5)
    edges = 0:4500:45000;
    histogram(cell2mat(classii(:,6)),edges);
    xlabel('Y intensity');

    subplot(2,3,6)
    histogram(cell2mat(classii(:,7)),'NumBins',10);
    xlim([0 100000]);
    xlabel('B intensity');

end
%class iii

figure;
if ~isempty(classiii)
    edges=0:250:3000;
    subplot(2,3,1)
    histogram(cell2mat(classiii(:,11)),edges);
    ylabel('freq');
    xlabel('RY distance (nm)');

    subplot(2,3,2)
    histogram(cell2mat(classiii(:,12)),edges);
    xlabel("RB distance (nm)");
    title('class iii');

    subplot(2,3,3)
    histogram(cell2mat(classiii(:,13)),edges);
    xlabel('YB distance (nm)');

    subplot(2,3,4)
    edges=0:2500:25000;
    histogram(cell2mat(classiii(:,5)),edges);
    ylabel('freq');
    xlabel('R intensity');

    subplot(2,3,5)
    edges = 0:4500:45000;
    histogram(cell2mat(classiii(:,6)),edges);
    xlabel('Y intensity');

    subplot(2,3,6)
    histogram(cell2mat(classiii(:,7)),'NumBins',10);
    xlim([0 100000]);
    xlabel('B intensity');

end

figure;
%class iv

if ~isempty(classiv)
    edges=0:250:3000;
    subplot(2,3,1)
    histogram(cell2mat(classiv(:,11)),edges);
    ylabel('freq');
    xlabel('RY distance (nm)');

    subplot(2,3,2)
    histogram(cell2mat(classiv(:,12)),edges);
    xlabel("RB distance (nm)");
    title('class iv');

    subplot(2,3,3)
    histogram(cell2mat(classiv(:,13)),edges);
    xlabel('YB distance (nm)');

    subplot(2,3,4)
    edges=0:2500:25000;
    histogram(cell2mat(classiv(:,5)),edges);
    ylabel('freq');
    xlabel('R intensity');

    subplot(2,3,5)
    edges = 0:4500:45000;
    histogram(cell2mat(classiv(:,6)),edges);
    xlabel('Y intensity');

    subplot(2,3,6)
    histogram(cell2mat(classiv(:,7)),'NumBins',10);
    xlim([0 100000]);
    xlabel('B intensity');
end
