%Developed by Pablo Vicente-Munuera

function [ ] = createNetworkHexagonalGridSharedSide()
    [stat,struc] = fileattrib;
    PathCurrent = struc.Name;
    lee_imagenes = dir(PathCurrent);
    lee_imagenes = lee_imagenes(3:size(lee_imagenes,1))
    for imK = 1:size(lee_imagenes,1)
        if (lee_imagenes(imK).isdir == 0 && (size(strfind(lee_imagenes(imK).name, 'COL'),1) == 1 || size(strfind(lee_imagenes(imK).name, 'CD31'),1) == 1 || size(strfind(lee_imagenes(imK).name, 'RET'),1) == 1 || size(strfind(lee_imagenes(imK).name, 'GAG'),1) == 1))
            lee_imagenes(imK).name
            Img=imread(lee_imagenes(imK).name);
            Img = im2bw(Img, 0.2);
            for numMask = 2:50
                inNameFile = strsplit(strrep(lee_imagenes(imK).name,' ','_'), '.');
                outputFileName = strcat('Adjacency\adjacencyMatrix', inNameFile(1), 'hexagonalSharedSideMask', num2str(numMask),'Diamet.mat')
				outputFileNameSif = strcat('visualize\adjacencyMatrix', inNameFile(1), 'hexagonalSharedSideMask', num2str(numMask),'Diamet.cvs');
                outputFileNameSifComplete = strcat('visualize\adjacencyMatrixComplete', inNameFile(1), 'hexagonalSharedSideMask', num2str(numMask),'Diamet.cvs');
                if exist(outputFileName{:}, 'file') ~= 2
                    maskName = strcat('..\..\..\..\..\Mascaras\HexagonalMask', num2str(numMask), 'Diamet.mat');
                    mask = importdata(maskName);
                    mask = mask(1:size(Img, 1), 1:size(Img,2));
                    
                    maxHexagons = size(unique(mask(mask>0)),1);

                    v1 = [];
                    v2 = [];

                    for i = 2:size(Img,1)
                        for j = 2:size(Img,2)
                            if (mask(i,j) ==  0 && Img(i,j) ~= 0) %If trasspass the boundary we put an edge
                                %Add to verteces list
                                [vSides] = connectedHexagons(mask, i, j);
                                %%Add it to the vertex list
                                v1 = [v1;vSides(1)];
                                v2 = [v2;vSides(2)];
                                if(size(vSides) == 3)
                                    v1 = [v1;vSides(1)];
                                    v2 = [v2;vSides(3)];
                                    v1 = [v1;vSides(2)];
                                    v2 = [v2;vSides(3)];
                                end
                            end
                        end
                    end

                    classes = unique([v1,v2]); 
                    %Creating the Incidence matrix
                    adjacencyMatrix = sparse(size(classes,1), size(classes,1));
                    %GetThe
%                     v1Concatv2 = strcat(num2str(v1), num2str(v2));
%                     [uniques,numUnique] = count_unique(v1Concatv2);
%                     maxSidesTime = max(numUnique)
                    for i = 1:size(v1,1)
                        v1Index = find(classes == v1(i));
                        v2Index = find(classes == v2(i));
                        adjacencyMatrix(v1Index, v2Index) = adjacencyMatrix(v1Index, v2Index) + 1;
                        adjacencyMatrix(v2Index, v1Index) = adjacencyMatrix(v2Index, v1Index) + 1;
                    end

                    adjacencyMatrix = adjacencyMatrix / max(adjacencyMatrix(:));
                    
                    %clear v1 v2 classesArea mask
                    %classesStr = num2str(classes);
                    %file:///C:/Program%20Files/MATLAB/R2014b/help/bioinfo/ref/biograph.html
                    %bg = biograph(adjacencyMatrix, num2str(classes),'ShowArrows','off','ShowWeights','off');
                    [S, C] = graphconncomp(adjacencyMatrix, 'Directed', false);

                    [vCentroidsRows, vCentroidsCols] = GetCentroidOfCluster(mask, C, S);

                    distanceBetweenClusters = pdist([vCentroidsRows', vCentroidsCols'], 'euclidean');

                    
                    adjacencyMatrixComplete = GetConnectedGraphWithMinimumDistances(distanceBetweenClusters ,adjacencyMatrix, C);



                    save(outputFileName{:}, 'adjacencyMatrix', 'adjacencyMatrixComplete', '-v7.3');
                    generateSIFFromAdjacencyMatrix(adjacencyMatrixComplete, outputFileNameSif{:});
					generateSIFFromAdjacencyMatrix(adjacencyMatrix, outputFileNameSif{:});
                    
                    fileID = fopen('percentageOfHexagonsOccupied.txt','a');
                    fprintf(fileID,'Percentage of Hexagons occupied:%d of %d on file %s\n', 'size(classes, 1)', 'maxHexagons', 'outputFileName{:}');
                    fclose(fileID);
				elseif exist(outputFileNameSifComplete{:}, 'file') ~= 2
					load(outputFileName{:},'-mat')
					generateSIFFromAdjacencyMatrix(adjacencyMatrixComplete, outputFileNameSifComplete{:});
					generateSIFFromAdjacencyMatrix(adjacencyMatrix, outputFileNameSif{:});
                end
            end
        end
    end
end
