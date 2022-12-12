function [Allclass,SSclass,TrClass,wclass,wsaclass,wsdclass,wraclass,wrdclass,saclass,sdclass,rdclass,raclass,sawclass,sdwclass,rawclass,rdwclass,w,sa,sd,ra,rd,wsa,wrd,wsd,wra,raw,rdw,sdw,saw,ss,tr]=Calculatemean(Result)
wclass=[];wsaclass=[];wsdclass=[];wraclass=[];wrdclass=[];saclass=[];sdclass=[];rdclass=[];raclass=[];
sawclass=[];sdwclass=[];rawclass=[];rdwclass=[];
%Calculate mean


%Find each class's accuracy
for k=1:length(Result)
    res=Result{k};
    %Walking
    [j,~]=find((res(:,1)==3));
    w=res(j,2);
    wclass=[wclass w'];
    %StairA
    [j,~]=find((res(:,1)==6));
    sa=res(j,2);
    saclass=[saclass sa'];
    %StairD
    [j,~]=find((res(:,1)==7));
    sd=res(j,2);
    sdclass=[sdclass sd'];
    %RamA
    [j,~]=find((res(:,1)==4));
    ra=res(j,2);
    raclass=[raclass ra'];
    %RampD
    [j,~]=find((res(:,1)==5));
    rd=res(j,2);
    rdclass=[rdclass rd];
    %WSA
    [j,~]=find((res(:,1)==36));
    wsa=res(j,2);
    wsaclass=[wsaclass wsa];
    %WSD
    [j,~]=find((res(:,1)==37));
    wsd=res(j,2);
    wsdclass=[wsdclass wsd'];
    %WRD
    [j,~]=find((res(:,1)==35));
    wrd=res(j,2);
    wrdclass=[wrdclass wrd'];
    
    %WRA
    [j,~]=find((res(:,1)==34));
    wra=res(j,2);
    wraclass=[wraclass wra'];

    %SAW
    [j,~]=find((res(:,1)==63));
    saw=res(j,2);
    sawclass=[sawclass saw'];

    %SDW
    [j,~]=find((res(:,1)==73));
    sdw=res(j,2);
    sdwclass=[sdwclass sdw'];

    %RAW
    [j,~]=find((res(:,1)==43));
    raw=res(j,2);
    rawclass=[rawclass raw'];

    %RDW
    [j,~]=find((res(:,1)==53));
    rdw=res(j,2);
    rdwclass=[rdwclass rdw'];

    % Calculate ss and tr for every person

    %Remov nan and inf
    r=[];
    r(:,1:2)= res( ~any( isnan( res(:,2) ) | isinf(res(:,2) ), 2 ) ,:);
    [~,l]=ismember([3,4,5,6,7],r(:,1));
    ss(k)=mean(r(l,2));

    [~,m]=ismember([34,43,35,53,63,36,73,37],r(:,1));
    tr(k)=mean(r(m,2));

end

%Calculate mean without nan
w=mean(wclass, 'all','omitnan' );
sa=mean(saclass, 'all','omitnan' );
sd=mean(sdclass, 'all' ,'omitnan');
ra=mean(raclass, 'all' ,'omitnan');
rd=mean(rdclass, 'all' ,'omitnan');
wsaclass(wsaclass==inf)=nan; wsa=mean(wsaclass(wsaclass~=0),'omitnan'); 
wsdclass(wsdclass==inf)=nan;wsd=mean(wsdclass(wsdclass~=0),'omitnan');
wraclass(wraclass==inf)=nan;wra=mean(wraclass(wraclass~=0),'omitnan');
wrdclass(wrdclass==inf)=nan;wrd=mean(wrdclass(wrdclass~=0),'omitnan');
sawclass(sawclass==inf)=nan;saw=mean(sawclass, 'all','omitnan' );
sdwclass(sdwclass==inf)=nan;sdw=mean(sdwclass, 'all' ,'omitnan');
rawclass(rawclass==inf)=nan;raw=mean(rawclass, 'all' ,'omitnan');
rdwclass(rdwclass==inf)=nan;rdw=mean(rdwclass, 'all','omitnan' );


wclass(isnan(wclass))=[];
saclass(isnan(saclass))=[];
sdclass(isnan(sdclass))=[];
raclass(isnan(raclass))=[];
rdclass(isnan(rdclass))=[];
wsaclass(isnan(wsaclass))=[];
wsdclass(isnan(wsdclass))=[];
wraclass(isnan(wraclass))=[];
wrdclass(isnan(wrdclass))=[];
sawclass(isnan(sawclass))=[];
sdwclass(isnan(sdwclass))=[];
rawclass(isnan(rawclass))=[];
rdwclass(isnan(rdwclass))=[];

SSclass=[wclass,saclass,sdclass,raclass,rdclass];
TrClass=[wsaclass,wsdclass,wraclass,wrdclass,sawclass,sdwclass,rawclass,rdwclass];
Allclass=[SSclass,TrClass];






end