function filename = plotStatistics(scoreMatrix, bins, numOfShifts, Precetile,filename, string, sufixText, index, plotInd)
subplot(4,2,plotInd);
    hold on;
    histogram(scoreMatrix(:,index),bins);
    xlim([min(scoreMatrix(:,index)) - 0.01 max(scoreMatrix(:,index)) + 0.01]);
    yt = get(gca, 'YTick');
    set(gca, 'YTick', yt, 'YTickLabel', yt/numOfShifts)

    title({['Neuron ' num2str(index)]; [string num2str(scoreMatrix(1,index), 2)]});
    hold off;
    pVal = sum(scoreMatrix(:,index) > scoreMatrix(1,index)) /numOfShifts + 1 / numOfShifts; 
    text(0.8, 0.8, ['P Value = ' num2str(double(pVal), 4)], 'Units', 'normalized');
    hold on;
    if scoreMatrix(1,index) > Precetile
        plot(scoreMatrix(1,index),1,'r*', 'MarkerSize',12);
        filename = [filename sufixText];
    else
        plot(scoreMatrix(1,index),1,'g*', 'MarkerSize',12);
    end
    hold off;
    drawnow;
end