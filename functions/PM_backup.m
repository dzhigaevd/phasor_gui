function out = PM(O, Bmstop, data)
    inFT = fftNc(O);
    Bufferdata = inFT(Bmstop==1);
    inFT = abs(data).*inFT./(abs(inFT));
    inFT(Bmstop==1) = Bufferdata;
    out = ifftNc(inFT); % g'(k)
end