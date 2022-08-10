% 1. fetch trials from all data
file = load('../data/processed/singleTrials_20220223.mat');
singleTrialData = file.singleTrialData;

dataLength = 0;
for i=(1:length(singleTrialData))
    stateTransition = singleTrialData(i).prop.stateTransition;
    % fetch 1-2-3-4-5-6-7 transition (should use 6-13 failure ????)
    if all(ismember([3 4 5 6 7], stateTransition(1,:))) == 1
        dataLength + dataLength + 1;
    end
end

s = 0;
MEG = zeros(801, 5, dataLength);
directionArray = zeros(dataLength);
rewardArray = zeros(dataLength);
for i=(1:length(singleTrialData))
    stateTransition = singleTrialData(i).prop.stateTransition;
    % fetch 1-2-3-4-5-6-7 transition (should use 6-13 failure ????)
    if all(ismember([3 4 5 6 7], stateTransition(1,:))) == 1
        s = s+1;
        GoCueTime = stateTransition(2, find(stateTransition(1, :)==4));
        % start: -200ms end: +600ms at GoCue
        MEGaroundGoCue = singleTrialData(i).emg(GoCueTime-200:GoCueTime+600, :);
        MEG(:,:, s) = MEGaroundGoCue;
        directionArray(s) = singleTrialData(i).prop.direction;
        rewardArray(s) = singleTrialData(i).prop.reward;
    end
end

% 2. show each signal and mean trajectory
X = (-200:600);
plotPosition = [6, 3, 2, 1, 4, 7, 8, 9];
for channel=(1:5)
    figure
    for direction=(1:8)
        Y = MEG(:,channel,directionArray==direction);
        plotY = reshape(Y, 801, []);
        subplot(3,3, plotPosition(direction));
        plot(X, plotY, 'Color', '#aaaaaa');
        hold on
        plot(X, mean(plotY, 2), 'Color', 'k');
        hold off
    end
    sgtitle(string(file.muscle(channel)) + ' at each direction');
end

% transDict = containers.Map;
% transTimeDict = containers.Map;
% for i = (1:length(movementData.data))
%     a = movementData.data(i).TrialData.stateTransitions;
%     key = string(sum(a(1,:)));
%     if isKey(transDict, key)
%         transDict(key) = transDict(key) + 1;
%     else
%         transDict(key) = 1;
%         a(1,:)
%     end
%     for s = (1:length(a(1,:))-2)
%         key = string(sum(a(1,s:s+1)));
%         value = a(2,s+1) - a(2,s);
%         if isKey(transTimeDict, key)
%             transTimeDict(key) = [transTimeDict(key) value];
%         else
%             transTimeDict(key) = [value];
%         end
%     end
% end
% 
% 
% x = [a5.'; a7.'; a9.'; a11.'; a13.']
% g = [repmat({'2-3'}, length(a5), 1); repmat({'3-4'}, length(a7), 1); repmat({'4-5'}, length(a9), 1); repmat({'5-6'}, length(a11), 1); repmat({'6-7'}, length(a13), 1)];
% boxplot(x,g)