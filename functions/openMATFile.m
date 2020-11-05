function [fileName, pathName] = openMATFile(str)
%UNTITLED22 Summary of this function goes here
%   Detailed explanation goes here
    % Open a dialog for the MAT file selecting
    filterExtension              = '*.mat';
    dialogTitle                  = sprintf('Select a MAT-file containing %s',str);
    defaultFileName              = 'data.mat';
    [fileName, pathName] = uigetfile(filterExtension, dialogTitle, fullfile(pwd,defaultFileName));
    
%     out = fullfile(pathName, fileName);
end


