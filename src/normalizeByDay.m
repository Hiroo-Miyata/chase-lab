emg_channel = 5;
files = ["0216", "0217", "0218", "0221", "0222", "0223", "0224", "0225", "0228", "0301", "0302", "0303"]; %!!!!!!!!!!!

EMGAcrossDays = zeros(5, 0);
baselines = zeros(5, 0);
endofTrialByDays = zeros(length(files)+1, 1);
titles = {'Day1', 'Day2', 'Day3', 'Day4', 'Day5', 'Day6', 'Day7', 'Day8', 'Day9', 'Day10', 'Day11', 'Day12'};
means = zeros(length(files), emg_channel);
stds = zeros(length(files), emg_channel);
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
    
    meanEMGEachTrial = mean(EMG, 1);
    meanEMGEachTrial = reshape(meanEMGEachTrial, 5, []);
    endofTrialByDays(t+1) = endofTrialByDays(t) + int16(size(meanEMGEachTrial, 2));
    EMGAcrossDays = [EMGAcrossDays meanEMGEachTrial];
    emgRest = file.emg_rest; % 120s * channel
    baseline = zeros(size(meanEMGEachTrial)) + reshape(mean(emgRest, 1), 5, []);
    baselines = [baselines baseline];
    means(t, :) = mean(meanEMGEachTrial, 2);
    stds(t, :) = std(meanEMGEachTrial, 0, 2);
end

x=1:12;
% for c=(1:1)
%     figure
%     scatter(means(:, c), stds(:, c));
%     title('Mean and std of ' + string(file.muscleLabel(c)) + ' at each day');
%     xlabel('Mean')
%     ylabel('Standard')
% end

% for c=(1:5) % !!!!!!!!!
%     figure
%     plotMeanEMG = plot(EMGAcrossDays(c, :), 'b');
%     hold on;
%     plotBaseline = plot(baselines(c, :), ':', 'Color', 'r', 'LineWidth', 1.5);
%     hold on;
%     plotXline = xline(endofTrialByDays(1:length(endofTrialByDays)-1), '-', titles, 'LineWidth', 1.5);
%     hold off;
% %     legend([plotMeanEMG plotBaseline], {'mean EMG at each trial', 'baseline noise at rest period'});
%     title('Mean EMG of ' + string(file.muscleLabel(c)) + ' around Go Cue (-200 ~ +600 ms)');
%     xlabel('Trials');
%     ylabel('Mean EMG (a.u)');
% end


% for t=(1:length(files))
%     file = load('../data/processed/singleTrials_Rocky2022'+files(t)+'_movave_50ms.mat');
%     singleTrialData = file.singleTrialData;
%     emg_channel = 5;
%     
%     dataLength = 0;
%     for i=(1:length(singleTrialData))
%         stateTransition = singleTrialData(i).prop.stateTransition;
%         if all(ismember([3 4 5 6], stateTransition(1,:))) == 1
%             dataLength + dataLength + 1;
%         end
%     end
%     
%     s = 0;
%     EMG = zeros(801, emg_channel, dataLength);
%     directionArray = zeros(dataLength);
%     rewardArray = zeros(dataLength);
%     for i=(1:length(singleTrialData))
%         stateTransition = singleTrialData(i).prop.stateTransition;
%         if all(ismember([3 4 5 6], stateTransition(1,:))) == 1
%             s = s+1;
%             GoCueTime = stateTransition(2, find(stateTransition(1, :)==4));
%             % start: -200ms end: +600ms at GoCue
%             EMGaroundGoCue = singleTrialData(i).emg(GoCueTime-200:GoCueTime+600, :);
%             EMG(:,:, s) = EMGaroundGoCue;
%             directionArray(s) = singleTrialData(i).prop.direction;
%             rewardArray(s) = singleTrialData(i).prop.reward;
%         end
%     end
%     
%     meanEMGEachTrial = mean(EMG, 1);
%     meanEMGEachTrial = reshape(meanEMGEachTrial, 5, []);
%     endofTrialByDays(t+1) = endofTrialByDays(t) + int16(size(meanEMGEachTrial, 2));
%     emgRest = file.emg_rest; % 120s * channel
%     baselines = reshape(mean(emgRest, 1), 5, []);
%     normalizedEMG = (meanEMGEachTrial - baselines) ./ max(meanEMGEachTrial, [], 2);
%     EMGAcrossDays = [EMGAcrossDays normalizedEMG];
% end
% 
% for c=(1:1) % !!!!!!!!!
%     figure
%     plotMeanEMG = plot(EMGAcrossDays(c, :), 'b');
%     hold on;
%     plotXline = xline(endofTrialByDays(1:length(endofTrialByDays)-1), '-', {'Day1', 'Day2'}, 'LineWidth', 1.5);
%     hold off;
%     legend(plotMeanEMG, 'normalized EMG');
%     title('Mean EMG of ' + string(file.muscleLabel(c)) + ' around Go Cue (-200 ~ +600 ms)');
%     xlabel('Trials');
%     ylabel('Mean EMG (a.u)');
% end