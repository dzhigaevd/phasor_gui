function showSlices(volumeImage, windowSize, pixelSize)

set(0, 'defaultColorBarLineWidth', 2, ...
    'defaultFigureColor', 'w', ...
    'defaultAxesLineWidth', 2, ...
       'defaultAxesFontSize', 16)



% window in which the virues lies
% windowSize = 150e-9;
windowPixels = round(windowSize/pixelSize);
indStart = round((size(volumeImage,1)-windowPixels)/2);
indEnd = round((size(volumeImage,1)+windowPixels)/2);
sliceCenter = round(windowPixels/2);

% crop data to smaller window
volumeImage = volumeImage(indStart:indEnd, ...
                                        indStart:indEnd, ...
                                        indStart:indEnd);
                                    
volumeImage = volumeImage/max(volumeImage(:));



slices(:,:,1) = abs(volumeImage(:,:,sliceCenter)); % x,y
slices(:,:,2) = abs(squeeze(volumeImage(:,sliceCenter,:))); % x,z
slices(:,:,3) = abs(squeeze(volumeImage(sliceCenter,:,:))); % y,z

tit = {'x y', 'x z', 'y z'};

scaleBarLength = 50e-9;
clims = [0 1];

figure('WindowStyle', 'docked', 'Color', 'white')
cmap = colormap(bone);
cmap = flip(cmap,1);
colormap(cmap);
for ii = 1 : size(slices,3)
ax = subplot(1,3,ii);
imagesc(slices(:,:,ii))
axis image
ax.YTickLabel = [];
ax.XTickLabel = [];
caxis(clims)
title(tit{ii})
ylabel(colorbar, 'electron density [a.u.]')
scalebarScaled('ScaleLength', scaleBarLength/pixelSize, ...
               'units', pixelSize, ...
               'Colour', [0 0 0], ...
               'Location', 'southeast', ...
               'Bold', true);
end
end
