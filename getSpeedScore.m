function [speedScore, speed] = getSpeedScore(posx, posy, spiketrain, sampleRate)
 % add the extra just to make the vectors the same size
velx = diff([posx(1); posx]);
vely = diff([posy(1); posy]);

speed = sqrt(velx.^2+vely.^2) * sampleRate; 
speedScore = corr2(speed, spiketrain);
end