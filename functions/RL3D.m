% RL core %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function param = RL3D(param,RLtab) 
    uicontrol('Parent',RLtab,'String','Stop RL','Units','normalized',...
        'Position',[0.1 0.18 0.8 0.1],...
        'Callback',@stopReconstruction);

    function stopReconstruction(hObj,callbackdata)            
        param.stopFlag = 1; 
    end                

    zoomVal = 2;
    
    framesToShow  = 1:param.ShowSteps: param.nRL ;
    framesToShrink = 1:param.SrinkwrapSteps: param.nRL ;
    param.SigmaStart = param.sigma;
    ErrR = zeros(1,param.nRL);

    if param.GPUcheck == 1
        gpuDevice(1);
        param.data = gpuArray(param.data);
        param.O = gpuArray(param.O);
        ErrR = gpuArray(ErrR);
    end
    inFt_old = zeros(param.dataSize);
    
    for ii = 1:param.nRL
        if param.stopFlag == 0
            fprintf('RL iteration: %d\n',ii);                                      
                        
            
            inFT = fftNc(param.O);
            % Following J Clarck
            if ii == 1
                del_I = abs(inFT).^2;
            else
                del_I = 2*abs(inFT).^2-abs(inFt_old).^2;
            end
                        
            param.gamm = param.gamm.*(convn(del_I,param.data.^2./convn(del_I,param.gamm)));
            
            I_pck = convn(abs(inFt).^2,param.gamm);
            
            inFT_update = inFT.*(param.data./sqrt(I_pck));
                        
            param.O = PS(ifftNc(inFT_update),param.support); % Support projection operator                                            

            if ismember(ii,framesToShrink) 
                [param.support, param.sigma] = shrinkWrap(param,ii,'nRL');
            end

            if ismember(ii,framesToShow)
                Oftshow = fftNc(param.O);
                ErrR(ii) = sum(sum(sum((abs(Oftshow).*abs(param.Bmstop-1)-param.data).^2)))/sum(sum(sum(param.data.^2))); % Real space error for HIO
                showProgress(param,Oftshow,ErrR,zoomVal);                        
            end
            
            inFT_old = inFT;
        
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