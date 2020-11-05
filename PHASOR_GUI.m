% This software is designed for research propurses only and does not give
% any guarantee on any obtained result.
% Initially designed by Dmitry Dzhigaev, at DESY, Photon Science division,
% Hamburg, Germany
% Any requests, comments, bugs: ddzhigaev@gmail.com
% For experimental parameters initialization please use format of ini.phas
% in the main folder of the PHASOR

function PHASOR_GUI
%   close all;
    clear;   
    warning('off','all');
    
    % Determine where your m-file's folder is.
    folder = fileparts(which(mfilename));
    
    % Add that folder plus all subfolders to the path.
    addpath(genpath(folder));

    % Main phase retrieval algorithms are collected here:    
	% Constants. They are needed for correct labeling of axes
    h                       = 4.1357e-15;                                  % Plank's constant
    c                       = 2.99792458e8;                                % Speed of light in vacuum
                                           
    % ============================ GUI ====================================
    % --- Create the starting window
    % ===================================================================== 
    left1                   = 0.1;                                         % Values for UI elements positioning
    left2                   = 0.4;
    width                   = 0.3;
    height                  = 0.05;
    
    % Try to import an ini.phas file
    iniName = 'ini.phas';
    ini = getIni(iniName);
    
    mainF = figure('Name','PHASOR',...
        'NumberTitle','off','units',...
        'normalized','outerposition',[0 0.2 0.8 0.8]);       
    
    tgroup = uitabgroup('Parent', mainF);
        tab1 = uitab('Parent', tgroup, 'Title', 'Load Data');

    startIm = imread(fullfile('introLogo.png'));
    axes('Parent',tab1); 
    imagesc(startIm); axis image; zoom(1); set(gca,'xtick',[],'ytick',[]);
    
    uicontrol('Parent',tab1,'Style','text',...
        'String','Dzhigaev Dmitry 2018','Units','normalized',...
        'Position',[0.01 0.05 0.2 0.03]);
    
    leftPanelData = uipanel('Parent',tab1,'Title','Data control','FontSize',...
        12,'Units','Normalized','Position',[.01 0.1 .2 .85]);        
     
    % Button for openning the file 
    uicontrol('Parent',leftPanelData,'Units','normalized',...
        'Position',[0.02 0.87 0.45 0.1],'String','Open file',...
        'Callback',@openFile3D);                    
    
    uicontrol('Parent',leftPanelData,'Style','text',...
            'String','Binning',...
            'Units','normalized','Position',[left1 0.8 width height])      ;        
    
    hbinning = uicontrol('Parent',leftPanelData,'Style','edit',...
        'String',string(ini(1)),...
        'Units','normalized','Position',[left2 0.8 width height])      ;
        
    uicontrol('Parent',leftPanelData,'Style','text',...
        'String','Energy, [eV]',...
        'Units','normalized','Position',[left1 0.7 width height])      ;        
    
    hEnergy = uicontrol('Parent',leftPanelData,'Style','edit',...
            'String',string(ini(2)),...
            'Units','normalized','Position',[left2 0.7 width height])      ;
    
    uicontrol('Parent',leftPanelData,'Style','text',...
    'String','Sample-detector distance, [m]',...
    'Units','normalized','Position',[left1 0.6 width height])      ;        

    hSDD = uicontrol('Parent',leftPanelData,'Style','edit',...
            'String',string(ini(3)),...
            'Units','normalized','Position',[left2 0.6 width height])      ;
        
    uicontrol('Parent',leftPanelData,'Style','text',...
    'String','Detector pixel size, [m]',...
    'Units','normalized','Position',[left1 0.5 width height])      ;        

    hDetectorPixel = uicontrol('Parent',leftPanelData,'Style','edit',...
            'String',string(ini(4)),...
            'Units','normalized','Position',[left2 0.5 width height])      ;       
    
    uicontrol('Parent',leftPanelData,'Style','text',...
    'String','Angular step, [degrees]',...
    'Units','normalized','Position',[left1 0.4 width height])      ;        

    hAngularStep = uicontrol('Parent',leftPanelData,'Style','edit',...
            'String',string(ini(5)),...
            'Units','normalized','Position',[left2 0.4 width height])      ;
        
    hshowDataCheck = uicontrol('Parent',leftPanelData,'Style','checkbox',...
            'String','Show Isosurfaces','Value',0,...
            'Units','normalized','Position',[left1 0.3 width*3 height])    ;   
       
% ============================ GUI ========================================

% =========================================================================            
    function openFile3D(hObj,callbackdata)                                 % Main function of the display     
        
        % Callback definitions
        % Initialization of the object function
        function restoreGUI(ObjH, EventData)
            OrigDlgH = ancestor(ObjH, 'figure');
            delete(OrigDlgH);
            PHASOR_GUI;
        end
                        
        function createObjectCallback(hObj,callbackdata)                        
            param = createObject(param);      
        end
                
        % Update the 3D visualization of the reciprocal space
        function updateObjectReci(hObj,callbackdata)
            cla(imAxData1);
            axes(imAxData1); 
			isosurface(param.reciprocalVectorX,param.reciprocalVectorY,param.reciprocalVectorZ,param.dataLog./max(max(max(param.dataLog))),isoValReciprocal); 				
            xlabel('Q_{x}, [nm^{-1}]'); ylabel('Q_{y}, [nm^{-1}]'); zlabel('Q_{z}, [nm^{-1}]');
            axis tight; h1 = light; h1.Position = [-1 -1 -1];  h2 = light; h2.Position= [1 1 1]; rotate3d on
            colormap jet;
            
            drawnow();axis image;
            disp('Object updated!');
        end
        
        function updateObjectReal(hObj,callbackdata)         
            % Update 3D
            cla(imAxData2);
            axes(imAxData2); 
			isosurface(param.coordinateVectorX,param.coordinateVectorY,param.coordinateVectorZ,abs(param.O)./max(max(max(abs(param.O)))),isoValReal,angle(param.O)); 
                % axis vis3d equal;
            xlabel('x, [nm]'); ylabel('y, [nm]'); zlabel('z, [nm]');
            axis tight; 
            h3 = light; 
            h3.Position = [-1 -1 -1];  
            h4 = light; 
            h4.Position= [1 1 1];  
            rotate3d on ;
            colormap jet;
            c = colorbar(imAxData2,'Location','northoutside');
            c.Label.String = 'Phase, [rad]';
            
            % Update 2D            
            % Here ErrR = -1, as an exception value to update only 2D
            % slices in reconstruction monitors
            
            param.ShowSupport    = get(hShowSupport,'Value');
            showProgress(param,fftNc(param.O.*param.support),-1); 
            
            drawnow();%axis image;
            disp('Object updated!');
        end
        
        function updateFrame(hObj,callbackdata)         
            cla(axMod);
            axes(axMod); 
			imagesc(param.coordinateVectorX,param.coordinateVectorY,param.dataLog(:,:,frameVal));                 
            xlabel('x, [nm]'); ylabel('y, [nm]');
            axis image; 
           
            colormap jet;
            c = colorbar(axMod);
            c.Label.String = 'Amplitude log, [rad]';
            
            drawnow();%axis image;
            disp('Frame updated!');
        end
        
        function recenterCallback1(hObj,callbackdata)
            param = centerData(param,'fill','-');
            updateObjectReal;
        end
        
        function recenterCallback2(hObj,callbackdata)
            param = centerData(param,'fill','+');
            updateObjectReal;
        end
        
        function showBackgroundCallback(hObj,callbackdata)
            showBackground(param);
        end
         
        function slideIsosurfaceReciprocal(hObj,callbackdata)
            isoValReciprocal = get(hObj,'Value');
            updateObjectReci;
        end
        
        function slideIsosurfaceReal(hObj,callbackdata)
            isoValReal = get(hObj,'Value');
            updateObjectReal;
        end        
        
        function slideFrames(hObj,callbackdata)
            frameVal = get(hObj,'Value');
            updateFrame;
        end
        
        function calculatePSD(hObj,callbackdata)   
            centralPanelEvaluationPSD = uipanel('Parent',tab3,'Title','Evaluation plots','FontSize',...
            12,'Units','Normalized','Position',[.22 0.1 .77 .85]);
        
            [Zr,R] = radialAvg3D(param.data, str2num(get(hnBinsPSD,'String')));
            
            maxFrequ = param.dQx.*max(R(:))/1e9;

            ax1 = axes('Parent', centralPanelEvaluationPSD);
            plot(ax1,Zr);
            
            scaleType = 'log';
            %Yrange = [0 1.1];
            
            set(ax1, 'YScale', scaleType, 'PlotBoxAspectRatio', [1 0.5 1]); ylabel('PSD')
            
            % extend the maxFrequency coordinates till the corner of the
            % diffraction pattern as was measured
            cornerRes = param.realPixelSizeX/sqrt(3);
            maxFreqVal = 1/(2*cornerRes);

            % create spatial frequency cordinates for the x-axis
            frequencyCoord = (0: maxFreqVal / length(R) : maxFreqVal-maxFreqVal / length(R));

            % replace x-axis values with frequency coordinates
            set(ax1.Children, 'XData', frequencyCoord*1e-9);

            % style the lower x-axis
            set(ax1, 'box', 'off', ...
                  'Position', get(ax1, 'Position') - [0 0 0 0.05], ...
                  ...'xlim', [0.1 maxFrequ], ...
                  'xScale', 'lin', ...
                  'color', 'none');
            xlabel('Spatial Frequency [nm^{-1}]')

            % transform spatial frequency ticks to half period resolution in [nm]
            pause(0.1) % needed to get figure right, nasty matlab bug
            xTicksHalfPeriod = 1./(2*get(ax1, 'XTick'));
            pause(0.1) % needed to get figure right, nasty matlab bug
         
            % create upper x-axis for half peridod labels
            ax2 = axes('Parent',centralPanelEvaluationPSD,'Position',get(ax1,'Position'));

            % style the upper x-axis
            set(ax2, ...'box','off', ...
                  'xAxisLocation', 'top', ...
                  'yAxisLocation', 'right', ...
                  'PlotBoxAspectRatio', get(ax1, 'PlotBoxAspectRatio'), ...
                  'color', 'white', ...
                  'XTickLabel', num2str(xTicksHalfPeriod',3), ...
                  'xLim', get(ax1, 'xLim'), ...
                  'xScale', get(ax1, 'xScale'), ...
                  'xScale', get(ax1, 'xScale'), ...
                  'yLim', get(ax1, 'yLim'), ...
                  'yScale', get(ax1, 'yScale') ...
                  );

            xlabel('Half Period Resolution [nm]')
            
            axes(ax1);             
            linkaxes([ax1 ax2]);
        end
        
        function calculatePRTF(hObj,callbackdata)   
            centralPanelEvaluationPRTF = uipanel('Parent',tab3,'Title','Evaluation plots','FontSize',...
            12,'Units','Normalized','Position',[.22 0.1 .77 .85]);
        
            [Zr,R] = radialAvg3D(param.data, str2num(get(hnBinsPRTF,'String')));
            Or   = radialAvg3D(abs(fftNc(param.O)), str2num(get(hnBinsPRTF,'String')));            
            PRTF = Or./Zr;            
            maxFrequ = param.dQx.*max(R(:))/1e9;
            
            ax1 = axes('Parent', centralPanelEvaluationPRTF);
            cla;
            plot(ax1,PRTF);
            
            scaleType = 'log';
            %Yrange = [0 1.1];
            
            set(ax1, 'YScale', scaleType, 'PlotBoxAspectRatio', [1 0.5 1]); ylabel('PRTF')
            
            % extend the maxFrequency coordinates till the corner of the
            % diffraction pattern as was measured
            cornerRes = param.realPixelSizeX/sqrt(3);
            maxFreqVal = 1/(2*cornerRes);

            % create spatial frequency cordinates for the x-axis
            frequencyCoord = (0: maxFreqVal / length(R) : maxFreqVal-maxFreqVal / length(R));

            % replace x-axis values with frequency coordinates
            set(ax1.Children, 'XData', frequencyCoord*1e-9);

            % style the lower x-axis
            set(ax1, 'box', 'off', ...
                  'Position', get(ax1, 'Position') - [0 0 0 0.05], ...
                  ...'xlim', [0.1 maxFrequ], ...
                  'xScale', 'lin', ...
                  'color', 'none');
            xlabel('Spatial Frequency [nm^{-1}]')

            % transform spatial frequency ticks to half period resolution in [nm]
            pause(0.1) % needed to get figure right, nasty matlab bug
            xTicksHalfPeriod = 1./(2*get(ax1, 'XTick'));
            pause(0.1) % needed to get figure right, nasty matlab bug
         
            % create upper x-axis for half peridod labels
            ax2 = axes('Parent',centralPanelEvaluationPRTF,'Position',get(ax1,'Position'));

            % style the upper x-axis
            set(ax2, ...'box','off', ...
                  'xAxisLocation', 'top', ...
                  'yAxisLocation', 'right', ...
                  'PlotBoxAspectRatio', get(ax1, 'PlotBoxAspectRatio'), ...
                  'color', 'white', ...
                  'XTickLabel', num2str(xTicksHalfPeriod',3), ...
                  'xLim', get(ax1, 'xLim'), ...
                  'xScale', get(ax1, 'xScale'), ...
                  'xScale', get(ax1, 'xScale'), ...
                  'yLim', get(ax1, 'yLim'), ...
                  'yScale', get(ax1, 'yScale') ...
                  );

            xlabel('Half Period Resolution [nm]')
            
            axes(ax1);             
            linkaxes([ax1 ax2]);
        end
        
        %===================== ALGORITHMS START ==========================%        
        function setPattern(source, event)
            customFlag = 0;
            function setPatternCustom(source,event)                                
                param.currentPattern = hPattern.String;
                fprintf('Pattern %s is selected!\n', param.currentPattern);
                customFlag = 1;
                close;
            end
                
            param.currentPattern = source.String{source.Value};
            fprintf('Pattern %s is selected!\n', param.currentPattern);
            
            if strcmp(param.currentPattern,'custom')
                patternInput = figure('Name','Input custom pattern',...
                                                        'NumberTitle','off','units',...
                                                        'normalized','outerposition',[0 0.2 0.3 0.1]);
                
                hPattern = uicontrol('Parent',patternInput,'Style','edit',...
                        'String','',...
                        'Units','normalized','Position',[0.01 0.09 0.8 0.8]);
                
                uicontrol('Parent',patternInput,...
                        'String','Ok',...
                        'Units','normalized','Position',[0.85 0.09 0.15 0.8],...
                        'Callback', @setPatternCustom);
            end
            
            if customFlag == 1
                set(source.String{1},param.currentPattern);
            end
        end
        
        function setPatternGA(source, event)
            customFlag = 0;
            function setPatternCustom(source,event)                                
                param.currentPattern = hPattern.String;
                fprintf('Pattern %s is selected!\n', param.currentPattern);
                customFlag = 1;
                close;
            end

            param.currentPattern = source.String{source.Value};
            fprintf('Pattern %s is selected!\n', param.currentPattern);

            if strcmp(param.currentPattern,'custom')
                patternInput = figure('Name','Input custom pattern',...
                                                        'NumberTitle','off','units',...
                                                        'normalized','outerposition',[0 0.2 0.3 0.1]);

                hPattern = uicontrol('Parent',patternInput,'Style','edit',...
                        'String','',...
                        'Units','normalized','Position',[0.01 0.09 0.8 0.8]);

                uicontrol('Parent',patternInput,...
                        'String','Ok',...
                        'Units','normalized','Position',[0.85 0.09 0.15 0.8],...
                        'Callback', @setPatternCustom);
            end

            if customFlag == 1
                set(source.String{1},param.currentPattern);
            end
        end

        function performReconstructionGA(hObj,callbackdata)                              
            
            % Get parameters from the forms
            param.ShowSupport    = get(hShowSupport,'Value');
            param.GPUcheck       = get(hGPUcheck,'Value');
            param.SigmaStart     = str2double(get(handlesGA.hSigmaStartGA,'String'));
            param.SigmaEnd       = str2double(get(handlesGA.hSigmaEndGA,'String'));
            param.SrinkwrapSteps = str2double(get(handlesGA.hSrinkwrapStepsGA,'String'));
            param.ShowSteps      = str2double(get(handlesER.hShowStepsER,'String'));
            param.dataThreshold  = str2double(get(hdataThreshold,'String'));  
            param.Treshold       = str2double(get(handlesER.hTresholdER,'String')); 
            metrics              = get(handlesGA.hErrorMetric,'String');
            param.metricType     = metrics{get(handlesGA.hErrorMetric,'Value')};
            param.sigma          = param.SigmaStart;
                        
            param = GA3D(param,GAtab,handlesGA,handlesER,handlesHIO,handlesSF,handlesDM,handlesRAAR,handlesASR);
            disp('The object returned!');
            saveResult();
            disp('Result is saved!');
        end
            
        function performReconstructionPattern(hObj,callbackdata)
            uicontrol('Parent',MIXtab,'String','Stop THAT!','Units','normalized',...
            'Position',[left1 0.08 0.8 0.1],...
            'Callback',@stopReconstructionPattern);                        
        
            function stopReconstructionPattern(hObj,callbackdata)            
                param.stopFlagPattern = 1; 
            end           
            
            param.stopFlagPattern = 0;
            param.stopFlag = 0;

            algoList = (strsplit(param.currentPattern,'+'));
           
            for cycleCounter = 1:str2double(get(hnMIX,'String'))
                if param.stopFlagPattern == 0
                    % Create a new random guess for the object
                    param = createObject(param);                                

                    % Get parameters from the forms
%                     param.hBackgroundcheck = get(hBackgroundcheck,'Value');
                    param.ShowSupport    = get(hShowSupport,'Value');
                    param.GPUcheck       = get(hGPUcheck,'Value');
                    param.SigmaStart     = str2double(get(hSigmaStartMIX,'String'));
                    param.SigmaEnd       = str2double(get(hSigmaEndMIX,'String'));
                    param.SrinkwrapSteps = str2double(get(hSrinkwrapStepsMIX,'String'));
                    param.ShowSteps      = str2double(get(hShowStepsMIX,'String'));
                    param.Treshold       = str2double(get(hTresholdMIX,'String'));
                    param.dataThreshold   = str2double(get(hdataThreshold,'String')); 
                    param.Loop           = str2double(get(hnLoop,'String'));
                    param.sigma          = param.SigmaStart;
                                        
                    for loopCounter = 1:param.Loop
                        if param.stopFlagPattern == 0
                            for algoCounter = 1:numel(algoList)
                                if param.stopFlagPattern == 0
                                    switch algoList{algoCounter}
                                        case 'ER'
                                            metrics              = get(handlesER.hErrorMetric,'String');
                                            param.metricType     = metrics{get(handlesER.hErrorMetric,'Value')};
                                            param.nER  = str2double(get(handlesER.hnER,'String'));
                                            param.beta = str2double(get(handlesER.hBetaER,'String'));
                                            param = ER3D(param,MIXtab);                            
                                        case 'HIO'
                                            metrics              = get(handlesHIO.hErrorMetric,'String');
                                            param.metricType     = metrics{get(handlesHIO.hErrorMetric,'Value')};
                                            param.nHIO = str2double(get(handlesHIO.hnHIO,'String'));
                                            param.beta = str2double(get(handlesHIO.hBetaHIO,'String'));
                                            param = HIO3D(param,MIXtab); 
                                        case 'CHIO'
                                            metrics              = get(handlesCHIO.hErrorMetric,'String');
                                            param.metricType     = metrics{get(handlesCHIO.hErrorMetric,'Value')};
                                            param.nCHIO = str2double(get(handlesCHIO.hnCHIO,'String'));
                                            param.alpha = str2double(get(handlesCHIO.hAlphaCHIO,'String'));
                                            param.beta = str2double(get(hBetaCHIO,'String'));
                                            param = CHIO3D(param,MIXtab);
                                        case 'SF'
                                            metrics              = get(handlesSF.hErrorMetric,'String');
                                            param.metricType     = metrics{get(handlesSF.hErrorMetric,'Value')};
                                            param.nSF  = str2double(get(handlesSF.hnSF,'String'));
                                            param.beta = str2double(get(handlesSF.hBetaSF,'String'));
                                            param = SF3D(param,MIXtab);  
                                        case 'ASR'
                                            metrics              = get(handlesASR.hErrorMetric,'String');
                                            param.metricType     = metrics{get(handlesASR.hErrorMetric,'Value')};
                                            param.nASR  = str2double(get(handlesASR.hnASR,'String'));
                                            param.beta = str2double(get(handlesASR.hBetaASR,'String'));
                                            param = ASR3D(param,MIXtab);
                                        case 'DM'
                                            metrics              = get(handlesDM.hErrorMetric,'String');
                                            param.metricType     = metrics{get(handlesDM.hErrorMetric,'Value')};
                                            param.nDM  = str2double(get(handlesDM.hnDM,'String'));
                                            param.beta = str2double(get(handlesDM.hBetaDM,'String'));
                                            param = DM3D(param,MIXtab);
                                        case 'RAAR'
                                            metrics              = get(handlesRAAR.hErrorMetric,'String');
                                            param.metricType     = metrics{get(handlesRAAR.hErrorMetric,'Value')};
                                            param.nRAAR  = str2double(get(handlesRAAR.hnRAAR,'String'));
                                            param.beta = str2double(get(handlesRAAR.hBetaRAAR,'String'));
                                            param = RAAR3D(param,MIXtab);    
                                        case ' '
                                            error('Pattern is not selected!');                            
                                    end   
                                else
                                    break;
                                end
                                drawnow();
                            end
                        else
                            break;
                        end
                        drawnow();
                    end                
                drawnow();
                else
                    break;
                end
                disp('The object returned!');
                saveResult();
            end
            drawnow();
        end
        
        function performReconstructionER(hObj,callbackdata)
            param.stopFlag = 0;
            % Get parameters from the forms
%             param.hBackgroundcheck  = get(hBackgroundcheck,'Value');
            param.ShowSupport    = get(hShowSupport,'Value');
            param.GPUcheck       = get(hGPUcheck,'Value');
            param.nER            = str2double(get(handlesER.hnER,'String'));
            param.beta           = str2double(get(handlesER.hBetaER,'String'));
            param.SigmaStart     = str2double(get(handlesER.hSigmaStartER,'String'));
            param.SigmaEnd       = str2double(get(handlesER.hSigmaEndER,'String'));
            param.SrinkwrapSteps = str2double(get(handlesER.hSrinkwrapStepsER,'String'));
            param.ShowSteps      = str2double(get(handlesER.hShowStepsER,'String'));
            param.Treshold       = str2double(get(handlesER.hTresholdER,'String')); 
            param.dataThreshold  = str2double(get(hdataThreshold,'String')); 
            metrics              = get(handlesER.hErrorMetric,'String');
            param.metricType     = metrics{get(handlesER.hErrorMetric,'Value')};
            param.sigma          = param.SigmaStart;
 
            param = ER3D(param,ERtab);
            disp('The object returned!');
        end  
        
        function performReconstructionHIO(hObj,callbackdata)      
            param.stopFlag = 0; 
            % Get parameters from the forms    
%             param.hBackgroundcheck  = get(hBackgroundcheck,'Value');
            param.ShowSupport    = get(hShowSupport,'Value');
            param.GPUcheck       = get(hGPUcheck,'Value');
            param.nHIO           = str2double(get(handlesHIO.hnHIO,'String'));
            param.beta           = str2double(get(handlesHIO.hBetaHIO,'String'));
            param.SigmaStart     = str2double(get(handlesHIO.hSigmaStartHIO,'String'));
            param.SigmaEnd       = str2double(get(handlesHIO.hSigmaEndHIO,'String'));
            param.SrinkwrapSteps = str2double(get(handlesHIO.hSrinkwrapStepsHIO,'String'));
            param.ShowSteps      = str2double(get(handlesHIO.hShowStepsHIO,'String'));
            param.Treshold       = str2double(get(handlesHIO.hTresholdHIO,'String'));
            param.dataThreshold   = str2double(get(hdataThreshold,'String')); 
            metrics              = get(handlesER.hErrorMetric,'String');
            param.metricType     = metrics{get(handlesER.hErrorMetric,'Value')};
            
            param.sigma = param.SigmaStart; 
            param = HIO3D(param,HIOtab);
            disp('The object returned!');
        end                
        
        function performReconstructionCHIO(hObj,callbackdata)      
            param.stopFlag = 0; 
            % Get parameters from the forms    
            param.ShowSupport    = get(hShowSupport,'Value');
            param.GPUcheck       = get(hGPUcheck,'Value');            
            param.nCHIO          = str2double(get(handlesCHIO.hnCHIO,'String'));
            param.alpha          = str2double(get(handlesCHIO.hAlphaCHIO,'String'));
            param.beta           = str2double(get(handlesCHIO.hBetaCHIO,'String'));
            param.SigmaStart     = str2double(get(handlesCHIO.hSigmaStartCHIO,'String'));
            param.SigmaEnd       = str2double(get(handlesCHIO.hSigmaEndCHIO,'String'));
            param.SrinkwrapSteps = str2double(get(handlesCHIO.hSrinkwrapStepsCHIO,'String'));
            param.ShowSteps      = str2double(get(handlesCHIO.hShowStepsCHIO,'String'));
            param.Treshold       = str2double(get(handlesCHIO.hTresholdCHIO,'String'));
            param.WF             = str2double(get(handlesCHIO.hWeightCHIO,'String'));
            param.ViewVal        = str2double(get(handlesCHIO.hViewValCHIO,'String'));
            param.dataThreshold   = str2double(get(hdataThreshold,'String')); 
            metrics              = get(handlesER.hErrorMetric,'String');
            param.metricType     = metrics{get(handlesER.hErrorMetric,'Value')};
            
            param.sigma = param.SigmaStart; 
            param = CHIO3D(param,CHIOtab);
            disp('The object returned!');
        end       
        
        function performReconstructionSF(hObj,callbackdata)
            param.stopFlag = 0;            
            % Get parameters from the forms     
%             param.hBackgroundcheck  = get(hBackgroundcheck,'Value');
            param.ShowSupport    = get(hShowSupport,'Value');
            param.GPUcheck       = get(hGPUcheck,'Value');
            param.nSF            = str2double(get(handlesSF.hnSF,'String'));
            param.beta           = str2double(get(handlesSF.hBetaSF,'String'));
            param.SigmaStart     = str2double(get(handlesSF.hSigmaStartSF,'String'));
            param.SigmaEnd       = str2double(get(handlesSF.hSigmaEndSF,'String'));
            param.SrinkwrapSteps = str2double(get(handlesSF.hSrinkwrapStepsSF,'String'));
            param.ShowSteps      = str2double(get(handlesSF.hShowStepsSF,'String'));
            param.Treshold       = str2double(get(handlesSF.hTresholdSF,'String'));
            param.dataThreshold   = str2double(get(hdataThreshold,'String')); 
            metrics              = get(handlesER.hErrorMetric,'String');
            param.metricType     = metrics{get(handlesER.hErrorMetric,'Value')};
            
            param.sigma = param.SigmaStart;
            param = SF3D(param,SFtab);                        
            disp('The object returned!');
        end  
        
        function performReconstructionDM(hObj,callbackdata)      
            param.stopFlag = 0;            
            % Get parameters from the forms     
%             param.hBackgroundcheck  = get(hBackgroundcheck,'Value');
            param.ShowSupport    = get(hShowSupport,'Value');
            param.GPUcheck       = get(hGPUcheck,'Value');
            param.nDM            = str2double(get(handlesDM.hnDM,'String'));
            param.beta           = str2double(get(handlesDM.hBetaDM,'String'));
            param.SigmaStart     = str2double(get(handlesDM.hSigmaStartDM,'String'));
            param.SigmaEnd       = str2double(get(handlesDM.hSigmaEndDM,'String'));
            param.SrinkwrapSteps = str2double(get(handlesDM.hSrinkwrapStepsDM,'String'));
            param.ShowSteps      = str2double(get(handlesDM.hShowStepsDM,'String'));
            param.Treshold       = str2double(get(handlesDM.hTresholdDM,'String'));
            param.dataThreshold   = str2double(get(hdataThreshold,'String')); 
            metrics              = get(handlesER.hErrorMetric,'String');
            param.metricType     = metrics{get(handlesER.hErrorMetric,'Value')};            
            
            param.sigma = param.SigmaStart;
            param = DM3D(param,DMtab);
            disp('The object returned!');
        end
        
        function performReconstructionASR(hObj,callbackdata)      
            param.stopFlag = 0;            
            % Get parameters from the forms      
%             param.hBackgroundcheck  = get(hBackgroundcheck,'Value');
            param.ShowSupport    = get(hShowSupport,'Value');
            param.GPUcheck       = get(hGPUcheck,'Value');
            param.nASR           = str2double(get(handlesASR.hnASR,'String'));
            param.beta           = str2double(get(handlesASR.hBetaASR,'String'));
            param.SigmaStart     = str2double(get(handlesASR.hSigmaStartASR,'String'));
            param.SigmaEnd       = str2double(get(handlesASR.hSigmaEndASR,'String'));
            param.SrinkwrapSteps = str2double(get(handlesASR.hSrinkwrapStepsASR,'String'));
            param.ShowSteps      = param.SrinkwrapSteps;
            param.Treshold       = str2double(get(handlesASR.hTresholdASR,'String'));
            param.dataThreshold   = str2double(get(hdataThreshold,'String')); 
            metrics              = get(handlesER.hErrorMetric,'String');
            param.metricType     = metrics{get(handlesER.hErrorMetric,'Value')};
            
            param.sigma = param.SigmaStart;
            
            param = ASR3D(param,ASRtab);
            disp('The object returned!');
        end
        
        function performReconstructionRAAR(hObj,callbackdata)      
            param.stopFlag = 0;            
            % Get parameters from the forms     
%             param.hBackgroundcheck  = get(hBackgroundcheck,'Value');
            param.ShowSupport    = get(hShowSupport,'Value');
            param.GPUcheck       = get(hGPUcheck,'Value');
            param.nRAAR          = str2double(get(handlesRAAR.hnRAAR,'String'));
            param.beta           = str2double(get(handlesRAAR.hBetaRAAR,'String'));
            param.SigmaStart     = str2double(get(handlesRAAR.hSigmaStartRAAR,'String'));
            param.SigmaEnd       = str2double(get(handlesRAAR.hSigmaEndRAAR,'String'));
            param.SrinkwrapSteps = str2double(get(handlesRAAR.hSrinkwrapStepsRAAR,'String'));
            param.ShowSteps      = str2double(get(handlesRAAR.hShowStepsRAAR,'String'));
            param.Treshold       = str2double(get(handlesRAAR.hTresholdRAAR,'String'));
            param.dataThreshold   = str2double(get(hdataThreshold,'String')); 
            metrics              = get(handlesER.hErrorMetric,'String');
            param.metricType     = metrics{get(handlesER.hErrorMetric,'Value')};
            
            param.sigma = param.SigmaStart;
            
            param = RAAR3D(param,RAARtab);
            disp('The object returned!');
        end
        
        %========================= ALGORITHMS END ========================%        
        function performTransformation(hObj,callbackdata)
            param.nPoints  = str2double(get(hnAngles,'String'));
            param.gamma = str2double(get(hGammaArm,'String'));
            param.delta = str2double(get(hDeltaArm,'String'));            
            param.firstFrameAngle = str2double(get(hStartAngle,'String'));
            param.lastFrameAngle  = str2double(get(hEndAngle,'String'));            

            if get(hTheta,'Value')
                param.dth = (param.lastFrameAngle-param.firstFrameAngle)/(param.nPoints-1);
                param.dtilt = 0;
            else            
                param.dtilt = (param.lastFrameAngle-param.firstFrameAngle)/(param.nPoints-1);
                param.dth = 0;
            end 

            param = coordinateTransform(param);
            updateObjectRealT;
        end
                
        function defineSavePath(hObj,callbackdata)
            param.saveFolder = uigetdir;
            set(hsaveFolder,'String',param.saveFolder);
        end            
            
        function saveResult(hObj,callbackdata) 
            dataTime = getTimeStamp();
            O = param.O;
            Support = param.support;
            mkdir(fullfile(param.saveFolder,'reconstructions'));
            disp('Start saving the result!');
            hM = msgbox('Saving the result');
            if param.hBackgroundcheck  == 1
%                 B = param.B;
%                 save(fullfile('reconstructions',sprintf('RESULT_%s.mat',dataTime)),'O','Support','B','-v7.3');
            else
                save(fullfile(param.saveFolder,'reconstructions',sprintf('RESULT_%s.mat',dataTime)),'O','Support','-v7.3');
                savemat2vtk(fullfile(param.saveFolder,'reconstructions',sprintf('RESULT_%s.vtk',dataTime)),O);                
%                 print(mainF,'-dpng')
%                 param.centralPanelReconstruction
            end            
            delete(hM);            
            disp('Result is saved!')
        end
        
        %==================================================================
        % Import/prepare the data
        % Parameters and values definitions
        isoValReciprocal = 0.8;
        isoValReal = 0.8; 
        param.zoomVal = 3;
        
        [param.fileName, param.pathName] = openMATFile('data');
        param.saveFolder = param.pathName;
        
        data = dynamicName(fullfile(param.pathName, param.fileName));       
        
        data(isnan(data)) = 0;                
        Bmstop = (data == -1);                                             % Beamstop mask has to be created outside right now (-1 mask)  
        data(Bmstop) = 0;
        
        % Getting the amplitudes from measured intensity                      
        param.data    = single(sqrt(binning(double(data),str2double(get(hbinning,'String')))));       
                        
        % Binning and defining logical mask for the beamstop area
        param.Bmstop  = binning(Bmstop,str2double(get(hbinning,'String')));
        param.Bmstop  = round(param.Bmstop);

        clear Bmstop;                
        
        % Now we have the data in the memory ->    
                
        % Theoretical size of the real-space pixel
        param.dataSize       = size(param.data);               
        
        % Centering ?
%         param.data = centerMat(param.data);
        
        param.dataLog = log10(param.data);   % takes memory
        clear data pathName fileName;
        
        % Initial matrix of the object
        param.O = zeros(param.dataSize);                
%         param.B = rand(param.dataSize);        
        param.nShells = 62;                
        
        % Regularized amplitude constraint implementation (New Journal of Physics 12 2010 093042, Dilanian)
        param.RAC = 0;
        param.RACtype = 'POISS';
        
        algorithmCombinations = {' ','ER','HIO','SF','RAAR','DM','ASR'...
                                'ER+HIO',...
                                'HIO+ER',...
                                'ER+HIO+ER',...
                                'ER+HIO+SF',...
                                'ER+HIO+SF+ER',...
                                'HIO+ER+SF+ER',...
                                'ER+ASR',...
                                'ASR+ER'...
                                'ER+ASR+HIO',...
                                'ER+ASR+HIO+SF',...
                                'ER+RAAR+SF',...
                                'custom'};
        %==================================================================
        % Standart parameters for algorithms
        %============    n      beta   sigmaStart sigmaEnd shrinkwrapInt shrinkwrapThresh showRes         
        prepareER   = {'200',  '0.9',     '2',      '1',     '20',           '0.2',       '10'};
        prepareHIO  = {'50',   '0.7',     '5',      '1',     '10',           '0.2',       '10'};
        prepareCHIO = {'50',   '0.8',     '5',      '1',     '10',           '0.2',       '10',      '0.8',      '2'};
        prepareSF   = {'500',  '0.9',     '5',      '1',     '10',           '0.2',       '10'};
        prepareASR  = {'100',  '0.8',     '5',      '1',     '10',           '0.2',       '10'};
        prepareDM   = {'100',  '0.8',     '5',      '1',     '10',           '0.2',       '10'};
        prepareRAAR = {'100',  '0.8',     '5',      '1',     '10',           '0.2',       '10'};
        %===========    nTry   nLoop   sigmaStart sigmaEnd shrinkwrapInt shrinkwrapThresh showRes
        prepareMIX  = {'100',  '3',       '5',     '1',      '10',           '0.2',      '200'};
        
        %==================================================================
        fprintf('Data size: %d %d %d\n', param.dataSize);        
        
        % Must be in the input of the data        
        photonEnergy = str2double(get(hEnergy,'String'));
        param.sampleDetectorDistance = str2double(get(hSDD,'String'));
        param.detectorPixelSize = str2double(get(hDetectorPixel,'String'));
        param.dAngle = str2double(get(hAngularStep,'String'));
        param.wavelength = h*c/photonEnergy;
        
        param.realPixelSizeX = param.wavelength*param.sampleDetectorDistance/(param.detectorPixelSize*param.dataSize(2));
        param.realPixelSizeY = param.wavelength*param.sampleDetectorDistance/(param.detectorPixelSize*param.dataSize(1));
        param.realPixelSizeZ = param.wavelength/(param.dAngle*pi/180)/param.dataSize(3);
        
%         realPixelSizeZ = param.wavelength*param.sampleDetectorDistance/(param.detectorPixelSize*param.dataSize(3));		
        
        param.coordinateVectorX = (-round(param.dataSize(2))/2:round(param.dataSize(2))/2-1)*param.realPixelSizeX*1e9; % [nm]
        param.coordinateVectorY = (-round(param.dataSize(1))/2:round(param.dataSize(1))/2-1)*param.realPixelSizeY*1e9; % [nm]
        param.coordinateVectorZ = (-round(param.dataSize(3))/2:round(param.dataSize(3))/2-1)*param.realPixelSizeZ*1e9; % [nm]
		
        param.dQx = 1/(param.dataSize(2)*param.realPixelSizeX);
        param.dQy = 1/(param.dataSize(1)*param.realPixelSizeY);
        param.dQz = 1/(param.dataSize(3)*param.realPixelSizeZ);
		
        param.reciprocalVectorX = (-round(param.dataSize(2))/2:round(param.dataSize(2))/2-1)*param.dQx/1e9; % [nm^-1]
        param.reciprocalVectorY = (-round(param.dataSize(1))/2:round(param.dataSize(1))/2-1)*param.dQy/1e9; % [nm^-1]        
        param.reciprocalVectorZ = (-round(param.dataSize(3))/2:round(param.dataSize(3))/2-1)*param.dQz/1e9; % [nm^-1]
		                
        showDataCheckVal = get(hshowDataCheck,'Value');
        clf;% Clear figure before drawing a new one
        
        % ============================ GUI ================================
        % --- Create the controls
        % =================================================================  
        tgroup = uitabgroup('Parent', mainF);            
            tab1 = uitab('Parent', tgroup, 'Title', 'Load Data');
            tab2 = uitab('Parent', tgroup, 'Title', 'Reconstruction');
            tab3 = uitab('Parent', tgroup, 'Title', 'Evaluation');
            tab4 = uitab('Parent', tgroup, 'Title', 'Modify Data');
            
        % Initial area
        centralPanelData = uipanel('Parent',tab1,'Title','Initial Data','FontSize',...
            12,'Units','Normalized','Position',[.22 0.1 .77 .85]);                       
                                
        % Axes for 3D isosurface rendering
        
        leftP = uipanel('Parent',centralPanelData,'Title','Reciprocal space','FontSize',...
            10,'Units','Normalized','Position',[.01 0.01 0.5 0.98]); 
        rightP = uipanel('Parent',centralPanelData,'Title','Real space','FontSize',...
            10,'Units','Normalized','Position',[.51 0.01 0.48 0.98]);
        
        imAxData1 = axes('Parent',leftP);  zoom(0.8);     
        imAxData2 = axes('Parent',rightP); zoom(0.8);
        
        linkprop([imAxData1,imAxData2],'View');  
        
        % Show isosurface of the data if checked 
        if showDataCheckVal == 1
            updateObjectReci;
        end
        
        % Sliders for isosurface values %
        % Data
        uicontrol('Parent',tab1,'Style',...
            'slider','Min',0,'Max',1,...
            'Value',isoValReciprocal,'Units','Normalized',...
            'Position', [0.28 0.05 0.3 0.03],...
            'Callback', @slideIsosurfaceReciprocal); 
        
        % Reconstruction
        uicontrol('Parent',tab1,'Style',...
            'slider','Min',0,'Max',1,...
            'Value',isoValReciprocal,'Units','Normalized',...
            'Position', [0.68 0.05 0.3 0.03],...
            'Callback', @slideIsosurfaceReal); 
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Data tab creation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        uicontrol('Parent',tab1,'Style','text',...
            'String','Dzhigaev Dmitry & Young Young Kim 2018',...
            'Units','normalized','Position',[0.01 0.05 0.2 0.03]);
    
        leftPanelData = uipanel('Parent',tab1,'Title','Initializiation','FontSize',...
            12,'Units','Normalized','Position',[.01 0.1 .2 .85]);
        
        % Button for PHASOR restart
        uicontrol('Parent',leftPanelData,'Units','normalized',...
            'Position',[0.05 0.87 0.9 0.1],'String','Restart',...
            'Callback',@restoreGUI);
        
        uicontrol('Parent',leftPanelData,'Style','text',...
            'String','Save path...',...
            'Units','normalized','Position',[left1 0.79 width height])      ; 
        hsaveFolder = uicontrol('Parent',leftPanelData,'Style','edit',...
            'String',param.saveFolder,...
            'Units','normalized','Position',[0.1 0.78 0.7 height/1.5])      ;
        uicontrol('Parent',leftPanelData,'Units','normalized',...
            'Position',[0.81 0.78 0.1 height/1.5],'String','...',...
            'Callback',@defineSavePath);
        
        uicontrol('Parent',leftPanelData,'Style','text',...
            'String','Complexity of the object',...
            'Units','normalized','Position',[left1 0.7 width height])      ;        
                 
        param.hAmpCheck = uicontrol('Parent',leftPanelData,'Style','checkbox',...
            'String','Amplitude',...
            'Units','normalized','Position',[5*left1 0.7 width height])      ;
        
        param.hPhaseCheck = uicontrol('Parent',leftPanelData,'Style','checkbox',...
            'String','Phase',...
            'Units','normalized','Position',[2.2*left2-left1 0.7 width height])      ;                
        
        uicontrol('Parent',leftPanelData,'Style','text',...
            'String','Support estimate',...
            'Units','normalized','Position',[left1 0.6 width height])      ;
        
        bg = uibuttongroup('Parent',leftPanelData,'Visible','off',...
                  'Position',[5*left1 0.6 width*1.5 1.7*height]);
              
              % Handle for auto creation of the support
              param.hAutoSingle = uicontrol(bg,'Style','radiobutton',...
                  'String','Auto','Units','Normalized',...
                  'Position',[left1 0.1 5*width 8*height]);
              
              % Hadle for the pre-defined support
             uicontrol('Parent',bg,'Style','radiobutton',...
                  'String','Pre-Defined','Units','Normalized',...
                  'Position',[left1 0.6 5*width 8*height]);              
        
        bg.Visible = 'on';
        
        uicontrol('Parent',leftPanelData,'Style','text',...
            'String','Data threshold',...
            'Units','normalized','Position',[left1 0.52 0.4 height])      ;        
        hdataThreshold = uicontrol('Parent',leftPanelData,'Style','edit',...
            'String',0,...
            'Units','normalized','Position',[0.5 0.55 0.2 height/1.5])      ;
        
        uicontrol('Parent',leftPanelData,'Style','text',...
            'String','Remove phase ramp',...
            'Units','normalized','Position',[left1 0.41 0.9 height])      ;
                
        uicontrol('Parent',leftPanelData,'String','-','Units','normalized',...
            'Position',[left1 0.38 0.4 0.05],...
            'Callback',@recenterCallback1)
        
        uicontrol('Parent',leftPanelData,'String','+','Units','normalized',...
            'Position',[0.5 0.38 0.4 0.05],...
            'Callback',@recenterCallback2)
        
%         uicontrol('Parent',leftPanelData,'String','Show background!','Units','normalized',...
%             'Position',[left1 0.28 0.8 0.1],...
%             'Callback',@showBackgroundCallback) 
        
        uicontrol('Parent',leftPanelData,'String','Create Object!','Units','normalized',...
            'Position',[left1 0.18 0.8 0.1],...
            'Callback',@createObjectCallback) 
        
        uicontrol('Parent',leftPanelData,'String','Update Object!','Units','normalized',...
            'Position',[left1 0.08 0.8 0.1],...
            'Callback',@updateObjectReal)                       
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Reconstruction tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        hGPUcheck = uicontrol('Parent',tab2,'Style','checkbox',...
            'String','GPU-acceleration','Value',0,...
            'Units','normalized','Position',[.01 0.05 width/2 height])    ; 
        
        hShowSupport = uicontrol('Parent',tab2,'Style','checkbox',...
            'String','Support Outline','Value',0,...
            'Units','normalized','Position',[width/2 0.05 width*3 height])    ; 
%         hBackgroundcheck = uicontrol('Parent',tab2,'Style','checkbox',...
%             'String','correct for background','Value',0,...
%             'Units','normalized','Position',[0.1 0.05 width*3 height])    ;
        
        param.hBackgroundcheck = 0;
        
        leftPanelReconstruction = uipanel('Parent',tab2,'Title','Reconstruction control',...
            'FontSize',12,'Units','Normalized',...
            'Position',[.01 0.1 .2 .85]);
        
        algoGroup = uitabgroup('Parent', leftPanelReconstruction);
            ERtab   = uitab('Parent', algoGroup, 'Title', 'ER');
            HIOtab  = uitab('Parent', algoGroup, 'Title', 'HIO');
            CHIOtab = uitab('Parent', algoGroup, 'Title', 'CHIO');
            SFtab   = uitab('Parent', algoGroup, 'Title', 'SF');
            DMtab   = uitab('Parent', algoGroup, 'Title', 'DM');
            RAARtab = uitab('Parent', algoGroup, 'Title', 'RAAR');
            ASRtab  = uitab('Parent', algoGroup, 'Title', 'ASR');
            GAtab   = uitab('Parent', algoGroup, 'Title', 'GA');
            MIXtab  = uitab('Parent', algoGroup, 'Title', 'Pattern'); 
        
        % Reconstruction controls for ER ##################################  
        handlesER = guiER(ERtab,width,height,left1,left2,prepareER);
        
        uicontrol('Parent',ERtab,'Style','text',...
            'String','Remove phase ramp',...
            'Units','normalized','Position',[left1 0.41 0.9 height])      ;
                
        uicontrol('Parent',ERtab,'String','-','Units','normalized',...
            'Position',[left1 0.38 0.4 0.05],...
            'Callback',@recenterCallback1)
        
        uicontrol('Parent',ERtab,'String','+','Units','normalized',...
            'Position',[0.5 0.38 0.4 0.05],...
            'Callback',@recenterCallback2)
        
        uicontrol('Parent',ERtab,'String','Run ER','Units','normalized',...
            'Position',[left1 0.28 0.8 0.1],...
            'Callback',{@performReconstructionER})                       ;               
        
        uicontrol('Parent',ERtab,'String','Save Result','Units','normalized',...
            'Position',[left1 0.08 0.8 0.1],...
            'Callback',@saveResult)                                        ;  
        %##################################################################                
        
        % Reconstruction controls for HIO #################################
        handlesHIO = guiHIO(HIOtab,width,height,left1,left2,prepareHIO);
         
        uicontrol('Parent',HIOtab,'Style','text',...
            'String','Remove phase ramp',...
            'Units','normalized','Position',[left1 0.41 0.9 height])      ;
                
        uicontrol('Parent',HIOtab,'String','-','Units','normalized',...
            'Position',[left1 0.38 0.4 0.05],...
            'Callback',@recenterCallback1)
        
        uicontrol('Parent',HIOtab,'String','+','Units','normalized',...
            'Position',[0.5 0.38 0.4 0.05],...
            'Callback',@recenterCallback2) 
        
        uicontrol('Parent',HIOtab,'String','Run HIO','Units','normalized',...
            'Position',[0.1 0.28 0.8 0.1],...
            'Callback',@performReconstructionHIO)                      ;
        
        uicontrol('Parent',HIOtab,'String','Save Result','Units','normalized',...
            'Position',[left1 0.08 0.8 0.1],...
            'Callback',@saveResult) 
        %################################################################## 
        
        % Reconstruction controls for CHIO ################################
        handlesCHIO = guiCHIO(CHIOtab,width,height,left1,left2,prepareCHIO);
        
        uicontrol('Parent',CHIOtab,'Style','text',...
            'String','Remove phase ramp',...
            'Units','normalized','Position',[left1 0.41 0.9 height])      ;
                
        uicontrol('Parent',CHIOtab,'String','-','Units','normalized',...
            'Position',[left1 0.38 0.4 0.05],...
            'Callback',@recenterCallback1)
        
        uicontrol('Parent',CHIOtab,'String','+','Units','normalized',...
            'Position',[0.5 0.38 0.4 0.05],...
            'Callback',@recenterCallback2) 
        
        uicontrol('Parent',CHIOtab,'String','Run CHIO','Units','normalized',...
            'Position',[0.1 0.28 0.8 0.1],...
            'Callback',@performReconstructionCHIO)                      ;
        
        uicontrol('Parent',CHIOtab,'String','Save Result','Units','normalized',...
            'Position',[left1 0.08 0.8 0.1],...
            'Callback',@saveResult) 
        %################################################################## 
        
        % Reconstruction controls for SF ##################################
        handlesSF = guiSF(SFtab,width,height,left1,left2,prepareSF);
        
        uicontrol('Parent',SFtab,'Style','text',...
            'String','Remove phase ramp',...
            'Units','normalized','Position',[left1 0.41 0.9 height])      ;
                
        uicontrol('Parent',SFtab,'String','-','Units','normalized',...
            'Position',[left1 0.38 0.4 0.05],...
            'Callback',@recenterCallback1)
        
        uicontrol('Parent',SFtab,'String','+','Units','normalized',...
            'Position',[0.5 0.38 0.4 0.05],...
            'Callback',@recenterCallback2) 
        
        uicontrol('Parent',SFtab,'String','Run SF','Units','normalized',...
            'Position',[left1 0.28 0.8 0.1],...
            'Callback',{@performReconstructionSF})                       ;               
        
        uicontrol('Parent',SFtab,'String','Save Result','Units','normalized',...
            'Position',[left1 0.08 0.8 0.1],...
            'Callback',@saveResult)                                        ;  
        %##################################################################
        
        % Reconstruction controls for ASR ##################################
        handlesASR = guiASR(ASRtab,width,height,left1,left2,prepareASR);
        
        uicontrol('Parent',ASRtab,'Style','text',...
            'String','Remove phase ramp',...
            'Units','normalized','Position',[left1 0.41 0.9 height])      ;
                
        uicontrol('Parent',ASRtab,'String','-','Units','normalized',...
            'Position',[left1 0.38 0.4 0.05],...
            'Callback',@recenterCallback1)
        
        uicontrol('Parent',ASRtab,'String','+','Units','normalized',...
            'Position',[0.5 0.38 0.4 0.05],...
            'Callback',@recenterCallback2) 
        
        uicontrol('Parent',ASRtab,'String','Run ASR','Units','normalized',...
            'Position',[left1 0.28 0.8 0.1],...
            'Callback',{@performReconstructionASR})                       ;               
        
        uicontrol('Parent',ASRtab,'String','Save Result','Units','normalized',...
            'Position',[left1 0.08 0.8 0.1],...
            'Callback',@saveResult)                                        ;  
        %##################################################################
        
        % Reconstruction controls for DM ###################################
        handlesDM = guiDM(DMtab,width,height,left1,left2,prepareDM);        
        
        uicontrol('Parent',DMtab,'Style','text',...
            'String','Remove phase ramp',...
            'Units','normalized','Position',[left1 0.41 0.9 height])      ;
                
        uicontrol('Parent',DMtab,'String','-','Units','normalized',...
            'Position',[left1 0.38 0.4 0.05],...
            'Callback',@recenterCallback1)
        
        uicontrol('Parent',DMtab,'String','+','Units','normalized',...
            'Position',[0.5 0.38 0.4 0.05],...
            'Callback',@recenterCallback2) 
        
        uicontrol('Parent',DMtab,'String','Run DM','Units','normalized',...
            'Position',[left1 0.28 0.8 0.1],...
            'Callback',{@performReconstructionDM})                       ;               
        
        uicontrol('Parent',RAARtab,'String','Save Result','Units','normalized',...
            'Position',[left1 0.08 0.8 0.1],...
            'Callback',@saveResult)                                        ;  
        %##################################################################
        
        % Reconstruction controls for RAAR ################################
        handlesRAAR = guiRAAR(RAARtab,width,height,left1,left2,prepareRAAR);        
        
        uicontrol('Parent',RAARtab,'Style','text',...
            'String','Remove phase ramp',...
            'Units','normalized','Position',[left1 0.41 0.9 height])      ;
                
        uicontrol('Parent',RAARtab,'String','-','Units','normalized',...
            'Position',[left1 0.38 0.4 0.05],...
            'Callback',@recenterCallback1)
        
        uicontrol('Parent',RAARtab,'String','+','Units','normalized',...
            'Position',[0.5 0.38 0.4 0.05],...
            'Callback',@recenterCallback2) 
        
        uicontrol('Parent',RAARtab,'String','Run RAAR','Units','normalized',...
            'Position',[left1 0.28 0.8 0.1],...
            'Callback',{@performReconstructionRAAR})                       ;               
        
        uicontrol('Parent',RAARtab,'String','Run RAAR','Units','normalized',...
            'Position',[left1 0.28 0.8 0.1],...
            'Callback',{@performReconstructionRAAR})                       ;               
        
        uicontrol('Parent',RAARtab,'String','Save Result','Units','normalized',...
            'Position',[left1 0.08 0.8 0.1],...
            'Callback',@saveResult)                                        ;  
        %##################################################################
        
        % Left panel with a reconstructin parameters GA ###################
        handlesGA = guiGA(GAtab,width,height,left1,left2,algorithmCombinations);                        
        
        uicontrol('Parent',GAtab,'Style','text',...      
            'String','Pattern',...                              
            'Units','normalized','Position',[0.05 0.76 0.25 height])     ;                                                                                     
        handlesGA.hAlgoPatternGA = uicontrol('Parent',GAtab,'Style',...     
            'popup','String',algorithmCombinations,...                                      
            'Units','normalized','Position',[0.35 0.76 0.55 height],...
            'Callback',@setPatternGA);  
        
        uicontrol('Parent',GAtab,'String','Run genetic algorithm','Units','normalized',...
            'Position',[0.1 0.05 0.8 0.1],...
            'Callback',@performReconstructionGA)                      ; 
                
        % Left panel with a reconstructin parameters MIX ##################                                                                                                          
        uicontrol('Parent',MIXtab,'Style','text',...
            'String','Number of Trials / Loops',...
            'Units','normalized','Position',[left1 0.9 width height])      ;        
        hnMIX = uicontrol('Parent',MIXtab,'Style','edit',...
            'String',prepareMIX{1},...
            'Units','normalized','Position',[left2 0.9 width height])      ;
        
        hnLoop = uicontrol('Parent',MIXtab,'Style','edit',...
            'String',prepareMIX{2},...
            'Units','normalized','Position',[left2+width 0.9 width height])      ;
        
        uicontrol('Parent',MIXtab,'Style','text',...      
            'String','Pattern',...                              
            'Units','normalized','Position',[left1 0.83 width height])     ;                                                                                     
        hBetaMIX = uicontrol('Parent',MIXtab,'Style',...     
            'popup','String',algorithmCombinations,...                                      
            'Units','normalized','Position',[left2 0.83 2*width height],...
            'Callback',@setPattern)     ;                         
        
        uicontrol('Parent',MIXtab,'Style','text',...
            'String','Sigma interval',...
            'Units','normalized','Position',[left1 0.76 width height])     ;        
        hSigmaStartMIX = uicontrol('Parent',MIXtab,'Style','edit',...
            'String',prepareMIX{3},...
            'Units','normalized','Position',[left2 0.76 width/2 height])   ;        
        hSigmaEndMIX = uicontrol('Parent',MIXtab,'Style','edit',...
            'String',prepareMIX{4},...
            'Units','normalized','Position',[left2+width/2 0.76 width/2 height]);
        
        uicontrol('Parent',MIXtab,'Style','text',...
            'String','Srinkwrap interval',...
            'Units','normalized','Position',[left1 0.69 width height])     ;        
        hSrinkwrapStepsMIX = uicontrol('Parent',MIXtab,'Style','edit',...
            'String',prepareMIX{5},...
            'Units','normalized','Position',[left2 0.69 2*width height])     ;
        
        uicontrol('Parent',MIXtab,'Style','text',...
            'String','Treshold for Shrinkwrap',...
            'Units','normalized','Position',[left1 0.62 width height])     ;       
        hTresholdMIX = uicontrol('Parent',MIXtab,'Style','edit',...
            'String',prepareMIX{6},...
            'Units','normalized','Position',[left2 0.62 2*width height])     ;        
        
        uicontrol('Parent',MIXtab,'Style','text',...
            'String','Show results step',...
            'Units','normalized','Position',[left1 0.55 width height])     ;       
        hShowStepsMIX = uicontrol('Parent',MIXtab,'Style','edit',...
            'String',prepareMIX{7},...
            'Units','normalized','Position',[left2 0.55 2*width height])     ;
        
        uicontrol('Parent',MIXtab,'Style','text',...
            'String','Remove phase ramp',...
            'Units','normalized','Position',[left1 0.41 0.9 height])      ;
                
        uicontrol('Parent',MIXtab,'String','-','Units','normalized',...
            'Position',[left1 0.38 0.4 0.05],...
            'Callback',@recenterCallback1)
        
        uicontrol('Parent',MIXtab,'String','+','Units','normalized',...
            'Position',[0.5 0.38 0.4 0.05],...
            'Callback',@recenterCallback2) 
        
        uicontrol('Parent',MIXtab,'String','Run reconstruction pattern','Units','normalized',...
            'Position',[0.1 0.28 0.8 0.1],...
            'Callback',@performReconstructionPattern)                      ;        
        %################################################################## 
        
        %##################################################################
        % Monitor area
        param.centralPanelReconstruction = uipanel('Parent',tab2,'Title','Reconstruction monitors','FontSize',...
            12,'Units','Normalized','Position',[.22 0.1 .77 .85]);              
        %##################################################################
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Evaluation tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        leftPanelEvaluation = uipanel('Parent',tab3,'Title','Evaluation control',...
            'FontSize',12,'Units','Normalized',...
            'Position',[.01 0.1 .2 .85]);
        
        plotGroup = uitabgroup('Parent', leftPanelEvaluation);
            DET2LABtab = uitab('Parent', plotGroup, 'Title', 'Det2Lab');
            PSDtab     = uitab('Parent', plotGroup, 'Title', 'PSD');
            FSCtab     = uitab('Parent', plotGroup, 'Title', 'FSC');
            PRTFtab    = uitab('Parent', plotGroup, 'Title', 'PRTF');              
        
        centralPanelTransformation = uipanel('Parent',tab3,'Title','Transformation result','FontSize',...
            12,'Units','Normalized','Position',[.22 0.1 .77 .85]);
        
        hAX = axes('Parent',centralPanelTransformation);                                 
                        
        function updateObjectRealT(hObj,callbackdata)         
            cla(hAX);
            axes(hAX); 
            isosurface(abs(param.O)./max(max(max(abs(param.O)))),isoValReal,angle(param.O)); 
            xlabel('x, [nm]'); ylabel('y, [nm]'); zlabel('z, [nm]');
            axis tight;
            h3 = light; h3.Position = [-1 -1 -1];  
            h4 = light; h4.Position= [1 1 1];  
            rotate3d on;
            colormap jet;
            c = colorbar(hAX,'Location','northoutside');
            c.Label.String = 'Phase, [rad]';
            drawnow();
            axis image; 
            disp('Object updated!');
        end        

        function slideIsosurfaceRealT(hObj,callbackdata)
            isoValReal = get(hObj,'Value');
            updateObjectRealT;
        end
            
        % Det2Lab transformation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        uicontrol('Parent',DET2LABtab,'Style','text',...
            'String','Number of points',...
            'Units','normalized','Position',[left1 0.9 width height])      ;        
        hnAngles = uicontrol('Parent',DET2LABtab,'Style','edit',...
            'String',param.dataSize(3),...
            'Units','normalized','Position',[left2 0.9 width height])      ;
        
        uicontrol('Parent',DET2LABtab,'Style','text',...      
            'String','Gamma angle',...                              
            'Units','normalized','Position',[left1 0.83 width height])     ;                                                                                     
        hGammaArm = uicontrol('Parent',DET2LABtab,'Style',...     
            'edit','String',24,...                                      
            'Units','normalized','Position',[left2 0.83 width height])     ;
        
        uicontrol('Parent',DET2LABtab,'Style','text',...      
            'String','Delta angle',...                              
            'Units','normalized','Position',[left1 0.76 width height])     ;                                                                                     
        hDeltaArm = uicontrol('Parent',DET2LABtab,'Style',...     
            'edit','String',0.4,...                                      
            'Units','normalized','Position',[left2 0.76 width height])     ;         
                
        uicontrol('Parent',DET2LABtab,'Style','text',...
            'String','Scan interval',...
            'Units','normalized','Position',[left1 0.69 width height])     ;        
        hStartAngle = uicontrol('Parent',DET2LABtab,'Style','edit',...
            'String',11.65,...
            'Units','normalized','Position',[left2 0.69 width/2 height])   ;        
        hEndAngle = uicontrol('Parent',DET2LABtab,'Style','edit',...
            'String',13,...
            'Units','normalized','Position',[left2+width/2 0.69 width/2 height]);                        
        
        uicontrol('Parent',DET2LABtab,'Style','text',...
            'String','Scan type',...
            'Units','normalized','Position',[left1 0.58 width height])     ;
        
        bgScanType = uibuttongroup('Parent',leftPanelEvaluation,'Visible','off',...
                  'Position',[5*left1 0.55 width*1.5 1.7*height]);
              
              % Handle for auto creation of the support
              hTheta = uicontrol(bgScanType,'Style','radiobutton',...
                  'String','Phi scan','Units','Normalized',...
                  'Position',[left1 0.1 5*width 8*height]);
              
              % Hadle for the pre-defined support
              uicontrol('Parent',bgScanType,'Style','radiobutton',...
                  'String','Omega scan','Units','Normalized',...
                  'Position',[left1 0.6 5*width 8*height]);              
        
        bgScanType.Visible = 'on';        
        
        uicontrol('Parent',DET2LABtab,'Style','text',...
            'String','Isosurface level',...
            'Units','normalized','Position',[left1 0.45 0.8 height])     ;  
        
        uicontrol('Parent',leftPanelEvaluation,'Style',...
            'slider','Min',0,'Max',1,...
            'Value',isoValReal,'Units','Normalized',...
            'Position', [0.08 0.40 0.8 0.05],...
            'Callback', @slideIsosurfaceRealT); 
            drawnow;
        
        uicontrol('Parent',DET2LABtab,'String','Transform','Units','normalized',...
            'Position',[left1 0.28 0.8 0.1],...
            'Callback',@performTransformation)                       ;               
        
        uicontrol('Parent',DET2LABtab,'String','Save Result','Units','normalized',...
            'Position',[left1 0.08 0.8 0.1],...
            'Callback',@saveResult)
            
        % Spectral analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        uicontrol('Parent',PSDtab,'Style','text',...
            'String','Number of bins',...
            'Units','normalized','Position',[left1 0.9 width height])      ;        
        hnBinsPSD = uicontrol('Parent',PSDtab,'Style','edit',...
            'String','100',...
            'Units','normalized','Position',[left2 0.9 width height])      ;
        
        uicontrol('Parent',PSDtab,'String','Calculate PSD','Units','normalized',...
            'Position',[left1 0.28 0.8 0.1],...
            'Callback',{@calculatePSD})                                    ;
        
        uicontrol('Parent',PRTFtab,'Style','text',...
            'String','Number of bins',...
            'Units','normalized','Position',[left1 0.9 width height])      ;        
        hnBinsPRTF = uicontrol('Parent',PRTFtab,'Style','edit',...
            'String','100',...
            'Units','normalized','Position',[left2 0.9 width height])      ;
        
        uicontrol('Parent',PRTFtab,'String','Calculate PRTF','Units','normalized',...
            'Position',[left1 0.28 0.8 0.1],...
            'Callback',{@calculatePRTF}) 
        %##################################################################    
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Data Modification tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        uicontrol('Parent',tab4,'Style','text',...
            'String','Dzhigaev Dmitry & Young Young Kim 2018',...
            'Units','normalized','Position',[0.01 0.05 0.2 0.03]);
    
        leftPanelModData = uipanel('Parent',tab4,'Title','Tools','FontSize',...
            12,'Units','Normalized','Position',[.01 0.1 .2 .85]);
        centralPanelModData = uipanel('Parent',tab4,'Title','Initial Data','FontSize',...
            12,'Units','Normalized','Position',[.22 0.1 .77 .85]); 
        
        axMod = axes('Parent', centralPanelModData);     
        frameVal = 1;
        
        uicontrol('Parent',leftPanelModData,'String','Detector mask','Units','normalized',...
            'Position',[left1 0.8 0.8 0.1],...
            'Callback',{@loadDetectorMask}) 
        
        % Data frames
        uicontrol('Parent',tab4,'Style',...
            'slider','Min',1,'Max',param.dataSize(3),...
            'Value',1,'Units','Normalized',...
            'Position', [0.28 0.05 0.6 0.03],...
            'SliderStep', [1/(param.dataSize(3)-1) 1/(param.dataSize(3)-1)],...
            'Callback', @slideFrames); 
    end
end
