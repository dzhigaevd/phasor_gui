function out = PM_dm(O,Bmstop,data,dataMask)
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
        inFT = fftNc(O);
        Bufferdata = inFT(Bmstop==1);
        inFT = data.*dataMask.*inFT./(abs(inFT));
        inFT(Bmstop==1) = Bufferdata;
        out = ifftNc(inFT); % g'(k)
%         param.B = 0;    
        
%     end
end