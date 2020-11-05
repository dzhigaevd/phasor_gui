function T = transformT(param)    
    degree2rad = pi/180;

    dpx=param.px/param.sampleDetectorDistance;
    dpy=param.py/param.sampleDetectorDistance;

    %old pre july 2013
    dQdpx(1) = -cosd(param.gamma)*cosd(param.delta);
    dQdpx(2) = 0.0;
    dQdpx(3) = sind(param.gamma)*cosd(param.delta);

    dQdpy(1) = sind(param.gamma)*sind(param.delta);
    dQdpy(2) = -cosd(param.delta);
    dQdpy(3) = cosd(param.gamma)*sind(param.delta);

    if param.dthFlag == 1
        dQdth(1) = -cosd(param.gamma)*cosd(param.delta)+1.0;
        dQdth(2) = 0.0;
        dQdth(3) = sind(param.gamma)*cosd(param.delta);
        
        Cstar(1) = (2*pi/param.wavelength)*param.dth*degree2rad*dQdth(1);
        Cstar(2) = (2*pi/param.wavelength)*param.dth*degree2rad*dQdth(2);
        Cstar(3) = (2*pi/param.wavelength)*param.dth*degree2rad*dQdth(3);
    elseif param.dthFlag == 0
        dQdth(1) = 0.0;
        dQdth(2) = cosd(param.gamma)*cosd(param.delta)-1.0;
        dQdth(3) = -sind(param.delta);
        
        Cstar(1) = (2*pi/param.wavelength)*param.dtilt*degree2rad*dQdth(1);
        Cstar(2) = (2*pi/param.wavelength)*param.dtilt*degree2rad*dQdth(2);
        Cstar(3) = (2*pi/param.wavelength)*param.dtilt*degree2rad*dQdth(3);
    end

    Astar(1) = (2*pi/param.wavelength)*dpx*dQdpx(1);
    Astar(2) = (2*pi/param.wavelength)*dpx*dQdpx(2);
    Astar(3) = (2*pi/param.wavelength)*dpx*dQdpx(3);

    Bstar(1) = (2*pi/param.wavelength)*dpy*dQdpy(1);
    Bstar(2) = (2*pi/param.wavelength)*dpy*dQdpy(2);
    Bstar(3) = (2*pi/param.wavelength)*dpy*dQdpy(3);   

    denom    = dot(Astar,cross(Bstar,Cstar));
    Axdenom  = cross(Bstar,Cstar);
    Bxdenom  = cross(Cstar,Astar);
    Cxdenom  = cross(Astar,Bstar);

    A(1)     = 2*pi*Axdenom(1)/(denom);
    A(2)     = 2*pi*Axdenom(2)/(denom);
    A(3)     = 2*pi*Axdenom(3)/(denom);

    B(1)     = 2*pi*Bxdenom(1)/(denom);
    B(2)     = 2*pi*Bxdenom(2)/(denom);
    B(3)     = 2*pi*Bxdenom(3)/(denom);

    C(1)     = 2*pi*Cxdenom(1)/(denom);
    C(2)     = 2*pi*Cxdenom(2)/(denom);
    C(3)     = 2*pi*Cxdenom(3)/(denom);        

    T = [A(1) B(1) C(1) 0;A(2) B(2) C(2) 0;A(3) B(3) C(3) 0;0 0 0 1];                       
end