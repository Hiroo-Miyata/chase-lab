file = load('../data/processed/singleTrials_Rocky20220217_movave_50ms.mat');
singleTrialData = file.singleTrialData;

% get mean EMG voltage in each trial, then visualize it

meanEMGEachTrial = zeros(length(singleTrialData), 5);
for i=(1:length(singleTrialData))
    meanEMGEachTrial(i, :) = mean(singleTrialData(i).emg, 1);
end


% boxplot(meanEMGEachTrial(:, :), file.muscleLabel(1:5))

for c=(1:5)
    [~,maxid] = max(meanEMGEachTrial(:,c));
    [~,minid] = min(meanEMGEachTrial(:,c));
    fprintf('Channel: %s, max: %d, min: %d \n', string(file.muscleLabel(c)), int16(maxid), int16(minid));
    figure
    plot(singleTrialData(maxid).emg(:,c));
    title(string(file.muscleLabel(c)) + ' at max')
    figure
    plot(singleTrialData(minid).emg(:,c));
    title(string(file.muscleLabel(c)) + ' at min')
end