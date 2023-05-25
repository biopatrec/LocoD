
% Reads the file features.def and loads the data into motor objects.


function fID = LoadFeaturesIDs

fileid = fopen('features.def');
tline = fgetl(fileid);
i=1;
fID = {};
while ischar(tline) && ~isempty(tline)
    t = textscan(tline,'%s');
    t = t{1};
    fID(i) = t(1);
    %disp(t{1});
    tline = fgetl(fileid);
    i=i+1;
end

fID = fID'; % It made a vector to keep compatibility with the rest of BioPatRec

fclose(fileid);


