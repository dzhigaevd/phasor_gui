% ER core %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function param = ER3D(param,ERtab) 
    uicontrol('Parent',ERtab,'String','Stop ER','Units','normalized',...
        'Position',[0.1 0.18 0.8 0.1],...
        'Callback',@stopReconstruction);

    function stopReconstruction(hObj,callbackdata)            
        param.stopFlag = 1; 
    end                
    
    % Mask for the data threshold
    param.dataMask = param.data>param.dataThreshold;
    
    framesToShow  = 1:param.ShowSteps: param.nER ;
    framesToShrink = 1:param.SrinkwrapSteps: param.nER ;
    param.SigmaStart = param.sigma;
    ErrR = zeros(1,param.nER);

    if param.GPUcheck == 1
        gpuDevice(1);
        param.data = gpuArray(param.data);
        param.O = gpuArray(param.O);
%         param.B = gpuArray(param.B);
        ErrR = gpuArray(ErrR);
    end

    for ii = 1:param.nER
        if param.stopFlag == 0
            fprintf('ER iteration: %d\n',ii);                                      
            
            if param.hBackgroundcheck  == 1
%                 [param.O, param.B] = PM(param.O,param.Bmstop,param.data,param.B);
            else
                param.O = PM(param); % Magnitude projection operator
            end
            
            param.O = PS(param.O,param.support); % Support projection operator   
            
            if param.hBackgroundcheck  == 1
                param.B = radialAvg3Dset(param,param.nShells);            
            end
            
            if ismember(ii,framesToShrink) 
                [param.support, param.sigma] = shrinkWrap(param,ii,'nER');
            end

            if ismember(ii,framesToShow)
                ErrR(ii) = calculateMetric(param);
                showProgress(param,fftNc(param.O.*param.support),ErrR);                        
            end
        elseif param.stopFlag == 1
            break;
        end
        drawnow();
    end 
    param.stopFlag
    % Grab everything from GPU
%     param.B = gather(param.B);
    param.O = gather(param.O);
    param.support = gather(param.support);
    param.data = gather(param.data);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       