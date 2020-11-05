


%%
viewField = 150e-9;
showSlices(p1, viewField, realSpaceSampling)
showSlices(p2, viewField, realSpaceSampling)
% showSlices(p2aligned, viewField, realSpaceSampling)

%% FOURIER SHELL CORRELATION
% still needs fix with Friedel symmetry applied!!!

%

% styled figure
set(0, 'defaultFigureColor', 'white')
set(0, 'defaultFigureWindowStyle', 'docked')
set(0, 'defaultAxesLineWidth', 2)
set(0, 'defaultAxesFontSize', 20)
set(0, 'defaultColorbarLinewidth', 2)
set(0, 'defaultColorbarFontSize', 15)


% realspace sampling
lambda = 7.75e-10;
z = 58.1e-2;
dPixelSize = 4*75e-6;
nPixels = 1040/4;
realSpaceSampling = lambda * z / (nPixels*dPixelSize);
pixelSize = realSpaceSampling;

cornerRes2D = realSpaceSampling/sqrt(2);

% spatial frequency maximum
% use here the 2D corner value because that is the length of the profile
% line as defined by lineRadLen
spFreqMax = 1/(2*cornerRes2D) * 1e-9;
spFreqCoords = linspace(0,spFreqMax, numel(FSCdata));


% get the FSC data
FSCdata = FSC(reconstructedParticle1, reconstructedParticle2);


% profile line plot
figure('Color', 'white');
plot(spFreqCoords, FSCdata, 'r', 'LineWidth', 2);
ax1 = gca;
ax1.Box = 'off';
xlim([0 spFreqMax])
ylabel('FSC')
xlabel('spatial frequency [nm^{-1}]')
set(ax1, 'YLim', [0 1.1])
pause(0.5) % needed to get figure right before adding another axis

set(ax1, 'box', 'off', ...
    'Position', get(ax1, 'Position') - [0 -0.05 0 0.15]);

pause(0.5) % needed to get figure right before adding another axis

% select full or half period resolution axis
resScale = 'fp';

switch resScale
    case 'hp'
resTicks = 1./(2*get(ax1, 'XTick'));
    case 'fp'
resTicks = 1./(get(ax1, 'XTick'));
end


pause(0.5) % needed to get figure right before adding another axis

% create half period axis
ax2 = axes('Position',get(ax1,'Position'));


% styling
set(ax2, ... 'box','off', ...
    'xAxisLocation', 'top', ...
    'yAxisLocation', 'right', ...
    'color', 'none', ...
    'XTickLabel', num2str(resTicks',3), ...
    'xLim', get(ax1, 'xLim'), ...
    'xScale', get(ax1, 'xScale'), ...
    'yLim', get(ax1, 'yLim'), ...
    'yScale', get(ax1, 'yScale') ...
    );

switch resScale
    case 'hp'
xlabel('Half Period Resolution [nm]')
    case 'fp'
xlabel('Full Period Resolution [nm]')
end

% link axes in case of zooming
linkaxes([ax1 ax2])

% threshold lines
n = 1:numel(FSCdata);
n = n * size(p1,1)/numel(FSCdata)/2;
T1 = (0.5 + (1+sqrt(2)) ./ sqrt(n)) ./ (1.5 +sqrt(2./n));
T2 = (0.2071 + 1.9102 ./ sqrt(n)) ./ (1.2071 + 0.9102 ./ sqrt(n));
% T1(1) = 1;
% T2(1) = 1;

line(ax2, spFreqCoords, T1, 'Color', 'k', 'LineWidth', 2, 'LineStyle', '--','DisplayName', '1-bit threshold')
line(ax2, spFreqCoords, T2, 'Color', 'k', 'LineWidth', 2, 'LineStyle', ':', 'DisplayName', '1/2-bit threshold')
legend('location', 'southwest')
%%
export_fig('FSCusingABS', '-q101', '-png')
