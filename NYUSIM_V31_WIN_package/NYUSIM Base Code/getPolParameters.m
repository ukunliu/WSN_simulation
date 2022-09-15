function polMod = getPolParameters(Pol,f,envType)

% STD between VV and HH
sigmaPol = 1.6;
if strcmp(Pol,'Co-Pol')
    polMod = {0,'CoPol'};
else
    if strcmp(envType,'LOS')
        XPD = 11.5 + f*0.10;
    elseif strcmp(envType,'NLOS')
        XPD = 5.5 + f*0.13;
    else
        disp('Wrong Env Type.');
    end
    if strcmp(Pol,'X-Pol')
        polMod = {XPD,'XPol'};
    elseif strcmp(Pol,'Co/X-Pol')
        polMod = {0,'CoPol';XPD,'XPol'};
    elseif strcmp(Pol,'All-Pol')
        polMod = {0,'VVPol';randn*sigmaPol,'HHPol';XPD,'VHPol';XPD+randn*sigmaPol,'HVPol'};
    else
        disp('Wrong Polarization Input.');
    end
end