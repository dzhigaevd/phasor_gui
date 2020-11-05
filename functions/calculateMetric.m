function out = calculateMetric( param )
    switch param.metricType
        case 'reciprocal'            
            out = sum(sum(sum(param.dataMask.*...
                (abs(fftNc(param.O.*param.support)).*...
                abs(param.Bmstop-1)-param.data).^2)))/...
                sum(sum(sum((param.dataMask.*param.data).^2)));             
        case 'real'
            out = sum(sum(sum(abs(param.O.*abs(param.support-1)).^2)))/...
                sum(sum(sum(abs(param.O.*param.support).^2))); 
            % Real space error for HIO
        case 'sharpness'
            out = calculateSharpness(param.O);
    end
end

