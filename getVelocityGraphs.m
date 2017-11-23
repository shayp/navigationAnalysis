function [hdTuningFast, hdTuningSlow, bins, timeSpentFast, timeSpentSlow]  = getVelocityGraphs(posx, posy, headDirection, spiketrain, dt, threshold)
    % add the extra just to make the vectors the same size
    velx = diff([posx(1); posx]);
    vely = diff([posy(1); posy]); 
    bins = 8;
    velx = velx;
    vely = vely;
    speed = sqrt(velx.^2+vely.^2) / dt; 
    hdTuningSlow = zeros(bins, 1);
    hdTuningFast = zeros(bins, 1);
    timeSpentSlow = zeros(bins, 1);
    timeSpentFast = zeros(bins, 1);

    hdVec = linspace(0, 2 * pi, bins + 1);
    fastInd = find(speed > threshold);
    slowInd = find(speed < threshold);
    for i = 1:bins
        timeSpentFastHDInd = headDirection(fastInd) > hdVec(i) & headDirection(fastInd) < hdVec(i+ 1);
        timeSpentSlowHDInd = headDirection(slowInd) > hdVec(i) & headDirection(slowInd) < hdVec(i+ 1);
        timeSpentFast(i) = sum(timeSpentFastHDInd);
        timeSpentSlow(i) = sum(timeSpentSlowHDInd);
        if sum(timeSpentFastHDInd) == 0
            hdTuningFast(i) = 0;
        else
            hdTuningFast(i) = sum(spiketrain(fastInd(timeSpentFastHDInd))) / sum(timeSpentFastHDInd);
            
        end
        
       if sum(timeSpentSlowHDInd) == 0
            hdTuningSlow(i) = 0;
        else
            hdTuningSlow(i) = sum(spiketrain(slowInd(timeSpentSlowHDInd))) / sum(timeSpentSlowHDInd);
            
        end
    end
hdTuningSlow  = hdTuningSlow /dt;
hdTuningFast  = hdTuningFast /dt;

end