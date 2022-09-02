emg_channel = 5;
files = ["0216", "0217", "0218", "0221", "0222", "0223", "0224", "0225", "0228", "0301", "0302", "0303"];

%
%
% prepare variables for visualization
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
    directionArray = zeros(1, dataLength);
    rewardArray = zeros(1, dataLength);
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

    % for visualize normalize EMG data
    normalizedMeanEMG = (meanEMGEachTrial - normalizedParams(1, :, t).') ./ normalizedParams(2, :, t).';
    meanEMGAcrossDays = cat(2, meanEMGAcrossDays, normalizedMeanEMG);
end

%
%
% prepare variables for save data
%
%
normalizedEMGAcrossDays = zeros(801, emg_channel, 0);
directionAcrossDays = zeros(0);
rewardAcrossDays = zeros(0);
datapointEachDay = zeros(size(files));
integratedVelositesAcrossDays = zeros(801, 0);
transitionTimeAcrossDays = zeros(2, 5, 0);
%
%
% normalize successes and failures (Be careful! it is different from previous code!!!)
%
%
for t=(1:length(files)) %(1:length(files)
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
    directionArray = zeros(1, dataLength);
    rewardArray = zeros(1, dataLength);
    integratedVelosityArray = zeros(801, dataLength);
    transitionTime = zeros(2, 5, dataLength);
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
            % ここを修正する
            % GoCueTime-200:GoCueTime+600をそれぞれTime関数から取得しindexにに変換する
            movementStartTime = find(singleTrialData(i).timeInTrial == GoCueTime);
%             TargetOnsetTime = stateTransition(2, find(stateTransition(1, :)==6));
%             movementEndTime = find(singleTrialData(i).timeInTrial == TargetOnsetTime);
            velosityEachTrails = singleTrialData(i).handKinematics.velocity(movementStartTime-200:movementStartTime+600, :);
            integratedVelosityArray(:, s) = rssq(velosityEachTrails, 2);
            transitionTime(:, :, s) = stateTransition(:, find(stateTransition(1, :)==3):find(stateTransition(1, :)==3)+4);
        end
    end

    % for save normalize EMG data
    normalizedEMG = zeros(size(EMG));
    for channel=(1:emg_channel)
        normalizedEMGEachMuscle = (reshape(EMG(:, channel, :), 801, []) - normalizedParams(1, channel, t)) ./ normalizedParams(2, channel, t);
        normalizedEMG(:, channel, :) = normalizedEMGEachMuscle;
    end
    normalizedEMGAcrossDays = cat(3, normalizedEMGAcrossDays, normalizedEMG);
    directionAcrossDays = cat(2, directionAcrossDays, directionArray);
    rewardAcrossDays = cat(2, rewardAcrossDays, rewardArray);
    integratedVelositesAcrossDays = cat(2, integratedVelositesAcrossDays, integratedVelosityArray);
    transitionTimeAcrossDays = cat(3, transitionTimeAcrossDays, transitionTime);
    if t == 1
        datapointEachDay(t) = size(normalizedEMG, 3);
    else
        datapointEachDay(t) = size(normalizedEMG, 3) + datapointEachDay(t-1);
    end
end

muscleLabel = file.muscleLabel;

exceptionRemovedEMG = struct;
exceptionRemovedEMG.data.emgs = struct.empty(0);
exceptionRemovedEMG.data.directions = directionAcrossDays;
exceptionRemovedEMG.data.rewards = rewardAcrossDays;
exceptionRemovedEMG.data.kinematics.integratedVelosities = integratedVelositesAcrossDays;
exceptionRemovedEMG.data.transitions = transitionTimeAcrossDays;
exceptionRemovedEMG.preprocessProp.normalizedParams = normalizedParams;
exceptionRemovedEMG.preprocessProp.nineMetadatas = tenDmetadataAcrossDays;
exceptionRemovedEMG.preprocessProp.IndexEachDay = datapointEachDay;

for channel=(1:emg_channel)
    exceptionRemovedEMG.data.emgs(channel).name=muscleLabel(channel);
    exceptionRemovedEMG.data.emgs(channel).signals = reshape(normalizedEMGAcrossDays(:, channel, :), size(normalizedEMGAcrossDays,1), []);
    exceptionRemovedEMG.data.emgs(channel).exceptions = ones(1, length(directionAcrossDays));
    if muscleLabel(channel) == "Trap"
        exceptionRemovedEMG.data.emgs(channel).exceptions(:,1:datapointEachDay(1)) = 0;
    elseif muscleLabel(channel) == "Tric"
        exceptionRemovedEMG.data.emgs(channel).exceptions(:,datapointEachDay(5)+1:datapointEachDay(9)) = 0;
    elseif muscleLabel(channel) == "LBic"
        exceptionRemovedEMG.data.emgs(channel).exceptions(:,datapointEachDay(8)+1:datapointEachDay(9)) = 0;
    elseif muscleLabel(channel) == "PDel"
        exceptionRemovedEMG.data.emgs(channel).exceptions(:,datapointEachDay(8)+1:datapointEachDay(9)) = 0;
    end
end

clearvars -except exceptionRemovedEMG