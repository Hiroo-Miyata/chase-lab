% load('../data/normalized/Rocky20220216to0303_ma50ms_successesOnly.mat');
% load('../data/normalized/Rocky20220216to0303_ma50ms_345.mat');
% movement = exceptionRemovedEMG.data.kinematics.integratedVelosities; % timewindow * N
% [maxVelosityMagnitudes, maxVelosityIndexs] = max(movement, [], 1); % should be 1*N
% 
% normals = zeros(1,size(movement, 2), 'logical');
% for i=(1:length(maxVelosityIndexs))
%     if maxVelosityIndexs(i) > 300+200
%         normals(i) = 1;
%     end
% end
% 
% Y = zeros(1, 4);
% Yerror = zeros(1, 4);
% for reward=(1:4)
%     condition = all([exceptionRemovedEMG.data.rewards==reward;normals]);
%     Y(reward) = mean(maxVelosityMagnitudes(condition));
%     Yerror(reward) = std(maxVelosityMagnitudes(condition)) / length(maxVelosityMagnitudes(condition));
% end
% errorbar(Y, Yerror, 'Color', "k",'linewidth',2)
% set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
% xticks([1 2 3 4]);
% xticklabels({'Small', 'Medium', 'Large', 'Jackpot'});

% for channel=(1:1)
%     data = exceptionRemovedEMG.data;
%     emg = exceptionRemovedEMG.data.emgs(channel);
%     idx = (1:size(emg.signals, 2));
%     fetchedEMG = mean(emg.signals(50:250, cast(emg.exceptions, 'logical')), 1);
%     fetchedIdx = idx(cast(emg.exceptions, 'logical'));
%     
% %     plot(fetchedEMG(fetchedEMG < -1.5))
%     weirdIdx = fetchedIdx(fetchedEMG < -1.5);
%     plot(emg.signals(:, weirdIdx))
% end

%% check normalization method
dates = ["0222", "0221"];
figure
for date=dates
    load('../data/normalized/singleTrials_Rocky2022' + date + '_50ms.mat');
    Y = (EMGMetrics.maxSignalTuningCurve_mean - EMGMetrics.normalizedParams(1,:)) ./ EMGMetrics.normalizedParams(2,:);
    plot(Y)
    rewColors = [1 0 0; 1 0.6470 0; 0 0.6470 0; 0 0 1; 0 0 0];
    colororder(rewColors);
    hold on
end
set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
hold off

%% EMG fatigue across the session

% parameters = zeros(2, 0);
% for channel=(1:5)
%     data = exceptionRemovedEMG.data;
%     emg = exceptionRemovedEMG.data.emgs(channel);
%     acrossday = zeros(size(emg.exceptions));
%     startTrial = 1;
%     for day = (1:length(exceptionRemovedEMG.preprocessProp.IndexEachDay))
%         fetchedEMG = mean(emg.signals(50:250, startTrial:exceptionRemovedEMG.preprocessProp.IndexEachDay(day)), 1); %-150~+50ms
%         exception = emg.exceptions(startTrial:exceptionRemovedEMG.preprocessProp.IndexEachDay(day));
%         fetchedEMG = fetchedEMG(cast(exception, "logical"));
%         startTrial = exceptionRemovedEMG.preprocessProp.IndexEachDay(day)+1;
%         fprintf("emg size: %d \n", length(fetchedEMG));
%         if length(fetchedEMG) > 2
%             X = (1:length(fetchedEMG));
%             Y = fetchedEMG;
%             covariance = cov(Y, X);
%             alpha = covariance(1,2) / var(X);
%             beta = mean(Y) - alpha * mean(X);
%             parameters(:, end+1) = [beta beta+alpha*500];
% %             figure
% %             plot(X,Y, 'color', [.5 .5 .5])
% %             hold on
% %             plot(X, (alpha*X+beta), "k", "LineWidth", 2);
% %             title([emg.name,": Day",num2str(day)]);
% %             hold off
%         end
%     end
% end
% 
% 
% plot([1 500], reshape(parameters, 2, []), 'color', [.5 .5 .5])
% hold on
% plot([1 500], mean(reshape(parameters, 2, []), 2), "k", 'linewidth', 3)
% set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out', "LineWidth", 1.5);
% xlabel("trials")
% ylabel("regression EMG")
% title("regression EMG of all muscle")
% hold off

%% EMG variablity as a function of reward
% 
% Y0 = zeros(5, 8, 4);
% Y = zeros(40, 4);
% for channel=(1:5)
%     data = exceptionRemovedEMG.data;
%     emg = exceptionRemovedEMG.data.emgs(channel);
%     for direction=(1:8)
%         condition = all([data.directions==direction; emg.exceptions]);
%         rewardArray = data.rewards(condition);
%         fetchedEMG = mean(emg.signals(50:250, condition), 1); %-150~+50ms
%         zScoredEMG = zscore(fetchedEMG);
%         for reward=(1:4)
%             Y0(channel,direction, reward) = mean(zScoredEMG(rewardArray==reward));
%             Y(channel*8+direction-8, reward) = mean(zScoredEMG(rewardArray==reward));
%         end
%     end
% end
% scatter(Y, ones(40,4) .* (.1:.1:.4))
% set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out', "LineWidth", 1, ...
%     "XAxisLocation", "origin", "YAxisLocation", 'origin', 'YTickLabel',[]);
% ylim([0 .5])
% xlabel("z-indexed mean EMG around Go Cue")
% rewColors = [1 0 0; 1 0.6470 0; 0 0 1; 0 0 0];
% colororder(rewColors);
% gca.YAxis.Visible = 'off';
% box off;

%% mean trajectories around Go Cue(-200~+600) as a function of direction
% for channel=(1:5)
%     data = exceptionRemovedEMG.data;
%     emg = exceptionRemovedEMG.data.emgs(channel);
%     Y = zeros(801, 8);
%     for direction=(1:8)
%         condition = all([data.directions==direction; emg.exceptions]);
%         fetchedEMG = emg.signals(1:801, condition);
%         Y(:, direction) = mean(fetchedEMG, 2);
%     end
%     figure
%     plot(Y, "LineWidth", 2)
%     set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out', "LineWidth", 2);
% end


%% histogram of the time spent on reaching period of both successes and failure 
% for channel=(5:5)
%     successes = [];
%     failures = [];
%     for i=(1:size(exceptionRemovedEMG.data.transitions, 3))
%         transition = exceptionRemovedEMG.data.transitions(:, :, i);
%         if transition(1,4) == 6
%             successes = [successes, int32(transition(2,4)-transition(2,2))];
%         else
%             failures = [failures, int32(transition(2,4)-transition(2,2))];
%         end
%     end
%     histogram(successes,'FaceAlpha',0.2, "FaceColor","r")
%     hold on
%     histogram(failures,'FaceAlpha',0.2, "FaceColor","b")
%     hold off
% end
       

%     emg = exceptionRemovedEMG.data.emgs(channel); 

%% visualize mean EMG across day

% for channel = (1:5)
%     emg = exceptionRemovedEMG.data.emgs(channel);
%     Y = emg.signals(50:251, cast(emg.exceptions, 'logical'));
%     figure
%     plot(mean(Y, 1),'linewidth',2)
%     title(emg.name);
%     set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
%     hold off
% end


%% visualize mean EMG around velocity peak value aligned by holding time 

% baseline = zeros(8, 5);
% for channel=(1:5)
%     emg = exceptionRemovedEMG.data.emgs(channel);
%     for direction=(1:8)
%         EMGtmp = emg.signals(50:250, exceptionRemovedEMG.data.directions==direction);
%         meanOneDirectionEMG = mean(EMGtmp, 2);
%         baseline(direction, channel) = mean(meanOneDirectionEMG);
%     end
% end
% datapoint = zeros(8,4,5);
% for channel=(1:5) %1:length(exceptionRemovedEMG.data.emgs)
%     data = exceptionRemovedEMG.data;
%     emg = exceptionRemovedEMG.data.emgs(channel);
% 
%     Y = zeros(8,4);
%     Yerror = zeros(8,4);
%     for reward=(1:4)
%         for direction=(1:8)
%             condition = all([data.directions==direction; data.rewards==reward; normals; emg.exceptions]);
%             maxVelosityIndexsConditioned = maxVelosityIndexs(condition);
%             EMGtmp = emg.signals(:, condition);
%             EMGAroundPeak = zeros(1, size(EMGtmp, 2));
%             for i=(1:length(maxVelosityIndexsConditioned))
%                 maxVIdx = maxVelosityIndexsConditioned(i);
%                 EMGAroundPeak(i) = mean(EMGtmp(maxVIdx-100:maxVIdx+100, i));
%             end
%             MeanIntensitysAtOneDirection = mean(EMGAroundPeak);
%             standardError = std(EMGAroundPeak) / sqrt(length(EMGAroundPeak));
%             Y(direction, reward) = MeanIntensitysAtOneDirection;
%             Yerror(direction, reward) = standardError;
%             datapoint(direction, reward, channel) = size(EMGtmp, 2);
%         end
%     end
%     figure
%     errorbar(abs(Y-baseline(:,channel)), Yerror,'linewidth',2);
%     title(emg.name);
%     legend(["Small", "Medium", "Large", "Jackpot"])
%     rewColors = [1 0 0; 1 0.6470 0; 0 0 1; 0 0 0];
%     colororder(rewColors);
%     set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
%     xticks([1 2 3 4 5 6 7 8]);
%     xticklabels({'0', '45', '90', '135', '180', '225', '270', '325'});
%     xlim([0.5 8.5]);
% end

%% visualize mean EMG around velocity peak value

% datapoint = zeros(8,4,5);
% for channel=(1:5) %1:length(exceptionRemovedEMG.data.emgs)
%     data = exceptionRemovedEMG.data;
%     emg = exceptionRemovedEMG.data.emgs(channel);
% 
%     Y = zeros(8,4);
%     Yerror = zeros(8,4);
%     for reward=(1:4)
%         for direction=(1:8)
%             condition = all([data.directions==direction; data.rewards==reward; normals; emg.exceptions]);
%             maxVelosityIndexsConditioned = maxVelosityIndexs(condition);
%             EMGtmp = emg.signals(:, condition);
%             EMGAroundPeak = zeros(1, size(EMGtmp, 2));
%             for i=(1:length(maxVelosityIndexsConditioned))
%                 maxVIdx = maxVelosityIndexsConditioned(i);
%                 EMGAroundPeak(i) = mean(EMGtmp(maxVIdx-100:maxVIdx+100, i));
%             end
%             MeanIntensitysAtOneDirection = mean(EMGAroundPeak);
%             standardError = std(EMGAroundPeak) / sqrt(length(EMGAroundPeak));
%             Y(direction, reward) = MeanIntensitysAtOneDirection;
%             Yerror(direction, reward) = standardError;
%             datapoint(direction, reward, channel) = size(EMGtmp, 2);
%         end
%     end
%     figure
%     errorbar(Y, Yerror,'linewidth',2);
%     title(emg.name);
%     legend(["Small", "Medium", "Large", "Jackpot"])
%     rewColors = [1 0 0; 1 0.6470 0; 0 0 1; 0 0 0];
%     colororder(rewColors);
%     set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
%     xticks([1 2 3 4 5 6 7 8]);
%     xticklabels({'0', '45', '90', '135', '180', '225', '270', '325'});
%     xlim([0.5 8.5]);
% end

% Y = movement(:, normals);
% figure
% plot(Y, "Color", [0.7 0.7 0.7]);
% set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
% hold on
% plot(mean(Y, 2), "Color", [0 0 0])
% hold off
% histogram(maxVelosityMagnitudes(normals))
% title("Histogram of maxVelosityMagnitudes for each trial")
% histogram(maxVelosityIndexs(normals)-200)
% title("Histogram of maxVelosityMagnitudes for each trial")


%% coefficient of variation across days

% figure
% for channel=(1:5)
%     titles = {'Day1', 'Day2', 'Day3', 'Day4', 'Day5', 'Day6', 'Day7', 'Day8', 'Day9', 'Day10', 'Day11', 'Day12'};
%     Y = normalizedParams(2, channel, :) ./ normalizedParams(1, channel, :);
%     Y = reshape(Y, 1, []);
%     if file.muscleLabel(channel) == "Tric"
%         Y(5:9) = [];
%         titles(5:9) = [];
%     elseif file.muscleLabel(channel) == "Trap"
%         Y(1) = [];
%         titles(1) = [];
%     elseif file.muscleLabel(channel) == "LBic" || file.muscleLabel(channel) == "PDel"
%         Y(9) = [];
%         titles(9) = [];
%     end
%     plot(Y,'linewidth',2)
%     hold on
% end
% legend(file.muscleLabel)
% set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
% hold off


%% z-indexed 9 datapoint metadata 

% for channel=(1:5)
%     titles = {'Day1', 'Day2', 'Day3', 'Day4', 'Day5', 'Day6', 'Day7', 'Day8', 'Day9', 'Day10', 'Day11', 'Day12'};
%     figure
%     Y = reshape(tenDmetadataAcrossDays(:, channel, :), 9, []);
%     if file.muscleLabel(channel) == "Tric"
%         Y(:, 5:9) = [];
%         titles(5:9) = [];
%     elseif file.muscleLabel(channel) == "Trap"
%         Y(:, 1) = [];
%         titles(1) = [];
%     elseif file.muscleLabel(channel) == "LBic" || file.muscleLabel(channel) == "PDel"
%         Y(:, 9) = [];
%         titles(9) = [];
%     end
%     plot(Y)
%     title(file.muscleLabel(channel));
%     legend(titles)
%     xticklabels({'0', '45', '90', '135', '180', '225', '270', '325', 'hold'});
% end

 
%% Mean EMG at holding time as a function of reward  

% for channel=(1:5)
%     Y = zeros(1,4);
%     Yerror = zeros(1,4);
%     datapoint = zeros(1,4);
%     for reward=(1:4)
%         EMGtmp = normalizedEMGAcrossDays(50:250, channel, rewardAcrossDays==reward);
%         meanOneDirectionEMG = mean(EMGtmp, 3);
%         MaxIntensitysAtOneDirection = mean(meanOneDirectionEMG);
%         standardError = std(meanOneDirectionEMG) / sqrt(size(EMGtmp, 3));
%         Y(reward) = MaxIntensitysAtOneDirection;
%         Yerror(reward) = standardError;
%         datapoint(reward) = size(EMGtmp, 3);
%     end
%     figure
%     errorbar([1 2 3 4],Y, Yerror,'linewidth',2);
%     title(muscleLabel(channel));
%     xticks([1 2 3 4]);
%     xticklabels(["Small", "Medium", "Large", "Jackpot"]);
% %     rewColors = [1 0 0; 1 0.6470 0; 0 0 1; 0 0 0];
% %     colororder(rewColors);
%     set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
% end


%% EMG tuning curve at holding time as a function of reward and direction 

% for channel=(1:5)
%     data = exceptionRemovedEMG.data;
%     emg = exceptionRemovedEMG.data.emgs(channel);
%     Y = zeros(8,4);
%     Yerror = zeros(8,4);
%     datapoint = zeros(8,4);
%     for reward=(1:4)
%         for direction=(1:8)
%             condition = all([data.directions==direction; data.rewards==reward; emg.exceptions]);
%             EMGtmp = emg.signals(50:250, condition);
%             meanOneDirectionEMG = mean(EMGtmp, 2);
%             meanIntensitysAtOneDirection = mean(meanOneDirectionEMG);
%             standardError = std(meanOneDirectionEMG) / sqrt(size(EMGtmp, 2));
%             Y(direction, reward) = meanIntensitysAtOneDirection;
%             Yerror(direction, reward) = standardError;
%             datapoint(direction, reward) = size(EMGtmp, 2);
%         end
%     end
%     figure
%     errorbar(Y, Yerror,'linewidth',2);
%     title(emg.name);
%     legend(["Small", "Medium", "Large", "Jackpot"])
%     rewColors = [1 0 0; 1 0.6470 0; 0 0 1; 0 0 0];
%     colororder(rewColors);
%     set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
%     xticks([1 2 3 4 5 6 7 8]);
%     xticklabels({'0', '45', '90', '135', '180', '225', '270', '325'});
%     xlim([0.5 8.5]);
% end

% 
% for c=(3:3)
%     figure
%     Y = reshape(normalizedParams(:, c, :), 2, []);
%     scatter(Y(1, :), Y(2, :));
%     title(file.muscleLabel(c));
%     dx = 0.05; dy = 0.1; % displacement so the text does not overlay the data points
%     text(Y(1, :)+dx, Y(2, :)+dy, titles);
% end

% x=1:12;
% for c=(1:1)
%     figure
%     scatter(means(:, c), stds(:, c));
%     title('Mean and std of ' + string(file.muscleLabel(c)) + ' at each day');
%     xlabel('Mean')
%     ylabel('Standard')
% end

%  
% for c=(3:3) % !!!!!!!!!
%     figure
%     plotMeanEMG = plot(EMGAcrossDays(c, :), 'b');
%     hold on;
%     plotXline = xline(endofTrialByDays(1:length(endofTrialByDays)-1), '-', titles, 'LineWidth', 1.5);
%     hold off;
%     title('Mean EMG of ' + string(file.muscleLabel(c)) + ' around Go Cue (-200 ~ +600 ms)');
%     xlabel('Trials');
%     ylabel('Mean EMG (a.u)');
%     ylim([0 300]);
% end