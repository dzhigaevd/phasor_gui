% Continous HIO core %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function param = CHIO3D(param,CHIOtab)        
    uicontrol('Parent',CHIOtab,'String','Stop CHIO','Units','normalized',...
    'Position',[0.1 0.18 0.8 0.1],...
    'Callback',@stopReconstruction);

    function stopReconstruction(hObj,callbackdata)            
        param.stopFlag = 1; 
    end
    
    % Mask for the data threshold
    param.dataMask = param.data>param.dataThreshold;
    
    framesToShow  = 1:param.ShowSteps: param.nCHIO ;
    framesToShrink = 1:param.SrinkwrapSteps: param.nCHIO ;
    param.SigmaStart = param.sigma;
    ErrR = zeros(1,param.nCHIO);
    
    if param.GPUcheck == 1
        gpuDevice(1);
        param.data = gpuArray(param.data);
        param.O = gpuArray(param.O);
%         param.B = gpuArray(param.B);
        ErrR = gpuArray(ErrR);
    end
    
    for ii = 1:param.nCHIO
        if param.stopFlag == 0
            fprintf('CHIO iteration: %d\n',ii);         
            % Far-field of the exit surface wave
            Oold = param.O; % g(k)

            if param.hBackgroundcheck  == 1
%                 [Obuffer,param.B] = PM(param.O,param.Bmstop,param.data,param.B); % Modulus projection operator 
            else
                Obuffer = PM(param); % Modulus projection operator
            end
                       %condition1 
                       C1 = PS(Obuffer,param.support); % Support projection operator
                       C1(C1 < param.alpha*Oold) = 0;
                       %condition2
                       C2 = Oold - ((1-param.alpha)/param.alpha)*Obuffer;
                       C2 = PS(C2,param.support);
                       C2(C1~=0) = 0;
                       %condition3
                       param.O = C1 + C2 + (Oold-param.beta*Obuffer).*abs(param.support-1);
                        
                       if param.GPUcheck == 0
                           com = round(ndimCOM(abs(param.O), 'auto'));
                           SC = round(size(param.data)/2);
                           TR = [SC(2), SC(1), SC(3)] - [com(2), com(1), com(3)];
                           param.O = imtranslate(param.O, TR);
                       end
                  if ismember(ii,framesToShrink)        
                      [param.support, param.sigma] = shrinkWrap(param,ii,'nCHIO');
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
%     param.B = gather(param.B);
    
    if param.GPUcheck == 1
       com = round(ndimCOM(abs(param.O), 'auto'));
       SC = round(size(param.data)/2);
       TR = [SC(2), SC(1), SC(3)] - [com(2), com(1), com(3)];
       param.O = imtranslate(param.O, TR);
       param.support = imtranslate(param.support, TR);
    end
end
                   