function [average,ppb,radialSum] = azimuthalAverage3D(image, center, binNo)
    yv = (1-center(1)):(size(image, 1)-center(1));
    xv = (1-center(2)):(size(image, 2)-center(2));
    zv = (1-center(3)):(size(image, 3)-center(3));


    [xm,ym,zm] = meshgrid(xv,yv,zv);
    R = sqrt(xm.^2+ym.^2+zm.^2);

    maxbinval = max(R(:));
    %binRanges = (-0.5:binFactor:maxbinval);
    dr = 1/(binNo-1);
    binRanges = linspace(-dr/2,1+dr/2,binNo+1)*maxbinval;
   
    [ppb, binIds] = histc(R(:), binRanges);
    binIds = reshape(binIds, size(R));

    radialSum = zeros(size(ppb));

    dispstat('', 'init')
    dispstat(sprintf('Averaging %d bins ...', binNo), 'keepthis')
    for binId=1:length(ppb)
        dispstat(sprintf('%d', binId))
        radialSum(binId) = sum(image(binIds==binId));
    end
    disp('done')

    average = radialSum./ppb;
end