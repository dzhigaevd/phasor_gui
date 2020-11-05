function param = createObject(param)            
            
    if get(param.hAutoSingle,'Value') == 1
        % Creation of the support first
        autoCorr = abs(fftNc(param.data.^2));   
        param.support = (autoCorr./max(autoCorr(:))) > 0.1;
    else                
        param.support = dynamicName(openMATFile('support'));
    end

    valueAmp   = get(param.hAmpCheck, 'Value');
    valuePhase = get(param.hPhaseCheck, 'Value');

    % Initialize the starting guess
    if valueAmp == 1 && valuePhase == 0
        out = rand(param.dataSize).*param.support;
    elseif valueAmp == 0 && valuePhase == 1
        out = ones(param.dataSize).*exp(1j*(-pi+2*pi.*rand(param.dataSize))).*param.support;
    elseif valueAmp == 1 && valuePhase == 1
        out = rand(param.dataSize).*exp(1j*(-pi+2*pi.*rand(param.dataSize))).*param.support;
    elseif valueAmp == 0 && valuePhase == 0
        out = ones(param.dataSize).*param.support;
    end
    
    param.O = out;
    disp('Object created!');

    % Create a log-file for this object case            
end