numOfNeurons = 92;
shuffleSize = 30;
numOfShifts  = 5000;
scailingFactor = 2;
speedScoresMatrix = zeros(numOfShifts, numOfNeurons);
velocityXScoresMatrix = zeros(numOfShifts, numOfNeurons);
velocityYScoresMatrix = zeros(numOfShifts, numOfNeurons);
borderScoresMatrix = zeros(numOfShifts, numOfNeurons);
classicBorderScoresMatrix = zeros(numOfShifts, numOfNeurons);
positionEncodingScoreMatrix = zeros(numOfShifts, numOfNeurons);
positionCells = [20 25 28 40 47 49 66 73 79 92];
correlationBins = -1:0.01:1;
scoreBins = -0.5:0.01:1;
distanceBins = 0:0.01:10;
% BIN = 1;
% FilterSize=3; %in cm
% FilterSize=FilterSize/2;
% ind = -FilterSize/BIN : FilterSize/BIN; % 
% [X Y] = meshgrid(ind, ind);
% sigma=2.5; %in cm;
% sigma=sigma/BIN;
% %// Create Gaussian Mask
% h = exp(-(X.^2 + Y.^2) / (2*sigma*sigma));

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

for i = 1:92
    i
    load(['data_for_cell_' num2str(i)]);
    % remove nan indicies
    nanInd = find(isnan(spiketrain));
    nanInd = [nanInd  find(isnan(posx))];
    nanInd = [nanInd  find(isnan(posy))];
    spiketrain(nanInd) = [];
    posx(nanInd) = [];
    posy(nanInd) = [];
    
    spiikeTimes= find(spiketrain);
    isi = diff(spiikeTimes);
    firstspikeInd = spiikeTimes(1);
    % Get scores for the original spike rate
    [speedScoresMatrix(1,i), speed] = getSpeedScore(posx, posy, spiketrain, 1/sampleRate);
    [borderScoresMatrix(1,i), dist, fr] = getBorderScore(posx, posy, spiketrain, boxSize);
    classicBorderScoresMatrix(1,i) = getClassicBorderScore(spiketrain, posx, posy, boxSize);
    [positionEncodingScoreMatrix(1,i),odd_tuning_curve, even_tuning_curve] = getPositionScore(posx, posy, spiketrain,boxSize);
    [halfsScore, firstTuning_curve, secondTuning_curve] = getHalfsTuningCurves(posx, posy, spiketrain,boxSize);
%     figure();
%     subplot(4,1,1)
%     odd_tuning_curve = filter2(h,odd_tuning_curve);
%     imagesc([0 boxSize(1)] , [0 boxSize(2)], odd_tuning_curve);
%     title(['Neuron - ' num2str(i) ', Position tuning curve - Odd minutes']);
%     colorbar;
%     colormap jet;
% 
%     xlabel('Aquarium Length [cm]');
%     ylabel('Aquarium Width [cm]');
%     subplot(4,1,2)
%     even_tuning_curve = filter2(h,even_tuning_curve);
%     imagesc([0 boxSize(1)] , [0 boxSize(2)], even_tuning_curve);
%     colorbar;
%     colormap jet;
%     xlabel('Aquarium Length [cm]');
%     ylabel('Aquarium Width [cm]');
%     title(['Neuron - ' num2str(i) ', Position tuning curve - Even minutes']);
%     
%     subplot(4,1,3)
%     firstTuning_curve = filter2(h,firstTuning_curve);
%     imagesc([0 boxSize(1)] , [0 boxSize(2)], firstTuning_curve);
%     colorbar;
%     colormap jet;
%     xlabel('Aquarium Length [cm]');
%     ylabel('Aquarium Width [cm]');
%     title(['Neuron - ' num2str(i) ', Position tuning curve - First half']);
%     
%     subplot(4,1,4)
%     secondTuning_curve = filter2(h,secondTuning_curve);
%     imagesc([0 boxSize(1)] , [0 boxSize(2)], secondTuning_curve);
%     colorbar;
%     colormap jet;
%     xlabel('Aquarium Length [cm]');
%     ylabel('Aquarium Width [cm]');
%     title(['Neuron - ' num2str(i) ', Position tuning curve - second half']);
%     
%     savefig(['./Results/Neuron_' num2str(i) '_PositionCurve']);
    
    firstBorderScore = borderScoresMatrix(1,i);
    velocityXScoresMatrix(1,i) = getVelocityScore(posx,spiketrain);
    velocityYScoresMatrix(1,i) = getVelocityScore(posy,spiketrain);
    
    % calculate the max shift(length of experiment minus one second)
    maxShift = length(spiketrain) - (1/sampleRate) * shuffleSize;
    
    % Run number of shifts and get score for each shift
    for j = 2:numOfShifts
        % Get random shift
        randShift = randi(maxShift) + (1/sampleRate) * shuffleSize;
        permSpikeTimes = firstspikeInd + cumsum(isi(randperm(size(isi,1))));
        shiftSpikeTrain = double(ismember(1:length(spiketrain), permSpikeTimes))';
        % circ shift the spike train
        %shiftSpikeTrain = circshift(spiketrain, randShift);
        % Get scores
        speedScoresMatrix(j,i) = getSpeedScore(posx, posy, shiftSpikeTrain, 1/sampleRate);
        [borderScoresMatrix(j,i), dist, fr] = getBorderScore(posx, posy, shiftSpikeTrain, boxSize);
        velocityXScoresMatrix(j,i) = getVelocityScore(posx,shiftSpikeTrain);
        velocityYScoresMatrix(j,i) = getVelocityScore(posy,shiftSpikeTrain);
        classicBorderScoresMatrix(j,i) = getClassicBorderScore(shiftSpikeTrain, posx, posy, boxSize);
        positionEncodingScoreMatrix(j,i) = getPositionScore(posx, posy,shiftSpikeTrain, boxSize);
    end

    % calculate the 95 precetile of each test
    speedPrecetile = prctile(speedScoresMatrix(:,i), 95);
    border95Precetile = prctile(borderScoresMatrix(:,i), 95);
    border5Precetile = prctile(borderScoresMatrix(:,i), 5);
    velocityXPrecetile = prctile(velocityXScoresMatrix(:,i), 95);
    velocityYPrecetile = prctile(velocityYScoresMatrix(:,i), 95);
    positionEncodingPrecetile = prctile(positionEncodingScoreMatrix(:,i), 95);
    classicBorderPrecetile = prctile(classicBorderScoresMatrix(:,i), 95);
    
    fileName = ['Neuron_' num2str(i) '_classification'];
    
    figure();
    
    % Speed plot
    subplot(3,2,1);
    hold on;
    hist(speedScoresMatrix(:,i),correlationBins);
    xlim([min(speedScoresMatrix(:,i)) - 0.01 max(speedScoresMatrix(:,i)) + 0.01]);
    yt = get(gca, 'YTick');
    maxY = max(yt / numOfShifts);
    set(gca, 'YTick', yt, 'YTickLabel', yt/numOfShifts)

    title({['Neuron ' num2str(i)]; [' Speed score = ' num2str(speedScoresMatrix(1,i), 2)]});
    x = [speedScoresMatrix(1,i) speedScoresMatrix(1,i)];
    y = [maxY 0];
    pValSpeed = sum(speedScoresMatrix(:,i) > speedScoresMatrix(1,i)) /numOfShifts + 1 / numOfShifts ;
    text(0.8,0.8,['P Value = ' num2str(pValSpeed)], 'Units', 'normalized');
    hold off;
    hold on;
    if speedScoresMatrix(1,i) > speedPrecetile
        plot(speedScoresMatrix(1,i),1,'r*', 'MarkerSize',12);
        fileName = [fileName '_speed'];
    else
        plot(speedScoresMatrix(1,i),1,'g*', 'MarkerSize',12);
    end
    hold off;
    
    % Border plot
    subplot(3,2,2);
    hist(borderScoresMatrix(:,i),distanceBins);
    xlim([min(borderScoresMatrix(:,i)) - 0.01 max(borderScoresMatrix(:,i)) + 0.01]);
    yt = get(gca, 'YTick');
    maxY = max(yt / numOfShifts);
    
    set(gca, 'YTick', yt, 'YTickLabel', yt/numOfShifts)
    title({['Neuron ' num2str(i) ]; ['Border score = ' num2str(borderScoresMatrix(1,i))]});
     x = [borderScoresMatrix(1,i) borderScoresMatrix(1,i)];
     y = [maxY 0];
     pValBorder = 1 - (sum(borderScoresMatrix(:,i) > borderScoresMatrix(1,i)) /numOfShifts)  + 1/ numOfShifts;
     text(0.2,0.8,['P Value = ' num2str(pValBorder)], 'Units', 'normalized');
    hold on;
    if borderScoresMatrix(1,i) < border5Precetile && borderScoresMatrix(1,i) < 5
        plot(borderScoresMatrix(1,i),1,'r*', 'MarkerSize',12);
       fileName = [fileName '_Border'];
    else
        plot(borderScoresMatrix(1,i),1,'g*', 'MarkerSize',12);
    end


    % border score plot
    subplot(3,2,3);
    hist(classicBorderScoresMatrix(:,i),scoreBins);
    xlim([min(classicBorderScoresMatrix(:,i)) - 0.01 max(classicBorderScoresMatrix(:,i)) + 0.01]);
    yt = get(gca, 'YTick');
    maxY = max(yt / numOfShifts);
    set(gca, 'YTick', yt, 'YTickLabel', yt/numOfShifts)
    
    title({['Neuron ' num2str(i) ]; ['Classic border score = ' num2str(classicBorderScoresMatrix(1,i))]});
    x = [classicBorderScoresMatrix(1,i) classicBorderScoresMatrix(1,i)];
    y = [maxY 0];
    pValClassicBorder = sum(classicBorderScoresMatrix(:,i) > classicBorderScoresMatrix(1,i)) /numOfShifts  + 1 / numOfShifts;
    text(0.8,0.8,['P Value = ' num2str(pValClassicBorder)], 'Units', 'normalized');
        hold on;
    min(classicBorderScoresMatrix(:,i))
    if classicBorderScoresMatrix(1,i) > classicBorderPrecetile
        plot(classicBorderScoresMatrix(1,i),1,'r*', 'MarkerSize',12);
        
        fileName = [fileName '_classicBorder'];
    else
        plot(classicBorderScoresMatrix(1,i),1, 'g*', 'MarkerSize',12);
    end
    
    hold on;
    line(x,y, 'Color','black','LineWidth',2);
    hold off;
    
    % velocity x
    subplot(3,2,4);
    hist(velocityXScoresMatrix(:,i),correlationBins);
    xlim([min(velocityXScoresMatrix(:,i)) - 0.01 max(velocityXScoresMatrix(:,i)) + 0.01]);
    yt = get(gca, 'YTick');
    maxY = max(yt / numOfShifts);
    set(gca, 'YTick', yt, 'YTickLabel', yt/numOfShifts)
    x = [velocityXScoresMatrix(1,i) velocityXScoresMatrix(1,i)];
    y = [maxY 0];
    pValVelocityX = sum(velocityXScoresMatrix(:,i) > velocityXScoresMatrix(1,i)) /numOfShifts  + 1 / numOfShifts ;
    text(0.8,0.8,['P Value = ' num2str(pValVelocityX)], 'Units', 'normalized');
    title({['Neuron ' num2str(i) ]; ['Velocity X score = ' num2str(velocityXScoresMatrix(1,i))]});
    hold on;

    if velocityXScoresMatrix(1,i) > velocityXPrecetile
        plot(velocityXScoresMatrix(1,i),1,'r*', 'MarkerSize',12);
        fileName = [fileName '_velocity_x'];  
    else
        plot(velocityXScoresMatrix(1,i),1,'g*', 'MarkerSize',12);
    end
    

    
    % Velocity Y
    subplot(3,2,5);
    hist(velocityYScoresMatrix(:,i),correlationBins);
    xlim([min(velocityYScoresMatrix(:,i)) - 0.01 max(velocityYScoresMatrix(:,i)) + 0.01]);
    yt = get(gca, 'YTick');
    maxY = max(yt / numOfShifts);
    set(gca, 'YTick', yt, 'YTickLabel', yt/numOfShifts)
    x = [velocityYScoresMatrix(1,i) velocityYScoresMatrix(1,i)];
    y = [maxY 0];
    pValVelocityY = sum(velocityYScoresMatrix(:,i) > velocityYScoresMatrix(1,i)) /numOfShifts  + 1 / numOfShifts;
    text(0.8,0.8,['P Value = ' num2str(pValVelocityY)], 'Units', 'normalized');
    title({['Neuron ' num2str(i)]; ['Velocity Y score = ' num2str(velocityYScoresMatrix(1,i),2)]});
    hold on;
    if velocityYScoresMatrix(1,i) > velocityYPrecetile
        plot(velocityYScoresMatrix(1,i),1,'r*', 'MarkerSize',12);
       fileName = [fileName '_velocity_y'];  
    else
	plot(velocityYScoresMatrix(1,i),1,'g*', 'MarkerSize',12);
    end

    
    % position encoding
    subplot(3,2,6);
    hist(positionEncodingScoreMatrix(:,i),correlationBins);
    xlim([min(positionEncodingScoreMatrix(:,i)) - 0.01 max(positionEncodingScoreMatrix(:,i)) + 0.01]);
    yt = get(gca, 'YTick');
    maxY = max(yt / numOfShifts);
    set(gca, 'YTick', yt, 'YTickLabel', yt/numOfShifts);
    x = [positionEncodingScoreMatrix(1,i) positionEncodingScoreMatrix(1,i)];
    y = [maxY 0];
    pValPosition = sum(positionEncodingScoreMatrix(:,i) > positionEncodingScoreMatrix(1,i)) /numOfShifts  + 1 / numOfShifts;
    text(0.8,0.8,['P Value = ' num2str(pValPosition)], 'Units', 'normalized');
    title({['Neuron ' num2str(i)]; ['Position encoding score = ' num2str(positionEncodingScoreMatrix(1,i))]});
    hold on;
    if positionEncodingScoreMatrix(1,i) > positionEncodingPrecetile
        plot(positionEncodingScoreMatrix(1,i),1,'r*', 'MarkerSize',12);
        fileName = [fileName '_positionEncoding'];  
    else
        plot(positionEncodingScoreMatrix(1,i),1,'g*', 'MarkerSize',12);
    end

    drawnow;
    savefig(['./Results/' fileName]);

end
