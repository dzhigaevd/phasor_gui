function output = centerMat( input )
%   Detailed explanation goes here
    % Centering of the object
    try
        disp('Object centering...');
        shift = -round(ndimCOM(abs(input),'auto')-(size(input)/2));    
        output = circshift(input,shift);        
        fprintf('Object centered by [%d %d %d] pixels\n',shift(1),shift(2),shift(3));
        
        % Center by max pixel
        
    catch
        warning('Cannot center the object! Continue without centering!')
    end  

end

