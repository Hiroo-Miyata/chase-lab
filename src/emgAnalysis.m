emgByReward1 = zeros(0, 5);
emgByReward2 = zeros(0, 5);
emgByReward3 = zeros(0, 5);
emgByReward4 = zeros(0, 5);
for i=(1:length(file.singleTrialData)) % length(file.singleTrialData)
    reward = file.singleTrialData(i).prop.reward;
    
    if reward == 1
        emgByReward1 = [emgByReward1; file.singleTrialData(i).emg];
    elseif reward == 2
        emgByReward2 = [emgByReward2; file.singleTrialData(i).emg];
    elseif reward == 3
        emgByReward3 = [emgByReward3; file.singleTrialData(i).emg];
    elseif reward == 4
        emgByReward4 = [emgByReward4; file.singleTrialData(i).emg];
    end
end

