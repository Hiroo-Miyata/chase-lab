function [selectedTrialData,selectedArray] = selectStateTransition(trialData, transition)

% this function is to select trials which have a specific state transion 
% input - trialData [ntrial * 1] type: struct
%       - transition array type: int
% output - selectedTrialData [mtrial * 1] type: struct
%        - selectedArray [ntrial * 1 type: logical selected=1 rejected=0
selectedArray = false(size(trialData));
for i=(1:length(trialData))
    stateTransition = trialData(i).stateTable;
    if all(ismember(transition, stateTransition(1,:))) == 1
        selectedArray(i) = true;
    end
end
selectedTrialData = trialData(selectedArray);

end

