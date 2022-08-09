
repmat({''}, length(), 1)
    

% transDict = containers.Map;
% transTimeDict = containers.Map;
% for i = (1:length(movementData.data))
%     a = movementData.data(i).TrialData.stateTransitions;
%     key = string(sum(a(1,:)));
%     if isKey(transDict, key)
%         transDict(key) = transDict(key) + 1;
%     else
%         transDict(key) = 1;
%         a(1,:)
%     end
%     for s = (1:length(a(1,:))-2)
%         key = string(sum(a(1,s:s+1)));
%         value = a(2,s+1) - a(2,s);
%         if isKey(transTimeDict, key)
%             transTimeDict(key) = [transTimeDict(key) value];
%         else
%             transTimeDict(key) = [value];
%         end
%     end
% end