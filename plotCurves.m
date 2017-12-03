numOfNeurons = 92;
dt = 1/8;
threshold = 15;
numHDBins = 8;
numSpeedBins = 10;
numVelBins = 100;
maxSpeed = 25;

for i = 1:numOfNeurons
    i
    load(['data_for_cell_' num2str(i)]);
    % remove nan indicies
    nanInd = find(isnan(spiketrain));
    nanInd = [nanInd;  find(isnan(posx))];
    nanInd = [nanInd;  find(isnan(posy))];
    nanInd = [nanInd;  find(isnan(headDirection))];

    spiketrain(nanInd) = [];
    posx(nanInd) = [];
    posy(nanInd) = [];
    headDirection(nanInd) = [];
    headDirection  = headDirection + pi;
    plotTuningCurves(i, posx, posy, spiketrain, headDirection, boxSize,...
        numHDBins, numSpeedBins, numVelBins,maxSpeed, dt, threshold)
end