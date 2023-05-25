% 
 tags=signalCopy.tags;
% % 
% for i=1:length(tags)
%     if i~=1
%         if (tags(1,i-1)==6 || tags(1,i-1)==7) && tags(1,i)==3
%             tags(2,i)=tags(2,i)+11.2;  %1.2  
%         end
%     end
% end
% % 
% for i=1:length(tags)
%     if i~=1
%         if tags(1,i-1)==3 && ( tags(1,i)==7 || tags(1,i)==6)
%             tags(2,i)=tags(2,i)+1;
%         end
%     end
%  end
% for i=1:length(tags)
%     if i~=1
%         if tags(1,i-1)==6 && tags(1,i)==3
%             tags(2,i)=tags(2,i)+.5;  %1.2  
%         end
%     end
% end
for i=1:length(tags)
    if i~=1
        if tags(1,i-1)==3 && tags(1,i)==7
            tags(2,i)=tags(2,i)-.5;  %1.2  
        end
    end
 end
% for i=1:length(tags)
%     if i~=1
%         if tags(1,i-1)==7 && tags(1,i)==3
%             tags(2,i)=tags(2,i)+3 ;  %1.2  
%         end
%     end
% end
% % 
% for i=1:length(tags)
%     if i~=1
%         if tags(1,i-1)==3 &&   tags(1,i)==6
%             tags(2,i)=tags(2,i)+.5;
%         end
%     end
% end
% 
for i=1:length(tags)
    if i~=1
        if tags(1,i-1)==5 && tags(1,i)==3
            tags(2,i)=tags(2,i)-.3;  %1.2  
        end
    end
end
for i=1:length(tags)
    if i~=1
        if tags(1,i-1)==3 && tags(1,i)==5
            tags(2,i)=tags(2,i)-.4;  %1.2  
        end
    end
end
for i=1:length(tags)
    if i~=1
        if tags(1,i-1)==4 && tags(1,i)==3
            tags(2,i)=tags(2,i)-.4;  %1.2  
        end
    end
end
% for i=1:length(tags)
%     if i~=1
%         if tags(1,i-1)==3 && tags(1,i)==4
%             tags(2,i)=tags(2,i)+1;  %1.2  
%         end
%     end
% end



% 
signalCopy.tags=tags;