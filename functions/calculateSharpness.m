function out = calculateSharpness( input )
    d = (abs(input)).^4;
    out = sum(d(:));
end

