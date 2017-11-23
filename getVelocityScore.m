function velocityScore = getVelocityScore(pos,spiketrain)
vel = diff([pos(1); pos]);

velocityScore = corr2(vel, spiketrain);
end