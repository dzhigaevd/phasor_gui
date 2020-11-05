function ini = getIni(iniName)
    try
        fileID = fopen(fullfile(pwd,iniName),'r');                                         
        InputText = textscan(fileID,'%s','delimiter','\n');       
        fprintf('Reading ini file...\n');  
        disp(InputText);                                  
        fclose(fileID);
        kk = 1;
        for ii = 1:length(InputText{1})
            if strcmp(InputText{1}{ii}(1),'>')
                ini(kk) = str2double(InputText{1}{ii+1});
                kk = kk+1;
            end
        end
        fprintf('Done!\n');
    catch
        fprintf('The ini file is not in the current folder, using default values...\n');
        % Standart ini table
        % Binning
        ini(1) = 1;
        % Energy
        ini(2) = 9000;
        % SDD
        ini(3) = 1.83;
        % Detector pixel size, [um]
        ini(4) = 55e-6;
        % Angular step
        ini(5) = 0.04;
    end
end

