function param = RAAR3D(param,RAARtab)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    uicontrol('Parent',RAARtab,'String','Stop RAAR','Units','normalized',...
        'Position',[0.1 0.18 0.8 0.1],...
        'Callback',@stopReconstruction);

    function stopReconstruction(hObj,callbackdata)            
        param.stopFlag = 1; 
    end                

    % Mask for the data threshold
    param.dataMask = param.data>param.dataThreshold;
    
    framesToShow  = 1:param.ShowSteps: param.nRAAR ;
    framesToShrink = 1:param.SrinkwrapSteps: param.nRAAR ;
    param.SigmaStart = param.sigma;

    ErrR = zeros(1,param.nRAAR);

    if param.GPUcheck == 1
        gpuDevice(1);
        param.data = gpuArray(param.data);
        param.O = gpuArray(param.O);
        ErrR = gpuArray(ErrR);
    end
    
    for ii = 1:param.nRAAR
        if param.stopFlag == 0
            fprintf('RAAR iteration: %d\n',ii);                                        

            Obuffer = PM(param); % Modulus projection operator 

            param.O = PS(2*Obuffer,param.support)-PS(param.O,param.support)+0.5*param.O+(1-param.beta)*Obuffer; % Support projection operator                                            

            if ismember(ii,framesToShrink) 
                [param.support, param.sigma] = shrinkWrap(param,ii,'nRAAR');
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

    % Grab everything from GPU
    param.O = gather(param.O);
    param.support = gather(param.support);
    param.data = gather(param.data);

end

