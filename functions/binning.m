 % Binning of the data
    function binned = binning(image, binning_size)
        convoluted = convn(image, ones(binning_size));
        convoluted_size = size(convoluted);
        binned = convoluted(binning_size:binning_size:convoluted_size(1), binning_size:binning_size:convoluted_size(2), binning_size:binning_size:convoluted_size(3));
    end