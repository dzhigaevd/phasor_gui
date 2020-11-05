% ShrinkWrap algorithm
function [supportOut, sigmaOut] = shrinkWrap(param,ii,algo)

    if numel(param.dataSize) == 3
        temp = imgaussfilt3(abs(param.O),[param.sigma param.sigma param.sigma]);
    elseif numel(param.dataSize) == 2
        temp = imgaussfilt(abs(param.O),[param.sigma param.sigma]);
    else
        warning('Wrong dimensionality of the input data');
    end

    supportOut = temp>param.Treshold*max(temp(:));
    
    clear temp; 
    f = param.(algo)/3;
    if param.sigma > param.SigmaEnd
        % This function has to be clarified
        sigmaOut = param.SigmaStart.*exp(-ii^2*log(2)/(f^2))+param.SigmaEnd;
    else
        sigmaOut = param.SigmaEnd; 
    end
end