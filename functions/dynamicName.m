function out = dynamicName( inputFile )
 % Dynamic determination of the dataset name
    in = load(inputFile); 
    names = fieldnames(in);
    out = in.(names{1});

end

