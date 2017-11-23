function [slowHDScore, fastHDScore] = getHeadDirectionSpeedScore(posx, posy, headDirection, spiketrain, dt, threshold)
    % add the extra just to make the vectors the same size
    velx = diff([posx(1); posx]);
    vely = diff([posy(1); posy]); 
    velx = velx;
    vely = vely;
    speed = sqrt(velx.^2+vely.^2) / dt; 

    fastInd = find(speed > threshold);
    slowInd = find(speed < threshold);
    
    fastSpikeTrain = spiketrain(fastInd);
    slowSpikeTrain = spiketrain(slowInd);
   
    fastHD = headDirection(fastInd);
    slowHD = headDirection(slowInd);
    
    slowHDScore = corr2(slowSpikeTrain,slowHD);
    fastHDScore = corr2(fastSpikeTrain, fastHD);
end