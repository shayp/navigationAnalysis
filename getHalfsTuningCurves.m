function [halfsScore, firstTuning_curve, secondTuning_curve] = getHalfsTuningCurves(posx, posy, spiketrain,boxSize)
xLen = boxSize(1);
yLen = boxSize(2);
numOfBinsInMinute = 8 * 60;

expLength = length(posx);
firstHalfLength = ceil(expLength / 2);
firstPosX = posx(1:firstHalfLength);
firstPosY = posy(1:firstHalfLength);
firstSpikeTrain = spiketrain(1:firstHalfLength);
firstTuning_curve = crreateTuningCurve2D(xLen, yLen, firstPosX, firstPosY, firstSpikeTrain);

secondPosX = posx(firstHalfLength + 1:end);
secondPosY = posy(firstHalfLength + 1:end);
secondSpikeTrain = spiketrain(firstHalfLength + 1:end);
secondTuning_curve = crreateTuningCurve2D(xLen, yLen, secondPosX, secondPosY, secondSpikeTrain);

halfsScore = corr2(firstTuning_curve, secondTuning_curve);
end