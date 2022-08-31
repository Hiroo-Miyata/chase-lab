
% plot(Y)
% title('raw '+string(file.muscleLabel(channel)));
% legend(titles);
% xticklabels({'0', '45', '90', '135', '180', '225', '270', '325', 'hold', 'mean'});


% for channel=(3:3)
%     figure
%     Y = reshape(tenDmetadataAcrossDays(:, channel, :), 9, []);
%     Y(:, 7:9) = [];
%     plot(Y)
%     title(file.muscleLabel(channel));
%     titles(7:9) = [];
%     legend(titles)
%     xticklabels({'0', '45', '90', '135', '180', '225', '270', '325', 'hold'});
% end

for channel=(1:5)
    Y = zeros(8,4);
    for reward=(1:4)
        for direction=(1:8)
            condition = all([directionArray==direction; rewardArray==reward]);
            tmpEMG = normalizedEMGAcrossDays(50:250, channel, condition);
            meanOneDirectionEMG = mean(tmpEMG, 3);
            MaxIntensitysAtOneDirection = mean(meanOneDirectionEMG);
            Y(direction, reward) = MaxIntensitysAtOneDirection;
            % add errorbar visualize standard error of mean
        end
    end
    figure
    plot(Y,'linewidth',2);
    rewColors = {[1 0 0],[1 0.6470 0],[0 0 1],[0 0 0]};
    title(muscleLabel(channel));
    legend(["Small", "Medium", "Large", "Jackpot"])
end

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