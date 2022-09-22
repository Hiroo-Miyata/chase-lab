function [rewardArray,directionArray] = taskConditions(trialData)
% this function is to select trials which have a specific state transion 
% input - trialData [ntrial * 1] type: struct
% output - rewardArray [ntrial * 1] type: int
%        - directionArray [ntrial * 1 type: int
rewardArray = zeros(size(trialData));
directionArray = zeros(size(trialData));

for i=(1:length(trialData))
    stateTransition = trialData(i).stateTable;
    if all(ismember(transition, stateTransition(1,:))) == 1
        selectedArray(i) = true;
    end
end
selectedTrialData = trialData(selectedArray);

end

