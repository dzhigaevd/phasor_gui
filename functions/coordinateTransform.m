function param = coordinateTransform(param)                   
    Nx=size(param.O,2);
    Ny=size(param.O,1);
    Nz=size(param.O,3);

    % Detector pixel sizes
    px=param.detectorPixelSize;
    py=param.detectorPixelSize;

    % Sample pixel sizes
    sx=param.wavelength*param.sampleDetectorDistance/px/Nx;
    sy=param.wavelength*param.sampleDetectorDistance/py/Ny;

    if param.dth ~= 0 || param.dtilt == 0
        sz=param.wavelength/(param.dth*pi/180)/Nz;
        param.dthFlag = 1;
    elseif param.dth == 0 || param.dtilt ~= 0
        sz=param.wavelength/(param.dtilt*pi/180)/Nz;
        param.dthFlag = 0;
    end      

    use_auto=1;

    if use_auto == 1
        FOVth=0.66;      %maximum reduction allowed in the field of view to prevent cutting the object
        param.sample_pixel=min([sz,sy,sx]);
        param.FOVold=[Nx*sx,Ny*sy,Nz*sz];
        param.FOVnew=[Nx*param.sample_pixel,Ny*param.sample_pixel,Nz*param.sample_pixel];
        FOVratio=min(param.FOVnew./param.FOVold);
    end

    if FOVratio(1) < FOVth
      param.sample_pixel=FOVth/FOVratio(1)*param.sample_pixel;   
    else
      param.sample_pixel=min([sz,sy,sx]);
    end

    param.sample_pixel=min([sz,sy,sx]);      

    param.Nx = Nx;
    param.Ny = Ny;
    param.Nz = Nz; 
    param.px = px;
    param.py = py;

    param.T = transformT(param);      

    self.size1=Nx;
    self.size2=Ny;
    self.size3=Nz;

    [ self ] = UpdateCoordSystem(self,param.T(1:3,1:3));

    X=reshape(self.coords(1,:),Ny,Nx,Nz);
    Y=reshape(self.coords(2,:),Ny,Nx,Nz);
    Z=reshape(self.coords(3,:),Ny,Nx,Nz);

    X=X-min(X(:));
    Y=Y-min(Y(:));
    Z=Z-min(Z(:));

    fprintf('Sample pixel size in x: %f nm; y: %f nm; z: %f nm\n', sx*1e9,sy*1e9,sz*1e9);

    XX=self.x*param.sample_pixel*Nx;
    YY=self.y*param.sample_pixel*Ny;
    ZZ=self.z*param.sample_pixel*Nz;

    param.O = flip(double(param.O),3);

    disp('Coordinate system transformation...');
    hM = msgbox('Transforming coordinates. Please, wait.');

    if verLessThan('matlab', '7.14.0')
        param.O = griddata3(X-max(X(:))/2,Y-max(Y(:))/2,Z-max(Z(:))/2,param.O,XX-max(XX(:))/2,YY-max(YY(:))/2,ZZ-max(ZZ(:))/2);
    else
        param.O = griddata(X-max(X(:))/2,Y-max(Y(:))/2,Z-max(Z(:))/2,param.O,XX-max(XX(:))/2,YY-max(YY(:))/2,ZZ-max(ZZ(:))/2);
    end

    param.O(isnan(param.O))=0;

    param.XX = XX-max(XX(:))/2;
    param.YY = YY-max(YY(:))/2;
    param.ZZ = ZZ-max(ZZ(:))/2;
    delete(hM);
    disp('Transformed');            
end