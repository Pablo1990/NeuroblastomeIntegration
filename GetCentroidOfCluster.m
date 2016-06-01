function [ vCentroidsRows, vCentroidsCols ] = GetCentroidOfCluster(mask, C, S)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    vCentroidsRows = zeros(S);
    vCentroidsCols = zeros(S);
    %parpool(4);
    parfor i = 1:S
       indexesOfClusters = find(C==i);
       rows = [];
       cols = [];
       for index = indexesOfClusters
           [row,col] = find(mask == index);
           rows = [rows; row];
           cols = [cols; col];
       end
       vCentroidsRows = [vCentroidsRows; mean(rows)];
       vCentroidsCols = [vCentroidsCols; mean(col)];
    end
end
