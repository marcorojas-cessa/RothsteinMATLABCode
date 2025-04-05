function [totalJaccard, mean_jaccard] = meanJaccardIndex(dataset1, dataset2)
    
    numCells1 = size(dataset1,1);
    numCells2 = size(dataset2,1);
    
    % Initialize variables
    comparisons = [];
    
    % Generate all possible comparisons between cells in dataset1 and dataset2
    for i = 1:numCells1
        cell1 = dataset1(i,:);
        for j = 1:numCells2
            cell2 = dataset2(j,:);
            % Calculate the Jaccard index for the pair (cell i from dataset1 and cell j from dataset2)
            jaccardIndex = jacCalc(cell1,cell2);
            comparisons = [comparisons; i, j, jaccardIndex];  % Store (i, j, jaccardIndex)
        end
    end
    
    % Sort the comparisons by Jaccard index in descending order
    comparisons = sortrows(comparisons, 3, 'descend');
    
    % Initialize matched cells tracking arrays
    matched_cells1 = false(1, numCells1);
    matched_cells2 = false(1, numCells2);
    
    totalJaccard = [];
    numComparisons = 0;
    
    % Greedily match the most similar cells
    for k = 1:size(comparisons, 1)
        i = comparisons(k, 1);  % Cell from dataset1
        j = comparisons(k, 2);  % Cell from dataset2
        
        % If neither cell has been matched yet
        if ~matched_cells1(i) && ~matched_cells2(j)
            % Add the Jaccard index to the total
            totalJaccard = [totalJaccard,comparisons(k, 3)];
            numComparisons = numComparisons + 1;
            
            % Mark both cells as matched
            matched_cells1(i) = true;
            matched_cells2(j) = true;
        end
    end
    
    % Handle unmatched cells in the longer dataset
    if numCells1 > numCells2
        % dataset1 is longer, so handle the unmatched cells in dataset1
        for i = 1:numCells1
            if ~matched_cells1(i)
                totalJaccard = [totalJaccard, 0];  % Jaccard index for unmatched cell in dataset1
                numComparisons = numComparisons + 1;
            end
        end
    elseif numCells2 > numCells1
        % dataset2 is longer, so handle the unmatched cells in dataset2
        for j = 1:numCells2
            if ~matched_cells2(j)
                totalJaccard = [totalJaccard,0];  % Jaccard index for unmatched cell in dataset2
                numComparisons = numComparisons + 1;
            end
        end
    end
    
    % Compute the mean Jaccard index
    if numComparisons > 0
        mean_jaccard = sum(totalJaccard) / numComparisons;
    else
        mean_jaccard = 0;
    end
end