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
% Compute cardinality
% This part was inspired by BioPatRect
% --------------------------Updates--------------------------
% % 2022-03-15 / Bahareh Ahkami / Creation
%



function pF = GetSigFeatures_tcard(pF)

% if strcmp(pF.filter,'None')
%     data = pF.data;
%     % Do nothing and exit if
% else
   %scale to 14 bits
    
    a = 4096;   
    b = a;
    a = a * -1;
    
    % Range of the original aquisition
    minX = -5;
    maxX = 5;
    
    % Scale
    data = round((pF.data- minX) .* (b-a) ./ (maxX-minX) + a);



    for ch = 1 : pF.ch
        % Get the number of different values and their number of repetitions
        v = unique(data(ch,:));
        m = size(v,1);      % Number of unique values, or cardinality        
        pF.f.tcard(ch) =  m;
    end
    pF.f.tcard=pF.f.tcard';
end
