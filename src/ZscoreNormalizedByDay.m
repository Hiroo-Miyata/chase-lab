emg_channel = 5;
files = ["0216", "0217", "0218", "0221", "0222", "0223", "0224", "0225", "0228", "0301", "0302", "0303"];

%
%
% prepare visualization variables
%
%
meanEMGAcrossDays = zeros(5, 0);
baselines = zeros(5, 0);
endofTrialByDays = zeros(length(files)+1, 1);
titles = {'Day1', 'Day2', 'Day3', 'Day4', 'Day5', 'Day6', 'Day7', 'Day8', 'Day9', 'Day10', 'Day11', 'Day12'};
means = zeros(length(files), emg_channel);
stds = zeros(length(files), emg_channel);
normalizedParams = zeros(2, emg_channel, length(files));
tenDmetadataAcrossDays = zeros(9, emg_channel, length(files));

%
%
% normalizing each day
%
%
for t=(1:length(files)) %(1:length(files)
    file = load('../data/processed/singleTrials_Rocky2022'+files(t)+'_movave_50ms.mat');
    singleTrialData = file.singleTrialData;
    
    dataLength = 0;
    for i=(1:length(singleTrialData))
        stateTransition = singleTrialData(i).prop.stateTransition;
        if all(ismember([3 4 5 6 7], stateTransition(1,:))) == 1
            dataLength + dataLength + 1;
        end
    end
    
    s = 0;
    EMG = zeros(801, emg_channel, dataLength);
    directionArray = zeros(dataLength);
    rewardArray = zeros(dataLength);
    for i=(1:length(singleTrialData))
        stateTransition = singleTrialData(i).prop.stateTransition;
        if all(ismember([3 4 5 6 7], stateTransition(1,:))) == 1
            s = s+1;
            GoCueTime = stateTransition(2, find(stateTransition(1, :)==4));
            % start: -200ms end: +600ms at GoCue
            EMGaroundGoCue = singleTrialData(i).emg(GoCueTime-200:GoCueTime+600, :);
            EMG(:,:, s) = EMGaroundGoCue;
            directionArray(s) = singleTrialData(i).prop.direction;
            rewardArray(s) = singleTrialData(i).prop.reward;
        end
    end
    
    meanEMGEachTrial = reshape(mean(EMG, 1), 5, []);
    endofTrialByDays(t+1) = endofTrialByDays(t) + int16(size(meanEMGEachTrial, 2));
    emgRest = file.emg_rest; % 120s * channel
    baseline = zeros(size(meanEMGEachTrial)) + reshape(mean(emgRest, 1), 5, []);
    tenDmetadata = zeros(9, emg_channel);
    for direction=(1:8)
        oneDirectionEMG = EMG(:,:,directionArray==direction);
        meanOneDirectionEMG = mean(oneDirectionEMG, 3);
        MaxIntensitysAtOneDirection = max(meanOneDirectionEMG, [], 1);
        tenDmetadata(direction, :) = MaxIntensitysAtOneDirection;
    end
    tenDmetadata(9, :) = mean(EMG(1:200, :, :), [1 3]); % mean at delay period
%     tenDmetadata(10, :) = mean(meanEMGEachTrial, 2);
    
    % culculate regression
    for channel = (1:emg_channel)
        Y = tenDmetadata(:, channel);
        Ymean = mean(Y);
        Ystd = std(Y);
        normalizedParams(:, channel, t) = [Ymean Ystd];
        tenDmetadataAcrossDays(:, channel, t) = (Y - Ymean) ./ Ystd;
    end

    % normalize EMG data
%     means(t, :) = mean(meanEMGEachTrial, 2);
%     stds(t, :) = std(meanEMGEachTrial, 0, 2);
    normalizedMeanEMG = (meanEMGEachTrial - normalizedParams(1, :, t).') ./ normalizedParams(2, :, t).';
    meanEMGAcrossDays = [meanEMGAcrossDays normalizedMeanEMG];
end


%
%
% save data
%
%
EMGAcrossDays = zeros(801, emg_channel, 0);
for t=(1:length(files))
    file = load('../data/processed/singleTrials_Rocky2022'+files(t)+'_movave_50ms.mat');
    singleTrialData = file.singleTrialData;
    
    dataLength = 0;
    for i=(1:length(singleTrialData))
        stateTransition = singleTrialData(i).prop.stateTransition;
        if all(ismember([3 4 5 6], stateTransition(1,:))) == 1
            dataLength + dataLength + 1;
        end
    end
    
    s = 0;
    EMG = zeros(801, emg_channel, dataLength);
    directionArray = zeros(dataLength);
    rewardArray = zeros(dataLength);
    for i=(1:length(singleTrialData))
        stateTransition = singleTrialData(i).prop.stateTransition;
        if all(ismember([3 4 5 6], stateTransition(1,:))) == 1
            s = s+1;
            GoCueTime = stateTransition(2, find(stateTransition(1, :)==4));
            % start: -200ms end: +600ms at GoCue
            EMGaroundGoCue = singleTrialData(i).emg(GoCueTime-200:GoCueTime+600, :);
            EMG(:,:, s) = EMGaroundGoCue;
            directionArray(s) = singleTrialData(i).prop.direction;
            rewardArray(s) = singleTrialData(i).prop.reward;
        end
    end
    
    normalizedEMG = zeros(size(EMG));
    for channel=(1:emg_channel)
        normalizedEMGEachMuscle = (reshape(EMG(:, channel, :), 801, []) - normalizedParams(1, channel, t)) ./ normalizedParams(2, channel, t);
        normalizedEMG(:, channel, :) = normalizedEMGEachMuscle;
    end
    EMGAcrossDays = cat(3, EMGAcrossDays, normalizedEMG);
end
