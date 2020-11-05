function self = UpdateCoordSystem(self,T)
    Nx=self.size1;
    Ny=self.size2;
    Nz=self.size3;
    self.dx=1./self.size1;
    self.dy=1./self.size2;
    self.dz=1./self.size3;

    [x, y, z] = meshgrid( ((1:self.size1)*self.dx),((1:self.size2)*self.dy),(1:self.size3)*self.dz);

    self.x=x;
    self.y=y;
    self.z=z;

    r=zeros([3,Ny,Nx,Nz]);

    r(1,:,:,:) = x;
    r(2,:,:,:) = y;
    r(3,:,:,:) = z;

    r = reshape(r,3,self.size2*self.size1*self.size3);

    self.coords=reshape(T*r,3,self.size2,self.size1,self.size3);
end