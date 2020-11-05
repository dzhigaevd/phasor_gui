% DM core %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function param = DM3D(param,DMtab)        
    uicontrol('Parent',DMtab,'String','Stop DM','Units','normalized',...
        'Position',[0.1 0.18 0.8 0.1],...
        'Callback',@stopReconstruction);

    function stopReconstruction(hObj,callbackdata)            
        param.stopFlag = 1; 
    end

    % Mask for the data threshold
    param.dataMask = param.data>param.dataThreshold;
    
    gamma_S = -1/param.beta;
    gamma_M = 1/param.beta;
    
    framesToShow  = 1:param.ShowSteps: param.nDM ;
    framesToShrink = 1:param.SrinkwrapSteps: param.nDM ;
    param.SigmaStart = param.sigma;

    ErrR = zeros(1,param.nDM);

    if param.GPUcheck == 1
        gpuDevice(1);
        param.data = gpuArray(param.data);
        param.O = gpuArray(param.O);
        ErrR = gpuArray(ErrR);
    end

    for ii = 1:param.nDM
        if param.stopFlag == 0
            fprintf('DM iteration: %d\n',ii);          
            
            % Veit Elser definition 
            PMdummy = PM(param);
            PSdummy = PS(param.O,param.support);
            
            param.O = param.O...
                + param.beta*(PS(PMdummy+gamma_M.*(PMdummy-param.O),param.support)...
                -PM_dm(PSdummy+gamma_S.*(PSdummy-param.O),param.Bmstop,param.data,param.dataMask));
            
            if ismember(ii,framesToShrink)        
                [param.support, param.sigma] = shrinkWrap(param,ii,'nDM');
            end
            
            if ismember(ii,framesToShow)
                ErrR(ii) = calculateMetric(param);
                showProgress(param,fft2c(sum(param.O.*param.support,3)),ErrR);                        
            end
        elseif param.stopFlag == 1
            break;
        end  
        drawnow();
    end
    
    % Grab everything from GPU
    param.O = gather(param.O);
    param.support = gather(param.support);
    param.data = gather(param.data);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%