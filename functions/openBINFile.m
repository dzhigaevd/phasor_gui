function out = openBINFile(str)
%UNTITLED22 Summary of this function goes here
%   Detailed explanation goes here
    % Open a dialog for the MAT file selecting
    filterExtension              = '*.bin';
    dialogTitle                  = sprintf('Select a MAT-file containing %s',str);
    defaultFileName              = 'data.bin';
    [fileName, pathName] = uigetfile(filterExtension, dialogTitle, fullfile(pwd,defaultFileName));
    out = fullfile(pathName, fileName);
end
