% Radial average
    function [Zr, R] = radialAvg3D(z,m)
        % RADIALAVG	 Radially averaqe any 3D matrix Z into M bins
        % radial distances r over grid of z
        N = min(size(z));
        
        [X,Y,Z] = meshgrid(-(N-1)/2:(N-1)/2);
        r = sqrt(X.^2+Y.^2+Z.^2);
        
        maxbinval = max(r(:));
        
        % equi-spaced points along radius which bound the bins to averaging radial values
        % bins are set so 0 (zero) is the midpoint of the first bin and 1 is the last bin
        dr = 1/(m-1);
        rbins = maxbinval.*linspace(-dr/2,1+dr/2,m+1);
        
        % radial positions are midpoints of the bins
        R =(rbins(1:end-1)+rbins(2:end))/2;
        
        Zr = zeros(1,m); % vector for radial average

        % loop over the bins, except the final (r=1) position
        for j=1:m-1
            % find all matrix locations whose radial distance is in the jth bin
            bins = r>=rbins(j) & r<rbins(j+1);

            % count the number of those locations
            n = sum(bins(:));
            if n~=0
                % average the values at those binned locations
                Zr(j) = sum(z(bins))/n;
            else
                % special case for no bins (divide-by-zero)
                Zr(j) = NaN;
            end
        end
    end
    