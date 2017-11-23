function [positionScore, odd_tuning_curve, even_tuning_curve] = getPositionScore(posx, posy, spiketrain,boxSize)
xLen = boxSize(1);
yLen = boxSize(2);
numOfBinsInMinute = 8 * 60;

expLength = length(posx);
numOfSessions = 1:floor(expLength / numOfBinsInMinute);
evenInd = find(mod(numOfSessions, 2));
oddInd = setdiff(1:numel(numOfSessions),evenInd);
oddPosx = [];
oddSpikTrain = [];
oddPosy = [];
for i = 1:length(oddInd)
    nextMove = min(expLength, oddInd(i) * numOfBinsInMinute + numOfBinsInMinute);
    oddSpikTrain = [oddSpikTrain spiketrain(oddInd(i) * numOfBinsInMinute: nextMove)'];
    oddPosx = [oddPosx posx(oddInd(i) * numOfBinsInMinute: nextMove)'];
    oddPosy = [oddPosy posy(oddInd(i) * numOfBinsInMinute: nextMove)'];
    odd_tuning_curve = crreateTuningCurve2D(xLen, yLen, oddPosx, oddPosy, oddSpikTrain);
end
evenPosx = [];
evenSpikTrain = [];
evenPosy = [];
for i = 1:length(evenInd)
    nextMove = min(expLength, evenInd(i) * numOfBinsInMinute + numOfBinsInMinute);
    evenSpikTrain = [evenSpikTrain spiketrain(evenInd(i) * numOfBinsInMinute: nextMove)'];
    evenPosx = [evenPosx posx(evenInd(i) * numOfBinsInMinute: nextMove)'];
    evenPosy = [evenPosy posy(evenInd(i) * numOfBinsInMinute: nextMove)'];
    even_tuning_curve = crreateTuningCurve2D(xLen, yLen, evenPosx, evenPosy, evenSpikTrain);
end

positionScore = corr2(even_tuning_curve,odd_tuning_curve);
end