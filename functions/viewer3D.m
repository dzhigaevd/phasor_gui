function viewer3D(hObj,callbackdata)                                 % Main function of the display     
        main = figure;
        % Initial area
        centralPanelData = uipanel('Parent',main,'Title','Initial Data','FontSize',...
            12,'Units','Normalized','Position',[.22 0.1 .77 .85]); 
        
        imAxData2 = axes('Parent',centralPanelData);
        
        % Update the 3D visualization of the reciprocal space
        data = dynamicName(openMATFile('data'));
        isoValReal = 0.5;
                
        uicontrol('Parent',main,'Style',...
            'slider','Min',0,'Max',1,...
            'Value',isoValReal,'Units','Normalized',...
            'Position', [0.68 0.05 0.3 0.03],...
            'Callback', @slideIsosurfaceReal); 
        
        function updateObjectReal(hObj,callbackdata)         
            cla(imAxData2);
            axes(imAxData2); 
				isosurface(abs(data)./max(max(max(abs(data)))),isoValReal); 
				axis vis3d equal; 
            xlabel('x, [nm]'); ylabel('y, [nm]'); zlabel('z, [nm]');
            axis tight; h3 = light; h3.Position = [-1 -1 -1];  h4 = light; h4.Position= [1 1 1];  rotate3d on 
            
            drawnow();
            disp('Object updated!');
        end        
        
        function slideIsosurfaceReal(hObj,callbackdata)
            isoValReal = get(hObj,'Value');
            updateObjectReal;
        end
end