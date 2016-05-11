function irPlotFig2FracVar(experimentI,cellTypeI,fractionalVariance)

vcNewGraphWin([],'upperleftbig'); 
hold on;

badInds1 = fractionalVariance{experimentI,1,cellTypeI}<0.6;
fractionalVariance{experimentI,1,cellTypeI}(badInds1) = -1;

badInds = fractionalVariance{experimentI,2,cellTypeI}<0;
fractionalVariance{experimentI,2,cellTypeI}(badInds) = 0;

switch cellTypeI
    case 1
        scatter(fractionalVariance{experimentI,1,cellTypeI},fractionalVariance{experimentI,2,cellTypeI},'g');
        scatter(fractionalVariance{experimentI,1,cellTypeI},fractionalVariance{experimentI,2,cellTypeI},16,'k');
    case 2
        scatter(fractionalVariance{experimentI,1,cellTypeI},fractionalVariance{experimentI,2,cellTypeI},'g','filled');
        scatter(fractionalVariance{experimentI,1,cellTypeI},fractionalVariance{experimentI,2,cellTypeI},8,'k','filled');
end

plot(0:.1:1,0:.1:1);
axis([0 1 0 1]);
xlabel('WN Score (AU)'); ylabel('NSEM Score (AU)');
title('Fractional Variance');
set(gca,'fontsize',16);
set(gcf,'position',[0.2736    0.1878    0.4431    0.5578]);
drawnow;