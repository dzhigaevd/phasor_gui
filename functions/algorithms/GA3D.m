function param = GA3D( param, GAtab, handlesGA,handlesER,handlesHIO,handlesSF,handlesDM,handlesRAAR,handlesASR)        
    param.stopFlagPattern = 0;
    param.stopFlag = 0;

    algoList = (strsplit(param.currentPattern,'+'));
    
     % Mask for the data threshold
    param.dataMask = param.data>param.dataThreshold;
    
    nIterations  = str2double(get(handlesGA.hnIterationsGA,'String'));
    nPopulation  = str2double(get(handlesGA.hnPopulationGA,'String'));
    nGenerations = str2double(get(handlesGA.hnGenerationsGA,'String'));
    nAlgos       = length(algoList);                           
    populationO  = rand([param.dataSize,nPopulation]);        
    
    for cycleCounter = 1:nGenerations                
        if param.stopFlag == 0                                                        
            for pp = 1:nPopulation
                if param.stopFlag == 0
                    param.O = populationO(:,:,:,pp);            
                    for loopCounter = 1:nIterations
                        if param.stopFlag == 0
                            for algoCounter = 1:nAlgos
                                if param.stopFlag == 0
                                    switch algoList{algoCounter}
                                        case 'ER'
                                            param.nER  = str2double(get(handlesER.hnER,'String'));                                    
                                            param = ER3D(param,GAtab);                            
                                        case 'HIO'
                                            param.nHIO = str2double(get(handlesHIO.hnHIO,'String'));
                                            param.beta = str2double(get(handlesHIO.hBetaHIO,'String'));
                                            param = HIO3D(param,GAtab); 
                                        case 'CHIO'
                                            param.nCHIO = str2double(get(handlesCHIO.hnCHIO,'String'));
                                            param.alpha = str2double(get(handlesCHIO.hAlphaCHIO,'String'));
                                            param.beta = str2double(get(hBetaCHIO,'String'));
                                            param = CHIO3D(param,GAtab);
                                        case 'SF'
                                            param.nSF  = str2double(get(handlesSF.hnSF,'String'));
                                            param.beta = str2double(get(handlesSF.hBetaSF,'String'));
                                            param = SF3D(param,GAtab);  
                                        case 'ASR'
                                            param.nASR  = str2double(get(hnASR,'String'));
                                            param.beta = str2double(get(hBetaASR,'String'));
                                            param = ASR3D(param,GAtab);
                                        case 'DM'
                                            param.nDM  = str2double(get(hnDM,'String'));
                                            param.beta = str2double(get(hBetaDM,'String'));
                                            param = DM3D(param,GAtab);
                                        case 'RAAR'
                                            param.nRAAR  = str2double(get(hnRAAR,'String'));
                                            param.beta = str2double(get(hBetaRAAR,'String'));
                                            param = RAAR3D(param,GAtab);    
                                        case ' '
                                            error('Pattern is not selected!');                            
                                    end 
                                else
                                    break;
                                end
                            end
                        else
                            break;
                        end
                        drawnow();
                    end 
                else
                    break;
                end
                if param.stopFlag == 0                     
                    disp('Calculation of the metric!');
                    if strcmp(param.metricType,'sharpness')                        
                        metric(pp) = 1/calculateMetric(param.O);
                    else
                        metric(pp) = calculateMetric(param.O);
                    end
                    populationO(:,:,:,pp) = param.O;
                end
            end
            if param.stopFlag == 0
                survivor = find(metric == min(metric));
                fprintf('Survivor is # %d',survivor);
                if cycleCounter ~= nGenerations
                    populationO   = sqrt(rand([param.dataSize,nPopulation]).*populationO(:,:,:,survivor));  
                else
                    param.O = populationO(:,:,:,survivor);
                end
            end
        else
            break;
        end     
    end
    drawnow();
    disp('Calculation stopped!');
end

