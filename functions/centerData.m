function param = centerData( param , type, direction)
%CENTERDATA Summary of this function goes here
%   Detailed explanation goes here
    c0 = param.dataSize/2;
    dummy = (param.O);
    for ii = 1:1        
        dummy = fftNc(dummy);    
        if numel(param.dataSize) == 3 
            c1 = ndimCOM(abs(dummy).^4,'auto');
            switch direction
                case '+'
                    d = (c1-c0);
                case '-'
                    d = -(c1-c0);
            end

            fprintf('Data center: [%.2f, %.2f, %.2f]\nShift by [%.2f, %.2f, %.2f]\n', c1(1), c1(2), c1(3),d(1),d(2),d(3));
            switch type
                case 'crop'
                    param.data = imtranslate(param.data,d);
                case 'fill'
                    dummy = imtranslate(dummy,d);
                    dummy = ifftNc(dummy);
            end
        elseif numel(param.dataSize) == 2
            c1 = ndimCOM(param.data,'auto');
            fprintf('Data center: [%.2f, %.2f]', c1(1), c1(2));
        else
            warning('Data dimensionality is wrong!');
        end 
    end
%     Average phase value
    param.O = dummy.*exp(-1j*mean(angle(dummy(:))));
    
    disp('Phase ramp removed!');
end

