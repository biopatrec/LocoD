
% Compute cardinality
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
