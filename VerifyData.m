function vOut = VerifyData(regMeas, regCalc, distThr, doseThr, plotOn)
% vOut = VerifyData(regMeas, regCalc, plotOn, distThr, doseThr)
%   Perform 1D gamma evaluation
%
%   Input:
%       regMeas - col 1 = position (cm), col 2 = measurements
%       regCalc - col 1 = position (cm), col 2 = calculated dose values
%       distThr - Gamma calc distance threshold in mm
%       doseThr - Gamma calc dose threshold in %
%       plotOn - Plot flag to be verbose with plotting
%
%   Output:
%       vOut - 1D gamma calculation result
%
%   Reference:
%       D.A. Low and J.F. Dempsey. Evaluation of the gamma dose distribution
%       comparison method. Medical Physics, 30(5):2455�2464, 2003.
%
%   by Jeremy Bredfeldt, 2014
%   github.com/open-source-medical-devices/mppg   
    
    %distThr = 3; %mm
    %doseThr = 0.03; %Should be percent Gray
    doseThr = doseThr/100; %Convert from percent to decimal
    
    %Compute distance error (in mm)
    len = length(regMeas(:,1));
    rm = repmat(10*regMeas(:,1),1,len); %convert to mm
    
    %figure;
    %imagesc(rm);
    
    rc = repmat(10*regCalc(:,1)',len,1); %convert to mm
    
    %figure;
    %imagesc(rc);
    
    rE = (rm-rc).^2;
    
    %figure;
    %imagesc(rE);
    
    rEThr = rE./(distThr.^2);
    if plotOn
        %figure;
        %imagesc(rEThr);
        %colorbar;

    end
    
    %Compute dose error
    Drm = repmat(regMeas(:,2),1,len);
    
    %figure;
    %imagesc(Drm);
    
    Drc = repmat(regCalc(:,2)',len,1);
    
    %figure;
    %imagesc(Drc);
    
    dE = (Drm-Drc).^2;
    
    %figure;
    %imagesc(dE);
    
    dEThr = dE./((doseThr).^2);    
    if plotOn
        %figure;
        %imagesc(dEThr);
        %colorbar;        
    end
    
    gam2 = rEThr + dEThr;
    
    %figure;
    %imagesc(gam2);
    
    %take min down columns to get gamma as a function of position
    [gam Ir] = min(gam2); %Ir is the row index where the min gamma was found
    gam = sqrt(gam);
    
    if plotOn
        %%%%%Debug
        figure;
        plot(regMeas(:,1),regMeas(:,2)); hold all;
        plot(regCalc(:,1),regCalc(:,2));
        plot(regMeas(:,1),gam);
        %get distance error at minimum gamma
        Ic = 1:len; %make column index array
        I = sub2ind(size(rm),Ir,Ic); %convert to linear indices
        distMinGam = sqrt(rEThr(I)); %distance error at minimum gamma position
        plot(regMeas(:,1),distMinGam);

        %get dose error at minimum gamma
        doseMinGam = sqrt(dEThr(I)); %dose error at minimum gamma position
        plot(regMeas(:,1),doseMinGam); hold off;
        %get distance to minimum dose difference
        [mDose IMDr] = min(dE);
        legend('meas','calc','gam','distMinGam','doseMinGam');
    end
    
    %figure;
    %plot(regMeas(:,1),regMeas(:,2)); hold all;
    %plot(regCalc(:,1),regCalc(:,2));
    %plot(regMeas(:,1),100*regMeas(:,2)-regCalc(:,2))./regMeas(:,2);
    %plot(regMeas(:,1),gam);
    %ylim([0 1.5]);
    %legend('Meas','Calc','DTE','Dose Dif','Gamma');
    %hold off;
        
    vOut = gam;
end