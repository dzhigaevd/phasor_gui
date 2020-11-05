function out = PM(param)
%     if param.B
%         
%         inFT = fftNc(param.O);
%         Bufferdata = inFT(param.Bmstop==1);
%         temp1 = param.data.*inFT./sqrt(abs(inFT).^2+param.B.^2);
%         param.B = param.data.*param.dataMask.*param.B./sqrt(abs(inFT).^2+param.B.^2);
%         inFT = temp1;
%         inFT(Bmstop==1) = Bufferdata;
%         out = ifftNc(inFT); % g'(k)
%     else
    if param.RAC % apply Regularized Amplitude Constraint
        inFT = fftNc(param.O);
        Bufferdata = inFT(param.Bmstop==1);
        switch param.RACtype
            case 'UNI'
                E_l = 1-((1./param.data).^2)/24;                
            case 'GAUSS'
                E_l = 1-((1./param.data).^2)/8;
            case 'POISS'
                E_l = 1-((1./param.data).^1.199)*0.236;
        end
        E_l(isinf(E_l)) = 1;
        inFT = E_l.*param.data.*param.dataMask.*inFT./(abs(inFT));
        inFT(param.Bmstop==1) = Bufferdata;
        out = ifftNc(inFT); % g'(k)                
    else
        inFT = fftNc(param.O);
        Bufferdata = inFT(param.Bmstop==1);
        inFT = param.data.*param.dataMask.*inFT./(abs(inFT));
        inFT(param.Bmstop==1) = Bufferdata;
        out = ifftNc(inFT); % g'(k)
%         param.B = 0;    
        
    end
end