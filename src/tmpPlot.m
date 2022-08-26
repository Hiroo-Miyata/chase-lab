
% plot(Y)
% title('raw '+string(file.muscleLabel(channel)));
% legend(titles);
% xticklabels({'0', '45', '90', '135', '180', '225', '270', '325', 'hold', 'mean'});

% 
% for channel=(3:3)
%     figure
%     Y = reshape(tenDmetadataAcrossDays(:, channel, 1:6), 10, []);
%     plot(Y)
%     title(file.muscleLabel(channel));
%     legend(titles)
% end
% 

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