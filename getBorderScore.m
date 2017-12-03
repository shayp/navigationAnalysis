function [selctedDistance, dist, fr] = getBorderScore(posx, posy, spiketrain, boxSize)
edgePosx = boxSize(1) - posx;
edgePosy = boxSize(2) - posy;
distance = 0.1:0.1:10;
selctedDistance = 6;
fIsDistanceSet = 0;
dist = [];
fr = [];
for i = 1:length(distance)
    borderInd = find(posx < distance(i) | posy < distance(i) | edgePosx < distance(i) | edgePosy < distance(i));
    borderInd = unique(borderInd);
    nonBorderInd = setdiff(1: numel(posx),borderInd);
    borderSpikeCount = sum(spiketrain(borderInd));
    nonBorderSpikeCount = sum(spiketrain(nonBorderInd));

    borderTimeSpent = numel(borderInd);
    nonBorderTimeSpent = numel(nonBorderInd);

    borderFR = borderSpikeCount / borderTimeSpent;
    nonBorderFR = nonBorderSpikeCount / nonBorderTimeSpent;
    TotalSpikeCount = sum(spiketrain);
    borderFiringRatio = borderSpikeCount / TotalSpikeCount;

    dist = [dist distance(i)];
    fr = [fr borderFiringRatio];
    if borderSpikeCount > 0.75 *  TotalSpikeCount && fIsDistanceSet == 0
        selctedDistance = distance(i);
        fIsDistanceSet =  1;
    end
end


end