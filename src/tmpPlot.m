% load('../data/normalized/Rocky20220216to0303_ma50ms_successesOnly.mat');

movement = exceptionRemovedEMG.data.kinematics.integratedVelosities; % 801 * N
[maxVelosityMagnitudes, maxVelosityIndexs] = max(movement, [], 1); % should be 1*N

over800 = zeros(1,size(movement, 2), 'logical');
for i=(1:length(maxVelosityIndexs))
    if maxVelosityIndexs(i) > 700
        if maxVelosityIndexs(i) < 800
            over800(i) = 1;
        end
    end
end

Y = movement(:, over800);
figure
plot(Y, "Color", [0.7 0.7 0.7])
set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
hold on
plot(mean(Y, 2), "Color", [0 0 0])
hold off
% histogram(maxVelosityIndexs)

%
% coefficient of variation across days
%
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

% 
% z-indexed 9 datapoint metadata
% 
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


% 
% Mean EMG at holding time as a function of reward  
% 
% for channel=(1:5)
%     Y = zeros(1,4);
%     Yerror = zeros(1,4);
%     datapoint = zeros(1,4);
%     for reward=(1:4)
%         tmpEMG = normalizedEMGAcrossDays(50:250, channel, rewardAcrossDays==reward);
%         meanOneDirectionEMG = mean(tmpEMG, 3);
%         MaxIntensitysAtOneDirection = mean(meanOneDirectionEMG);
%         standardError = std(meanOneDirectionEMG) / sqrt(size(tmpEMG, 3));
%         Y(reward) = MaxIntensitysAtOneDirection;
%         Yerror(reward) = standardError;
%         datapoint(reward) = size(tmpEMG, 3);
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


% 
% EMG tuning curve at holding time as a function of reward and direction 
% 
% for channel=(1:5)
%     emg = exceptionRemovedEMG.emg(channel);
%     Y = zeros(8,4);
%     Yerror = zeros(8,4);
%     datapoint = zeros(8,4);
%     for reward=(1:4)
%         for direction=(1:8)
%             condition = all([emg.directionArray==direction; emg.rewardArray==reward]);
%             tmpEMG = emg.signal(50:250, condition);
%             meanOneDirectionEMG = mean(tmpEMG, 2);
%             MaxIntensitysAtOneDirection = mean(meanOneDirectionEMG);
%             standardError = std(meanOneDirectionEMG) / sqrt(size(tmpEMG, 2));
%             Y(direction, reward) = MaxIntensitysAtOneDirection;
%             Yerror(direction, reward) = standardError;
%             datapoint(direction, reward) = size(tmpEMG, 2);
%         end
%     end
%     figure
%     errorbar(Y, Yerror,'linewidth',2);
%     title(muscleLabel(channel));
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