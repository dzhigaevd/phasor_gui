function showProgress(param,Oftshow,ErrR) 
    map = jet;
    map(65,:) = [0 0 0];
    
    % - Centering of the object -
    if numel(ErrR)>1
        try
            disp('Object centering...');
            shift = -round(ndimCOM(abs(param.O),'auto')-round(param.dataSize/2));    
            param.O = circshift(param.O,shift);
            param.support = circshift(param.support,shift);
            fprintf('Object centered by [%d %d %d] pixels\n',shift(1),shift(2),shift(3));
        catch
            warning('Cannot center the object! Continue without centering!')
        end  
    end
    % ---------------------------
    
    % - AMPLITUDES+SUPPORT ------
    hAxAmp1 = subplot(3,3,1,'Parent',param.centralPanelReconstruction); 
    imagesc(param.coordinateVectorY,param.coordinateVectorX,abs(param.O(:,:,round(param.dataSize(3)/2))));
    axis image;
    zoom(param.zoomVal); 
    colormap(hAxAmp1,bone);
    colorbar('FontSize',10);
    ylabel('Amplitude+Support');
    
    if ~param.GPUcheck && param.ShowSupport
        BW = bwboundaries(param.support(:,:,round(param.dataSize(3)/2)));                
        % Support contour
        try
            hold on;
            plot(param.coordinateVectorX(BW{1}(:,2)),param.coordinateVectorY(BW{1}(:,1)),'color','r','LineWidth',1);        
            hold off; 
            clear BW;
        catch
            warning('Fail to plot support 1');
        end
    end
    
    
    hAxAmp2 = subplot(3,3,2,'Parent',param.centralPanelReconstruction); 
    imagesc(param.coordinateVectorZ,param.coordinateVectorY,abs(squeeze(param.O(:,round(param.dataSize(2)/2),:))));
    zoom(param.zoomVal);
    colormap(hAxAmp2,bone);  
    
    if ~param.GPUcheck && param.ShowSupport
        BW = bwboundaries(squeeze(param.support(:,round(param.dataSize(2)/2),:)));
        % Support contour
        try
            hold on;
            plot(param.coordinateVectorZ(BW{1}(:,2)),param.coordinateVectorY(BW{1}(:,1)),'color','r','LineWidth',1);                   
            hold off;
            clear BW;
        catch
             warning('Fail to plot support 2');
        end
    end
            
        
    hAxAmp3 = subplot(3,3,3,'Parent',param.centralPanelReconstruction); 
    imagesc(param.coordinateVectorZ,param.coordinateVectorX,abs(squeeze(param.O(round(param.dataSize(1)/2),:,:))));
    colormap(hAxAmp3,bone);
    zoom(param.zoomVal); 
    
    if ~param.GPUcheck && param.ShowSupport
        BW = bwboundaries(squeeze(param.support(round(param.dataSize(1)/2),:,:))); %'noholes'        
        % Support contour
        try
            hold on;
            plot(param.coordinateVectorZ(BW{1}(:,2)),param.coordinateVectorX(BW{1}(:,1)),'color','r','LineWidth',1);
            hold off; 
            clear BW;
        catch
             warning('Fail to plot support 3');
        end
    end
    % ---------------------------
    
    % - PHASES ------------------
    hAxPha1 = subplot(3,3,4,'Parent',param.centralPanelReconstruction); 
        imagesc(param.coordinateVectorX,param.coordinateVectorY,...
        angle(param.O(:,:,round(param.dataSize(3)/2))).*param.support(:,:,round(param.dataSize(3)/2))...
        -3.15*(param.support(:,:,round(param.dataSize(3)/2))-1));
        colormap(hAxPha1,map);
        colorbar('FontSize',10);
        ylabel('Phase+Support');
        axis image;        
        zoom(param.zoomVal);

    hAxPha2 = subplot(3,3,5,'Parent',param.centralPanelReconstruction); 
        imagesc(param.coordinateVectorZ,param.coordinateVectorY,...
         angle(squeeze(param.O(:,round(param.dataSize(2)/2),:).*param.support(:,round(param.dataSize(2)/2),:)))...
        -3.15*squeeze(param.support(:,round(param.dataSize(2)/2),:)-1));
        colormap(hAxPha2,map);
        zoom(param.zoomVal);

    hAxPha3 = subplot(3,3,6,'Parent',param.centralPanelReconstruction); 
        imagesc(param.coordinateVectorZ,param.coordinateVectorX,...
        angle(squeeze(param.O(round(param.dataSize(1)/2),:,:).*param.support(round(param.dataSize(1)/2),:,:)))...
        -3.15*squeeze(param.support(round(param.dataSize(1)/2),:,:)-1));
        colormap(hAxPha3,map);
        zoom(param.zoomVal);
    % ---------------------------
    
    subplot(3,3,7,'Parent',param.centralPanelReconstruction); 
    try
        semilogy(ErrR(ErrR~=0),'-o');
        axis tight;
    catch
        warning('Error function is not accessible')
    end
    
    switch param.metricType
        case 'reciprocal'
            ylabel('\chi^2');
        case 'real'
            ylabel('real');
        case 'sharpness'
            ylabel('sharpness');
    end
    
    hAxDa1 = subplot(3,3,8,'Parent',param.centralPanelReconstruction);
        imagesc(param.reciprocalVectorX,param.reciprocalVectorY,squeeze(param.dataLog(:,:,round(end/2)).*param.dataMask(:,:,round(end/2))));
        axis image; clmp = caxis;
        colormap(hAxDa1,jet);
        ylabel('Measured amplitude\newline{[log-scale]}');
        
    hAxDa2 = subplot(3,3,9,'Parent',param.centralPanelReconstruction); 
        imagesc(param.reciprocalVectorX,param.reciprocalVectorY,log10(abs(squeeze(Oftshow(:,:,round(end/2))))));
        axis image; caxis(clmp);
        colormap(hAxDa2,jet);
        ylabel('Reconstructred amplitude\newline{[log-scale]}');
end