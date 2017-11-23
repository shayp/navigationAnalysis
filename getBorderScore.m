function [selctedDistance, dist, fr] = getBorderScore(posx, posy, spiketrain, boxSize)
edgePosx = boxSize(1) - posx;
edgePosy = boxSize(2) - posy;
distance = linspace(0.5, 6, 12);
selctedDistance = 6;
dist = [];
fr = [];
for i = 1:12
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
    if borderSpikeCount > 0.75 *  TotalSpikeCount
        selctedDistance = distance(i);
        return
    end
end


end