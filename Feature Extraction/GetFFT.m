% ---------------------------- Copyright Notice ---------------------------
% This file is part of LocoD © which is open and free software under
% the GNU Lesser General Public License (LGPL). See the file "LICENSE" for
% the full license governing this code and copyrights.
%
% LocoD was initially developed by Bahareh Ahkami at
% Center for Bionics and Pain research and Chalmers University of Technology.
% All authors’ contributions must be kept
% acknowledged below in the section "Updates % Contributors".
%
% Would you like to contribute to science and sum efforts to improve
% amputees’ quality of life? Join this project! or, send your comments to:
% ahkami@chalmers.se.
%
% The entire copyright notice must be kept in this or any source file
% linked to LocoD. This will ensure communication with all authors and
% acknowledge contributions here and in the project web page (optional).

% acknowledge contributions here and in the project web page (optional).
% ------------------- Function Description ------------------
% Calculate FFT
% This part was inspired by BioPatRec
% --------------------------Updates--------------------------
% 2022-03-15 / Bahareh Ahkami / Creation

function pF = GetFFT(pF)
    
    cF = pF.sF/2;

    % Fast Fourier Transform
    NFFT    = 2^nextpow2(pF.sp);      
   
    % Next power of 2 from number of samples
    dataf   = fft(pF.data',NFFT)/pF.sp;     
    % Gets the fast fourier transform
    pF.fftData = 2*abs(dataf((1:NFFT/2+1),:));  % Get the half of the data considering abs values,
                                                %   since it is simetric and we
                                                %   only look at the half, it is multiply for 2
                                                
    pF.fftData(1,:) = 0;                        % The first element is made 0 to reduce artifats of low fqs.

    pF.fftDataT = sum(pF.fftData);              % Sum of all frequency contributions
  
    pF.fV = pF.sF/2*linspace(0,1,NFFT/2+1);     % Creates the frequency vector
    
    % Plot for visualization if required
    % figure();                                        
    % plot(pF.fV,pF.fftData(:,1))
    
    % Cuff the matrix to cF for analysis
    cF = 1000;                                  % Cut frequency for features stimation
                                                % If sF > 1kH, the estimation of frequency related features
                                                % will be within 0 to 1kH    
    if pF.fV(end) > cF
        cS = round(cF * length(pF.fftData(:,1)) / (pF.sF/2));
        pF.fftData = pF.fftData(1:cS,:);
        pF.fV = pF.fV(1:cS);
    end



