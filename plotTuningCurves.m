function plotTuningCurves(neuronNumber, posx, posy, spiketrain, headDirection, boxSize, numHDBins, numSpeedBins, numVelBins, dt, threshold, shuffleSpikeTrain)
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

fig1  = figure('Visible','on');

spiketrain = spiketrain / dt;
% plot position
subplot(3,2,1:2);
spikeInd = find(spiketrain);
shuffleInd = find(shuffleSpikeTrain);
plot(posx,posy, posx(spikeInd), posy(spikeInd), 'r*', posx(shuffleInd), posy(shuffleInd), 'g*', 'MarkerSize', 8);
legend('trajectory', 'experiment spikes', 'shuffle spikes');
title(['Neuron ' num2str(neuronNumber) ' trajectory']);
xlabel('X Dim(cms)')
ylabel('Y Dim(cms)')

%head direction
hd_tuning_curve = compute_1d_tuning_curve(headDirection, spiketrain, numHDBins,0, 2* pi);
hd_range = linspace(0, 360, numHDBins);

subplot(3,2,3);
plot(hd_range, hd_tuning_curve,'k','linewidth',3);
box off
axis([0 360 -inf inf])
xlabel('direction angle')
ylabel('Spikes/s');
title(['Neuron ' num2str(neuronNumber) ' Head direction curve'])

% speed and velocity
 velx = diff([posx(1); posx]);
 vely = diff([posy(1); posy]);

 speed = sqrt(velx.^2+vely.^2) / dt;
 maxSpeed = max(speed);
speed_tuning_curve = compute_1d_tuning_curve(speed, spiketrain, numSpeedBins,0, maxSpeed);
speed_range = linspace(0, maxSpeed, numSpeedBins);
subplot(3,2,4);
plot(speed_range, speed_tuning_curve,'k','linewidth',3);
box off
axis([0 maxSpeed -inf inf])
xlabel('Speed (cm/s)')
ylabel('Spikes/s');
title(['Neuron ' num2str(neuronNumber) ' Speed curve']);
minVelX = min(velx / dt);
maxVelX = max(velx / dt);
minVelY = min(vely / dt);
maxVelY = max(vely / dt);
vel_tuning_curve_2d = compute_2d_tuning_curve(velx / dt,vely / dt,spiketrain,numVelBins,[minVelX minVelY], [maxVelX maxVelY]);
velx_range = linspace(minVelX, maxVelX, numVelBins);
vely_range = linspace(minVelY, maxVelY, numVelBins);

subplot(3,2,5:6);
imagesc(velx_range, fliplr(vely_range), vel_tuning_curve_2d); colorbar
colormap jet;
box off;
title(['Neuron ' num2str(neuronNumber) ' Velocity 2D curve']);
axis equal;
xlabel('velocity x (cm/s)')
ylabel('velocity y (cm/s)')

savefig(fig1, ['./Results/Neuron_' num2str(neuronNumber) '_TuningCurves']);

fig2 = figure('Visible','on');

velx_tuning_curve = compute_1d_tuning_curve(velx / dt, spiketrain, numVelBins,-maxSpeed, maxSpeed);
subplot(2,2,1);
plot(velx_range, velx_tuning_curve,'k','linewidth',3);
box off;
xlabel('velocity x (cm/s)');
ylabel('Spikes/s');
title(['Neuron ' num2str(neuronNumber) ' velocity x curve']);

vely_tuning_curve = compute_1d_tuning_curve(vely / dt, spiketrain, numVelBins,-maxSpeed, maxSpeed);
subplot(2,2,2);
plot(vely_range, vely_tuning_curve,'k','linewidth',3);
box off;
xlabel('velocity y (cm/s)');
ylabel('Spikes/s');
title(['Neuron ' num2str(neuronNumber) ' velocity y curve']);


[hdTuningFast, hdTuningSlow, timeSpentFast, timeSpentSlow]  = getVelocityGraphs(posx, posy, headDirection, spiketrain, dt, threshold, numHDBins);
 
subplot(2,2,3);
yyaxis left;
plot(hd_range, hdTuningFast,'linewidth',3);
axis([0 360 -inf inf])
ylabel('Spikes/s');
yyaxis right;
plot(hd_range, timeSpentFast,'linewidth',3);
axis([0 360 -inf inf])
ylabel('Time spent');
xlabel('direction angle');
title(['Neuron ' num2str(neuronNumber) ' Head direction tuning - fast speed']);

subplot(2,2,4);
yyaxis left;
plot(hd_range, hdTuningSlow,'linewidth',3);
axis([0 360 -inf inf])
ylabel('Spikes/s');
yyaxis right;
plot(hd_range, timeSpentSlow,'linewidth',3);
axis([0 360 -inf inf])
ylabel('Time spent');
xlabel('direction angle');
title(['Neuron ' num2str(neuronNumber) ' Head direction tuning - low speed']);
savefig(fig2, ['./Results/Neuron_' num2str(neuronNumber) '_velocityCurves']);

[~, firstTuning_curve, secondTuning_curve] = getHalfsTuningCurves(posx, posy, spiketrain,boxSize);
[~,odd_tuning_curve, even_tuning_curve] = getPositionScore(posx, posy, spiketrain,boxSize);

fig3 = figure('Visible','on');
subplot(4,1,1)
odd_tuning_curve = filter2(h,odd_tuning_curve);
imagesc([0 boxSize(1)] , [0 boxSize(2)], odd_tuning_curve);
title(['Neuron ' num2str(neuronNumber) ', Position tuning curve - Odd minutes']);
colorbar;
colormap jet;

xlabel('Aquarium Length [cm]');
ylabel('Aquarium Width [cm]');
subplot(4,1,2)
even_tuning_curve = filter2(h,even_tuning_curve);
imagesc([0 boxSize(1)] , [0 boxSize(2)], even_tuning_curve);
colorbar;
colormap jet;
xlabel('Aquarium Length [cm]');
ylabel('Aquarium Width [cm]');
title(['Neuron ' num2str(neuronNumber) ', Position tuning curve - Even minutes']);
    
subplot(4,1,3)
firstTuning_curve = filter2(h,firstTuning_curve);
imagesc([0 boxSize(1)] , [0 boxSize(2)], firstTuning_curve);
colorbar;
colormap jet;
xlabel('Aquarium Length [cm]');
ylabel('Aquarium Width [cm]');
title(['Neuron ' num2str(neuronNumber) ', Position tuning curve - First half']);
    
subplot(4,1,4)
secondTuning_curve = filter2(h,secondTuning_curve);
imagesc([0 boxSize(1)] , [0 boxSize(2)], secondTuning_curve);
colorbar;
colormap jet;
xlabel('Aquarium Length [cm]');
ylabel('Aquarium Width [cm]');
title(['Neuron ' num2str(neuronNumber) ', Position tuning curve - second half']);
    
savefig(fig3, ['./Results/Neuron_' num2str(neuronNumber) '_PositionCurve']);
 
end