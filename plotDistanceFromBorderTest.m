function plotDistanceFromBorderTest(distanceScore, distanceSteps, distanceFiringRate, neuronNumber, distanceBins, numOfShifts, border5Precetile)

h1 = figure('Visible','on');
subplot(1,2,1);

papersize=[24   29.7];
width=papersize(1);height=12;
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
set(gcf, 'PaperPositionMode', 'manual');
myfiguresize = [0, 0, width, height];
set(h1,'papertype','a4',  'paperunits', 'centimeters', 'PaperPosition',myfiguresize);

p(1)=plot(distanceSteps(1,:),distanceFiringRate(1,:),'r');
hold on;
meanFR = mean(distanceFiringRate(1:end,:));
MX=distanceSteps(1,:);

maxFiringRate = max(distanceFiringRate(2:end,:));
minFiringRate = min(distanceFiringRate(2:end,:));

prctile95 = prctile(distanceFiringRate(2:end,:),95);
prctile5 = prctile(distanceFiringRate(2:end,:),5);

fill([MX fliplr(MX)], [maxFiringRate fliplr(minFiringRate)], [.0 .0 1 ], 'linestyle', 'none')
alpha(0.1)
fill([MX fliplr(MX)], [prctile95 fliplr(prctile5)], [.0 .0 1], 'linestyle', 'none')
alpha(0.3)
p(2)=plot(MX,meanFR,'b');

A=distanceScore(1);
plot([A,A],[0,1],':k');
B=0.75;
plot([0,max(distanceScore)],[B,B],'--g', 'LineWidth', 3);
set(gca,'XTick',unique(sort([0,A,5,10])),'Ytick',[0.25,.5,.75,1]);
ylim([-0.0 1.01]);
xlabel('Distance from Border [Cm]');
ylabel('Spike Fraction');
Ax(1)=gca;
set(Ax(1),'LineWidth',1,'FontWeight','Bold',...
    'FontName','Helvetica','FontSize',18,'Box','off',...
    'TickDir','out','TickLength',[.025 .025],'Layer','top'...\*,'YAxisLocation','right'*\
    );
set(p,'LineWidth',3)
legend(p,'Original Data','Shuffled Data','location','southeast');
subplot(1,2,2);
hist(distanceScore,distanceBins);
xlim([min(distanceScore) - 0.01 max(distanceScore) + 0.01]);
yt = get(gca, 'YTick');
    
set(gca, 'YTick', yt, 'YTickLabel', yt/numOfShifts)
title({['Neuron ' num2str(neuronNumber) ]; ['Border score = ' num2str(distanceScore(1))]});
pValBorder = 1 - (sum(distanceScore > distanceScore(1)) /numOfShifts) + 1/ numOfShifts;
text(0.7,0.9,['P Value = ' num2str(pValBorder)], 'Units', 'normalized');
hold off;
hold on;
axis square;
if distanceScore(1) < border5Precetile && distanceScore(1) < 5
    plot(distanceScore(1),1,'r*', 'MarkerSize',12);
else
    plot(distanceScore(1),1,'g*', 'MarkerSize',12);
end

fileName = ['Neuron_' num2str(neuronNumber) '_borderScoreCurve'];
savefig(h1, ['./Results/' fileName]);

end