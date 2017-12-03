clear all;
numOfNeurons = 92;
shuffleSize = 30;
numOfShifts  = 100;
scailingFactor = 2;
sampleRate = 8;
secondsToRemove = 10;
numHDBins = 18;
numSpeedBins = 10;
numVelBins = 40;
maxSpeed = 25;

dt = 1/sampleRate;
threshold = 5;
speedScoresMatrix = zeros(numOfShifts, numOfNeurons);
velocityXScoresMatrix = zeros(numOfShifts, numOfNeurons);
velocityYScoresMatrix = zeros(numOfShifts, numOfNeurons);
borderScoresMatrix = zeros(numOfShifts, numOfNeurons);
classicBorderScoresMatrix = zeros(numOfShifts, numOfNeurons);
positionEncodingScoreMatrix = zeros(numOfShifts, numOfNeurons);
fastHeadDirectionScore = zeros(numOfShifts, numOfNeurons);
slowHeadDirectionScore = zeros(numOfShifts, numOfNeurons);

correlationBins = -1:0.01:1;
scoreBins = -0.5:0.01:1;
distanceBins = 0:0.01:10;

BIN = 1;
FilterSize=3; %in cm
FilterSize=FilterSize/2;
ind = -FilterSize/BIN : FilterSize/BIN; % 
[X Y] = meshgrid(ind, ind);
sigma=2.5; %in cm;
sigma=sigma/BIN;
%// Create Gaussian Mask
h = exp(-(X.^2 + Y.^2) / (2*sigma*sigma));
%// Normalize so that total area (sum of all weights) is 1
h = h / sum(h(:));

for i = 1:1
    i
    load(['./data/data_for_cell_' num2str(i)]);
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
    maxSpikes = max(spiketrain);
    spiikeTimes = find(spiketrain == 1);
    for j = 2:maxSpikes
        spiikeTimes = [spiikeTimes; repmat(find(spiketrain == j),j, 1)];
    end
    edges = 1:540:length(spiketrain) + 1;
   
    bins = discretize(spiikeTimes, edges);
    binArr  = 1:max(bins);
    figure('visible', 'off');
    hist(bins, binArr);
    xlabel('Time (minutes)');
    ylabel('# Spikes in minute');
    title({['Neuron: ' num2str(i)]; ['Spike count: ' num2str(sum(spiketrain))]});
    savefig(['./Results/Neuron_' num2str(i) '_firingRate']);

    startInd = max(1, spiikeTimes(1) - sampleRate * secondsToRemove);
    endInd = min(length(spiketrain), spiikeTimes(end) + sampleRate * secondsToRemove);
    spiketrain = spiketrain(startInd:endInd);
    posx = posx(startInd:endInd);
    posy = posy(startInd:endInd);
    headDirection = headDirection(startInd:endInd);
    
    
    spiikeTimes = find(spiketrain == 1);
    for j = 2:maxSpikes
        spiikeTimes = [spiikeTimes; repmat(find(spiketrain == j),j, 1)];
    end
    isi = diff(spiikeTimes);
    firstspikeInd = spiikeTimes(1);
    

    % Get scores for the original spike rate
    [speedScoresMatrix(1,i), speed] = getSpeedScore(posx, posy, spiketrain, 1/sampleRate);
    [borderScoresMatrix(1,i), dist(1,:), fr(1,:)] = getBorderScore(posx, posy, spiketrain, boxSize);
    classicBorderScoresMatrix(1,i) = getClassicBorderScore(spiketrain, posx, posy, boxSize);
    [positionEncodingScoreMatrix(1,i),odd_tuning_curve, even_tuning_curve] = getPositionScore(posx, posy, spiketrain,boxSize);
    [slowHeadDirectionScore(1,i), fastHeadDirectionScore(1,i)] =getHeadDirectionSpeedScore(posx, posy, headDirection, spiketrain, dt, threshold);

    [halfsScore, firstTuning_curve, secondTuning_curve] = getHalfsTuningCurves(posx, posy, spiketrain,boxSize);
    
    firstBorderScore = borderScoresMatrix(1,i);
    velocityXScoresMatrix(1,i) = getVelocityScore(posx,spiketrain);
    velocityYScoresMatrix(1,i) = getVelocityScore(posy,spiketrain);
   
    % Run number of shifts and get score for each shift
    for j = 2:numOfShifts
        % Get random shift
        permSpikeTimes = firstspikeInd + cumsum(isi(randperm(size(isi,1))));
        shiftSpikeTrain = double(ismember(1:length(spiketrain), permSpikeTimes))';
        % circ shift the spike train
        %shiftSpikeTrain = circshift(spiketrain, randShift);
        % Get scores
        speedScoresMatrix(j,i) = getSpeedScore(posx, posy, shiftSpikeTrain, 1/sampleRate);
        [borderScoresMatrix(j,i), dist(j,:), fr(j,:)] = getBorderScore(posx, posy, shiftSpikeTrain, boxSize);
        velocityXScoresMatrix(j,i) = getVelocityScore(posx,shiftSpikeTrain);
        velocityYScoresMatrix(j,i) = getVelocityScore(posy,shiftSpikeTrain);
        classicBorderScoresMatrix(j,i) = getClassicBorderScore(shiftSpikeTrain, posx, posy, boxSize);
        positionEncodingScoreMatrix(j,i) = getPositionScore(posx, posy,shiftSpikeTrain, boxSize);
        [slowHeadDirectionScore(j,i), fastHeadDirectionScore(j,i)] =getHeadDirectionSpeedScore(posx, posy, headDirection, shiftSpikeTrain, dt, threshold);

    end
    
    plotTuningCurves(i, posx, posy, spiketrain, headDirection, boxSize,...
        numHDBins, numSpeedBins, numVelBins,dt, threshold, shiftSpikeTrain)
    
    % calculate the 95 precetile of each test
    speedPrecetile = prctile(speedScoresMatrix(:,i), 95);
    border95Precetile = prctile(borderScoresMatrix(:,i), 95);
    border5Precetile = prctile(borderScoresMatrix(:,i), 5);
    velocityXPrecetile = prctile(velocityXScoresMatrix(:,i), 95);
    velocityYPrecetile = prctile(velocityYScoresMatrix(:,i), 95);
    positionEncodingPrecetile = prctile(positionEncodingScoreMatrix(:,i), 95);
    classicBorderPrecetile = prctile(classicBorderScoresMatrix(:,i), 95);
    slowHDPrecetile = prctile(slowHeadDirectionScore(:,i), 95);
    fastHDPrecetile = prctile(fastHeadDirectionScore(:,i), 95);
    
    fileName = ['Neuron-' num2str(i) '_classification'];
    plotDistanceFromBorderTest(borderScoresMatrix(:,i) , dist, fr, i, distanceBins, numOfShifts, border5Precetile)
    figure('Visible','Off');
    
   fileName = plotStatistics(speedScoresMatrix, correlationBins, numOfShifts, speedPrecetile,fileName, 'speed score = ', '_speed', i, 1);
   fileName = plotStatistics(classicBorderScoresMatrix, scoreBins, numOfShifts, classicBorderPrecetile,fileName, 'classic border score = ', '_classicBorder', i, 2);
   fileName = plotStatistics(velocityXScoresMatrix, correlationBins, numOfShifts, velocityXPrecetile,fileName, 'velocity x score = ', '_velocityX', i, 4);
   fileName = plotStatistics(velocityYScoresMatrix, correlationBins, numOfShifts, velocityYPrecetile,fileName, 'velocity y score = ', '_velocityY', i, 5);
   fileName = plotStatistics(positionEncodingScoreMatrix, correlationBins, numOfShifts, positionEncodingPrecetile,fileName, 'position score = ', '_position', i, 6);
   fileName = plotStatistics(fastHeadDirectionScore, correlationBins, numOfShifts, fastHDPrecetile,fileName, 'fast head direction score = ', '_fastHD', i, 7);
   fileName = plotStatistics(slowHeadDirectionScore, correlationBins, numOfShifts, slowHDPrecetile,fileName, 'slow head direction scor = ', '_slowHD', i, 8);
   
   
  
   % Border plot
    subplot(4,2,3);
    hold on;
    hist(borderScoresMatrix(:,i),distanceBins);
    xlim([min(borderScoresMatrix(:,i)) - 0.01 max(borderScoresMatrix(:,i)) + 0.01]);
    yt = get(gca, 'YTick');
    
    set(gca, 'YTick', yt, 'YTickLabel', yt/numOfShifts)
    title({['Neuron ' num2str(i) ]; ['Border score = ' num2str(borderScoresMatrix(1,i))]});

     pValBorder = 1 - (sum(borderScoresMatrix(:,i) > borderScoresMatrix(1,i)) /numOfShifts)  + 1/ numOfShifts;
     text(0.2,0.8,['P Value = ' num2str(pValBorder)], 'Units', 'normalized');
     hold off;
    hold on;
    if borderScoresMatrix(1,i) < border5Precetile && borderScoresMatrix(1,i) < 5
        plot(borderScoresMatrix(1,i),1,'r*', 'MarkerSize',12);
       fileName = [fileName '_Border'];
    else
        plot(borderScoresMatrix(1,i),1,'g*', 'MarkerSize',12);
    end
    savefig(['./Results/' fileName]);
    
    figure('visible', 'on');
    editedLabel = strrep(fileName, '_classification_', ' classification: ');
    editedLabel = strrep(editedLabel, '_', ', ');
    axis off;
    text(0.5,0.5,{[editedLabel];['Spike count: ' num2str(sum(spiketrain))]}, 'fontsize', 14);
    savefig(['./Results/Neuron-' num2str(i) '_label']);

end
