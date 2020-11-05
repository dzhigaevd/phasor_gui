function FSCarr = FSC(particle1, particle2)
    % FOURIER SHELL CORRELATION (FSC) of two particles from half data sets
    % https://en.wikipedia.org/wiki/Fourier_shell_correlation

    % get the FT of each particle and shift zero frequency into center!
    FTparticle1 = fftshift(fftn(ifftshift(particle1)));
    FTparticle2 = fftshift(fftn(ifftshift(particle2)));

    % get the multiplication of both particles
    % using real part only beacuase the conj-product does not eliminate all the
    % imaginary parts, (why actually not???)
    temp1 = real(FTparticle1 .* conj(FTparticle2));


    % center of the space for expected centered particles
    centerOfSpace = size(particle1)/2;

    % calculate nominator of the FSC definition
    fShellNOM = azimuthalAverage3D(temp1, centerOfSpace,round(centerOfSpace(1)/2));

    % calulate both parts of the denominator
    fShellDENOM1 = azimuthalAverage3D(abs(FTparticle1).^2, centerOfSpace, round(centerOfSpace(1)/2));
    fShellDENOM2 = azimuthalAverage3D(abs(FTparticle2).^2, centerOfSpace, round(centerOfSpace(1)/2));

    % finally the FSC ratio
    FSCarr = fShellNOM ./ sqrt(fShellDENOM1 .* fShellDENOM2);
end