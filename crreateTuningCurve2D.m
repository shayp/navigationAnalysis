function tuning_curve = crreateTuningCurve2D(xLen, yLen, posx, posy, spiketrain)
posx(posx > xLen) = xLen - 0.1;
posy(posy > yLen) = yLen - 0.1;

%% fill out the tuning curve
% xAxis = linspace(0,xLen,xLen / 2 );
% yAxis = linspace(0, yLen, yLen  / 2 );
numXBins = xLen / 2;
numYBins = yLen / 2;
tuning_curve = zeros(numYBins, numXBins);
hit_tuning_curve = zeros(numYBins, numXBins);

for i  = 1:length(posx)
%     % figure out the position index
%     [~, xcoor] = min(abs(posx(i)-xAxis));
%     [~, ycoor] = min(abs(posy(i)-yAxis));
    xInd = round(posx(i) / 2);
    yInd = round(posy(i) / 2);
    if xInd < 1
        xInd = 1;
    end
    if yInd < 1
        yInd = 1;
    end
    hit_tuning_curve(numYBins + 1 - yInd, xInd) =  hit_tuning_curve(numYBins + 1 - yInd, xInd) + 1;
    tuning_curve(numYBins + 1 - yInd, xInd) =  tuning_curve(numYBins + 1 - yInd, xInd) + spiketrain(i);
end
tuning_curve = tuning_curve ./ hit_tuning_curve;
tuning_curve(isnan(tuning_curve)) = 0;
end