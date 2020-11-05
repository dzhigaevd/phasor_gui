function out = cohPM(O, Bmstop, data, gamm)
    inFT = fftNc(O);
    % Following J Clarck
    I_k = abs(inFt).^2;
%     gamm = gamm.*()
    
    I_pc = convn(I_k,gamm);
    
    Bufferdata = inFT(Bmstop==1);
    inFT = abs(data).*inFT./(abs(inFT));
    inFT(Bmstop==1) = Bufferdata;
    out = ifftNc(inFT); % g'(k)
end