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
% Compute the rough entropy
% This part was inspired by BioPatRec
% --------------------------Updates--------------------------
% % % 2022-03-15 / Bahareh Ahkami / Creation
%



function pF = GetSigFeatures_tren(pF)
    % Compute the Rough Entropy per channel
    u = pF.sp; % Univers or in this case samples (elements)
    for ch = 1 : pF.ch

        % Get the number of different values and their number of repetitions
        [v q] = unique(pF.data(ch,:));
        m = size(v,1);      % Number of unique values
        % Sort q (last apperance) to compute how many apperances each value had
        sq = sort(q);

        % Compute the first value
        card = zeros(m,1);     
        card(1) = sq(1);        % How many elements are there of the first element
        rEn = (card(1)/u) * log2(1/card(1));
        % Compute the rest of the values
        for i = 2 : m
            % Collect the number of aperances
            card(i) = sq(i) - sq(i-1);
            rEn = rEn + ((card(i)/u) * log2(1/card(i)));
        end    
        pF.f.tren(ch) =  -rEn;
    end
     pF.f.tren= pF.f.tren';
end
