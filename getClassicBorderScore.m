function result = getClassicBorderScore(spiketrain, posx, posy, boxSize)
%% //Gauusian Filter
BIN = 1;
FilterSize=20; %in cm
FilterSize=FilterSize/2;
ind = -FilterSize/BIN : FilterSize/BIN; % 
[X Y] = meshgrid(ind, ind);
sigma=5; %in cm;
sigma=sigma/BIN;
%// Create Gaussian Mask
h = exp(-(X.^2 + Y.^2) / (2*sigma*sigma));

%// Normalize so that total area (sum of all weights) is 1
h = h / sum(h(:));

xEdges=0:1:boxSize(1);
yEdges=0:1:boxSize(2);
spikeIndexes = find(spiketrain);
[timeSpent,~,~] = histcounts2(posx,posy,xEdges,yEdges);
[spikeCount,~,~] = histcounts2(posx(spikeIndexes), posy(spikeIndexes), xEdges, yEdges);


%%
smoothedSpikes=filter2(h,spikeCount);
smoothedTimeSpent=filter2(h,timeSpent);
smoothedFiringRate=smoothedSpikes./smoothedTimeSpent;
smoothedFiringRate(isnan(smoothedFiringRate))=0;

% Build binary firing rate
binaryFiringRate=smoothedFiringRate;
binaryFiringRate(binaryFiringRate<(prctile(binaryFiringRate(:),75)))=0;
binaryFiringRate(binaryFiringRate>0)=1;

[labeledImage, numOfObjects] = bwlabel(binaryFiringRate);

centerOfMass = regionprops(labeledImage, 'Centroid');
BoundingBox = regionprops(labeledImage,'BoundingBox');

sumFromCentroid = 0;
lengthOfEdges = 0;
for i = 1:numOfObjects
    x1 = BoundingBox(i).BoundingBox(2);
    y1 = BoundingBox(i).BoundingBox(1);
    x2 = min(BoundingBox(i).BoundingBox(4) + x1, boxSize(1));
    y2 = min(BoundingBox(i).BoundingBox(3) + y1, boxSize(2));

    isXCloseToWall =  x1 < 2 |  boxSize(1) - x2 < 2;
    isYCloseToWall =  y1 < 2 |  boxSize(2) - y2 < 2;
    
    if isXCloseToWall
        sumFromCentroid = sumFromCentroid + min(centerOfMass(i).Centroid(2), boxSize(1) - centerOfMass(i).Centroid(2));
        lengthOfEdges = lengthOfEdges + y2 - y1;
    elseif isYCloseToWall
        lengthOfEdges = lengthOfEdges + x2 - x1;
        sumFromCentroid = sumFromCentroid + min(centerOfMass(i).Centroid(1), boxSize(2) - centerOfMass(i).Centroid(1));
    else
        sumFromCentroid = sumFromCentroid + min([centerOfMass(i).Centroid(1)...
            boxSize(2) - centerOfMass(i).Centroid(1) centerOfMass(i).Centroid(2) ...
            boxSize(1) - centerOfMass(i).Centroid(2)]);
    end    
end
result =  (lengthOfEdges - sumFromCentroid)/ (sumFromCentroid + lengthOfEdges);
% figure();
% subplot(1,2,1);
% imagesc(xEdges,yEdges,smoothedFiringRate');
% axis equal
% colormap jet
% hold off;
% ylim([0 boxSize(2)]);
% xlim([0 boxSize(1)]);
% set(gca,'Ytick',[0 boxSize(2)]);
% xlabel('Aquarium Length [cm]');
% ylabel('Aquarium Width [cm]');
% Ax(1)=gca;
% set(Ax(1),'LineWidth',1,'FontWeight','Bold',...
%     'FontName','Helvetica','FontSize',8,'Box','off',...
%     'TickDir','out','TickLength',[.025 .025],'Layer','top');
% set(gca,'Ydir','normal');
% subplot(1,2,2);
% imagesc(binaryFiringRate')
% axis equal
% colormap jet
% hold off;
% ylim([0 boxSize(2)]);
% xlim([0 boxSize(1)]);
% set(gca,'Ytick',[0 20]);
% drawnow;
end