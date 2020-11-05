function showBackground(param)
            figure;
            subplot(1,3,1);imagesc(param.B(:,:,round(end/2)));axis image; colormap hot; colorbar;
            subplot(1,3,2);imagesc(param.B(:,:,round(end/2)));axis image; colormap hot; colorbar;
            subplot(1,3,3);imagesc(param.B(:,:,round(end/2)));axis image; colormap hot; colorbar;
        end
        