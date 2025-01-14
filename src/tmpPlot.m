% clear all
close all

% load('../data/normalized/Rocky20220216to0303_ma50ms_successesOnly.mat');
% load('../data/normalized/emg/Rocky20220216to0303_ma50ms_345.mat');


%% choking paper debuging: find the reason of trap-correlation by day or direction
load('../data/processed/Rocky_rewProjDataByDay.mat');
load("../data/processed/singleTrials_Rocky2022to0303_0922_all.mat");

startidx=1;
muscle = 4; %trap
X = cell(length(rewProjData_byDay), 4);
Y = cell(length(rewProjData_byDay), 4);
% X = cell(8,4);
% Y = cell(8,4);
for d=(1:length(rewProjData_byDay))
    rewardAxises = rewProjData_byDay{d};
    removeIndex = ~isnan(rewardAxises);
    nanRemovedRAxis = rewardAxises(removeIndex);
    
    TrialDataByDay = wholeTrialData.data(startidx:startidx+length(rewardAxises)-1);
    nanRemovedTrialData = TrialDataByDay(removeIndex);
    nanRemovedEMG = [nanRemovedTrialData.emg];
%     emgs = cat(3, nanRemovedEMG.EMG);
    goodEMG = vertcat(nanRemovedEMG.goodEMGData);
    kinematicsData = [nanRemovedTrialData.kinematics];
    rewardArray = [kinematicsData.rewardLabel];
    directionArray = [kinematicsData.directionLabel];
    
    for reward=(1:4)
%         for direction=(1:8)
%             condition = all([goodEMG(:, muscle).'; rewardArray==reward; directionArray==direction]);
            condition = all([goodEMG(:, muscle).'; rewardArray==reward]);
            selectedTrialData = nanRemovedTrialData(condition);
            emgdata = [selectedTrialData.emg];
            if ~isempty(emgdata)
                emgs = cat(3, emgdata.EMG);
                result = reshape(mean(emgs(50:250, muscle, :), 1), [size(emgs, 3),1]);
                Y{d, reward} = cat(1, Y{d, reward}, result);
                X{d, reward} = cat(1, X{d, reward}, nanRemovedRAxis(condition));
%                 Y{direction, reward} = cat(1, Y{direction, reward}, result);
%                 X{direction, reward} = cat(1, X{direction, reward}, nanRemovedRAxis(condition));
                for singleTrialData = selectedTrialData
                    if singleTrialData.emg.goodEMGData(muscle) ~= 1
                        error('incorrect label is included')
                    end
                end
            end
%         end
    end 
    startidx=startidx+length(rewardAxises);
end
rewColors = [1 0 0; 1 0.6470 0; 0 0 1; 0 0 0];

figure
legendLabel = ["", "", "", ""];
rewardLabel = ["S", "M", "L", "J"];
for reward=(1:4)
    Xall = cat(1, X{[4,5,6,8,9,10], reward});
    Yall = cat(1, Y{[4,5,6,8,9,10], reward});
    scatter(Yall, Xall, 4, rewColors(reward, :), ...
        'filled', 'MarkerEdgeAlpha', .1, 'MarkerFaceAlpha',.1);
    hold on
    meanplot(reward) = scatter(mean(Yall), mean(Xall), 75, rewColors(reward, :), ...
        'filled');
    hold on
    r=corrcoef(Yall, Xall);
    legendLabel(reward) = "r_" + rewardLabel(reward) + " = "+ num2str(round(r(1,2), 2));
end
hold off
ylabel('Reward Axis');
xlabel('average EMG around GoCue');
legend(meanplot, legendLabel, Location="best");
title('Relationship Between RewardAxis and mean ' + wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle));
    saveas(gcf, "../result/images/202210w2/corrTrapEachDay/"+ ...
        wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle) +"-Day23711rem" + ".jpg");
% saveas(gcf, "../result/images/202210w2/corrTrapEachDirection/"+ ...
%     wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle) +"-" + ...
%     num2str(45*(d-1)) + ".jpg");
close all
% for d=(1:size(X, 1))
%     figure
%     legendLabel = ["", "", "", ""];
%     rewardLabel = ["S", "M", "L", "J"];
%     for reward=(1:4)
%         scatter(Y{d, reward}, X{d, reward}, 4, rewColors(reward, :), ...
%             'filled', 'MarkerEdgeAlpha', .1, 'MarkerFaceAlpha',.1);
%         hold on
%         meanplot(reward) = scatter(mean(Y{d, reward}), mean(X{d, reward}), 75, rewColors(reward, :), ...
%             'filled');
%         hold on
%         r=corrcoef(Y{d, reward}, X{d, reward});
%         legendLabel(reward) = "r_" + rewardLabel(reward) + " = "+ num2str(round(r(1,2), 2));
%     end
%     hold off
%     ylabel('Reward Axis');
%     xlabel('average EMG around GoCue');
%     legend(meanplot, legendLabel, Location="best");
%     title('Relationship Between RewardAxis and mean ' + wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle));
% %     saveas(gcf, "../result/images/202210w2/corrTrapEachDay/"+ ...
% %         wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle) +"-Day" + ...
% %         num2str(d) + ".jpg");
%     saveas(gcf, "../result/images/202210w2/corrTrapEachDirection/"+ ...
%         wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle) +"-" + ...
%         num2str(45*(d-1)) + ".jpg");
%     close all
% end


%% Fatigue: summation of Peri-movement change across session
% load("../data/processed/singleTrials_Rocky2022to0303_0922.mat");
% 
% startidx=1;
% 
% allY = cell(5,1);
% allYwithD = cell(5,8);
% for day=(1:length(wholeTrialData.sessionProp))
%     endidx = wholeTrialData.sessionProp(day).dataSizes;
%     trialDataByDay = wholeTrialData.data(startidx:startidx+endidx-1);
%     kinematicsData = [trialDataByDay.kinematics];
%     EMGData = [trialDataByDay.emg];
%     directionArray = [kinematicsData.directionLabel];
%     goodEMGMatrix = vertcat(EMGData.goodEMGData);
%     for muscle=(1:5)
%         dirColor = [0 0 0;1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 0.5 0.5 0.5];
%         maxX = 0;
%         for direction=(1:8)
%             condition = all([directionArray==direction;goodEMGMatrix(:, muscle).']);
%             selectedTrialData = trialDataByDay(condition);
%             if ~isempty(selectedTrialData)
%                 emgdata = [selectedTrialData.emg];
%                 emgs = cat(3, emgdata.EMG); % 801 * 5 * ntrial
%                 emgs = reshape(emgs(:, muscle, :), 801, []);
%     
%                 kinematicsData = [selectedTrialData.kinematics];
%                 handMovementData = cat(3, kinematicsData.handKinematics); % 801 * 3 * ntrial
%                 synthesisVelocities = rssq(handMovementData, 2); % 801 * ntrial
%                 [maxVelosityMagnitudes, maxVelosityIndexs] = max(synthesisVelocities, [], 1); % should be 1*N
%                 normals = true(length(maxVelosityIndexs), 1);
%                 for i=(1:length(maxVelosityIndexs))
%                     if maxVelosityIndexs(i) < 300+200
%                         normals(i) = false;
%                     elseif maxVelosityIndexs(i) > 700
%                         normals(i) = false;
%                     end
%                 end
% 
% %                 if sum(normals)/ length(normals) < 0.9
% %                     fprintf("muscle: " + num2str(muscle) + ", direction: " + num2str(direction) + ", Day"+num2str(day) ...
% %                         + ", ratio: " + num2str(sum(normals)/ length(normals)) + "\n");
% %                 end
%                 idx = maxVelosityIndexs(normals);
%                 processedEMG = emgs(:, normals);
%                 
%                 Y = zeros(size(processedEMG, 2), 1);
%                 for i=(1:size(processedEMG, 2))
%                     Y(i) = mean(processedEMG(idx(i)-100:idx(i)+100, i));
%                 end
%                   
%                 idxBin = round(0.2*length(Y));
%                 changeRatio = mean(Y(end-idxBin+1:end)) - mean(Y(1:idxBin));
% 
%                 allY{muscle}(end+1) = changeRatio;
%                 allYwithD{muscle, direction}(:, end+1) = [mean(Y(1:idxBin)), mean(Y(end-idxBin+1:end))];
% %                 plot((1:length(Y)), movmean(Y.', 20), LineWidth=2);
% %                 if maxX < length(Y)
% %                     maxX = length(Y);
% %                 end
% %                 hold on
%             end
% 
%         end
% %         hold off
% %         legend(["0", "45", "90", "135", "180", "225", "270", "315"])
% %         xlim([0 maxX+40])
% %         title(wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle) + "-Day" + num2str(day))
% %         xlabel("Trials")
% %         ylabel("Mean EMG around peak velocity")
% %         saveas(gcf, "../result/images/202209w4/FatigueEachDay/" + ...
% %             wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle) + "-Day" + num2str(day) ...
% %             + ".jpg");
% %         close all
%     end
%     startidx=startidx+endidx;
% end
% 
% pValues = zeros(5,8);
% for muscle=(5:5)
%     figure
%     plotPositions = [6, 3, 2, 1, 4, 7, 8, 9];
%     for direction=(1:8)
%         subplot(3,3, plotPositions(direction))
%         edges = (-2.5:0.25:0);
%         histogram(allYwithD{muscle, direction}(1, :), edges, EdgeColor="none", FaceColor=[0.7 0.7 0.7]);
%         hold on
%         histogram(allYwithD{muscle, direction}(2, :), edges, EdgeColor="none", FaceColor='k');
%         hold on
%         xline(mean(allYwithD{muscle, direction}(1, :)), Color="r", LineWidth=2)
%         hold on
%         xline(mean(allYwithD{muscle, direction}(2, :)), Color="b", LineWidth=2)
%         [h,p] = ttest(allYwithD{muscle, direction}(1, :), allYwithD{muscle, direction}(2, :));
%         pValues(muscle, direction) = p;
%         title("p="+num2str(p));
%     end
%     xlabel("mean EMG around peak")
%     ylabel("counts")
%     sgtitle(wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle) + ...
%         " change between first and last 20% trial");
%     hold off
% end

%% Fatigue: Peri-movement EMG change across session
% load("../data/processed/singleTrials_Rocky2022to0303_0922.mat");
% 
% startidx=1;
% 
% allY = cell(5,1);
% for day=(1:length(wholeTrialData.sessionProp))
%     endidx = wholeTrialData.sessionProp(day).dataSizes;
%     trialDataByDay = wholeTrialData.data(startidx:startidx+endidx-1);
%     kinematicsData = [trialDataByDay.kinematics];
%     EMGData = [trialDataByDay.emg];
%     directionArray = [kinematicsData.directionLabel];
%     goodEMGMatrix = vertcat(EMGData.goodEMGData);
%     for direction=(1:8)
%         for muscle=(1:5)
%             condition = all([directionArray==direction;goodEMGMatrix(:, muscle).']);
%             selectedTrialData = trialDataByDay(condition);
%             if ~isempty(selectedTrialData)
%                 emgdata = [selectedTrialData.emg];
%                 emgs = cat(3, emgdata.EMG); % 801 * 5 * ntrial
%                 emgs = reshape(emgs(:, muscle, :), 801, []);
%                 smoothedEMG = movmean(emgs, 100, 1);
%                 maxEMG = max(smoothedEMG, [], 1);
%     
%                 kinematicsData = [selectedTrialData.kinematics];
%                 handMovementData = cat(3, kinematicsData.handKinematics); % 801 * 3 * ntrial
%                 synthesisVelocities = rssq(handMovementData, 2); % 801 * ntrial
%                 [maxVelosityMagnitudes, maxVelosityIndexs] = max(synthesisVelocities, [], 1); % should be 1*N
%                 normals = true(length(maxVelosityIndexs), 1);
%                 for i=(1:length(maxVelosityIndexs))
%                     if maxVelosityIndexs(i) < 300+200
%                         normals(i) = false;
%                     elseif maxVelosityIndexs(i) > 750
%                         normals(i) = false;
%                     end
%                 end
%                 idx = maxVelosityIndexs(normals);
%                 processedEMG = emgs(:, normals);
%                 
%                 Y = zeros(size(processedEMG, 2), 1);
%                 for i=(1:size(processedEMG, 2))
%                     Y(i) = mean(processedEMG(idx(i)-50:idx(i)+50, i));
%                 end
%                 Y = maxEMG;
%     
%                 figure
%                 plot(Y);
%                 title(wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle) + "-Day" + num2str(day) ...
%                     + "-" + num2str(direction*45-45))
%                 set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
%                 saveas(gcf, "../result/images/202209w3/periMovementEMGEachDirection/max" + ...
%                     wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle) + "-Day" + num2str(day) ...
%                     + "-" + num2str(direction*45-45)+".jpg");
%                 close all
%                 
%                 idxBin = round(0.2*length(Y));
%                 changeRatio = mean(Y(end-idxBin+1:end)) / mean(Y(1:idxBin));
%                 allY{muscle}(end+1) = changeRatio;
%             end
%         end
%     end
%     startidx=startidx+endidx;
% end
% xlabels = string.empty(0);
% for muscle=(1:5)
%     scatter(muscle * ones(size(allY{muscle})), allY{muscle}, '*', "b");
%     hold on
%     xlabels(end+1) = wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle);
%     scatter(muscle, mean(allY{muscle}), '*', "r");
%     [h,p] = ttest(allY{muscle});
%     disp(p)
% end
% set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out', "LineWidth", 2);
% ylabel("last 20% EMG / first 20% EMG")
% xlim([0.5 5.5])
% xticklabels(xlabels)
% yline(1)
% hold off
% 

%% check abnormal EMG 
% load("../data/processed/singleTrials_Rocky2022to0303.mat");
% 
% kinematicsData = [wholeTrialData.data.kinematics];
% EMGData = [wholeTrialData.data.emg];
% rewardArray = [kinematicsData.rewardLabel];
% goodEMGMatrix = vertcat(EMGData.goodEMGData);
% idx = (1:length(wholeTrialData.data));
% for muscle=(2:2)
%     selectedTrialData = wholeTrialData.data(goodEMGMatrix(:, muscle).');
%     selectedidx = idx(goodEMGMatrix(:, muscle).');
%     idx2 = (1:length(selectedTrialData));
%     emgdata = [selectedTrialData.emg];
%     emgs = cat(3, emgdata.EMG); 
%     Y = mean(emgs(50:250, muscle, :), 1);
%     erroridx = selectedidx(find(Y > -2.2));
%     erroridx2 = idx2(find(Y > -2.2));
%     errorEMG = emgs(:, muscle, erroridx2);
%     errorEMG = reshape(errorEMG, size(errorEMG, 1), []);
%     plot(movmean(errorEMG, 100))
% end

%% correlation coeffecient b/w EMG and reward Axis
% load('../data/processed/Rocky_rewProjDataByDay.mat');
% load("../data/processed/singleTrials_Rocky2022to0303_0922_all.mat");
% 
% startidx=1;
% X = cell(1, 5);
% Y = cell(1, 5);
% for d=(1:length(rewProjData_byDay))%length(rewProjData_byDay)
%     rewardAxises = rewProjData_byDay{d};
%     removeIndex = ~isnan(rewardAxises);
%     nanRemovedRAxis = rewardAxises(removeIndex);
%     
%     TrialDataByDay = wholeTrialData.data(startidx:startidx+length(rewardAxises)-1);
%     nanRemovedTrialData = TrialDataByDay(removeIndex);
%     nanRemovedEMG = [nanRemovedTrialData.emg];
% %     emgs = cat(3, nanRemovedEMG.EMG);
%     goodEMG = vertcat(nanRemovedEMG.goodEMGData);
%     kinematicsData = [nanRemovedTrialData.kinematics];
%     rewardArray = [kinematicsData.rewardLabel];
%     for muscle=(1:5)
% %         condition = all(goodEMG(:, muscle).');
%         selectedTrialData = nanRemovedTrialData(goodEMG(:, muscle).');
%         emgdata = [selectedTrialData.emg];
%         if ~isempty(emgdata)
%             emgs = cat(3, emgdata.EMG);
%             result = reshape(mean(emgs(50:250, muscle, :), 1), [size(emgs, 3),1]);
%             Y{muscle} = cat(1, Y{muscle}, result);
%             X{muscle} = cat(1, X{muscle}, nanRemovedRAxis(goodEMG(:, muscle).'));
%             for singleTrialData = selectedTrialData
%                 if singleTrialData.emg.goodEMGData(muscle) ~= 1
%                     error('incorrect label is included')
%                 end
%             end
%         end
%     end
%     startidx=startidx+length(rewardAxises);
% end
% rewColors = [1 0 0; 1 0.6470 0; 0 0 1; 0 0 0];
% for muscle=(1:5)
%     figure
% %     legendLabel = ["", "", "", ""];
% %     rewardLabel = ["S", "M", "L", "J"];
% %     for reward=(1:4)
% %         scatter(Y{reward, muscle}, X{reward, muscle}, 4, rewColors(reward, :), ...
% %             'filled', 'MarkerEdgeAlpha', .1, 'MarkerFaceAlpha',.1);
% %         hold on
% %         meanplot(reward) = scatter(mean(Y{reward, muscle}), mean(X{reward, muscle}), 75, rewColors(reward, :), ...
% %             'filled');
% %         hold on
% %         r=corrcoef(Y{reward, muscle}, X{reward, muscle});
% %         legendLabel(reward) = "r_" + rewardLabel(reward) + " = "+ num2str(round(r(1,2), 2));
% %     end
%     scatter(Y{muscle}, X{muscle}, 4, "k",'filled', 'MarkerEdgeAlpha', .1, 'MarkerFaceAlpha',.1);
%     hold on
%     meanplot = scatter(mean(Y{muscle}), mean(X{muscle}), 75, 'k', 'filled');
%     hold off
%     ylabel('Reward Axis');
%     xlabel('average EMG around GoCue');
%     title('Relationship Between RewardAxis and mean ' + wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle));
%     r=corrcoef(Y{:, muscle}, X{:, muscle});
%     legend(meanplot, "r = "+ num2str(round(r(1,2), 2)));
% %     saveas(gcf, "../result/images/202209w4/scatterPlot_RAxis_EMG-" + ...
% %         wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle) + ".fig");
% %     saveas(gcf, "../result/images/202209w4/scatterPlot_RAxis_EMG-" + ...
% %         wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle) + ".svg");
% %     close all
% end

%% choking paper figures: probability distribution of each muscle as a function of rewards
% load("../data/processed/singleTrials_Rocky2022to0303_0922.mat");
% 
% kinematicsData = [wholeTrialData.data.kinematics];
% EMGData = [wholeTrialData.data.emg];
% rewardArray = [kinematicsData.rewardLabel];
% goodEMGMatrix = vertcat(EMGData.goodEMGData);
% for muscle=(1:5)
%     Y = cell(4, 1);
%     for reward=(1:4)
%         condition = all([rewardArray==reward;goodEMGMatrix(:, muscle).']);
%         selectedTrialData = wholeTrialData.data(condition);
%         emgdata = [selectedTrialData.emg];
%         emgs = cat(3, emgdata.EMG); 
%         Y{reward} = mean(emgs(50:250, muscle, :), 1);
%         for singleTrialData = selectedTrialData
%             if singleTrialData.kinematics.rewardLabel ~= reward && ...
%                singleTrialData.emg.goodEMGData(muscle) ~= 1
%                 error('incorrect label is included')
%             end
%         end
%     end
%     figure
%     rawColors = [1 0 0; 1 0.6470 0; 0 0 1; 0 0 0];
%     edges = (-5.025:0.05:2.025);
%     x = (-5:0.05:2);
%     for i=(1:4)
%         N = histcounts(Y{i}, edges);
%         prob = N / length(Y{i});
%         plot(x, prob, 'Color', rawColors(i, :), LineWidth=2)
%         % set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
%         hold on
%     end
%     hold off
%     legend({'Small', 'Medium', 'Large', 'Jackpot'});
%     xlabel("emg")
%     gca.YAxis.Visible = 'off';
%     box('off');
%     title('Probability Distribution of ' + wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle) + ' at each reward')
% %     saveas(gcf, "../result/images/202209w4/probabilityDistributionOfEMGAtHT-" + ...
% %         wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle) + ".fig");
% %     saveas(gcf, "../result/images/202209w4/probabilityDistributionOfEMGAtHT-" + ...
% %         wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle) + ".svg");
% %     close all
% end

%% Choking paper figure: average trajectory of each direction and muscle as a function of rewards
% load("../data/processed/singleTrials_Rocky2022to0303_0922.mat");
% 
% kinematicsData = [wholeTrialData.data.kinematics];
% EMGData = [wholeTrialData.data.emg];
% directionArray = [kinematicsData.directionLabel];
% rewardArray = [kinematicsData.rewardLabel];
% goodEMGMatrix = vertcat(EMGData.goodEMGData);
% for direction=(4:4)
%     for muscle=(2:2)
%         Y = zeros(801, 4);
%         for reward=(1:4)
%             condition = all([directionArray==direction;rewardArray==reward;goodEMGMatrix(:, muscle).']);
%             selectedTrialData = wholeTrialData.data(condition);
%             emgdata = [selectedTrialData.emg];
%             emgs = cat(3, emgdata.EMG); 
%             Y(:, reward) = movmean(mean(emgs(:, muscle, :), 3), 100);
%             for singleTrialData = selectedTrialData
%                 if singleTrialData.kinematics.directionLabel ~= direction && ...
%                         singleTrialData.kinematics.rewardLabel ~= reward && ...
%                         singleTrialData.emg.goodEMGData(muscle) ~= 1
%                     error('incorrect label is included')
%                 end
%             end
%         end
%         plot((-200:600), Y, lineWidth=2);
%         rawColors = [1 0 0; 1 0.6470 0; 0 0 1; 0 0 0];
%         colororder(rawColors);
%         set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
%         xticks([-200, 0, 600]);
%         xticklabels({'-200', 'GC', '600'});
%         box('off');
%         title(['average ' + wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle) + ' of all ' + num2str((direction-1)*45) + ' degree trials'; ...
%             'as a function of rewards'])
%         saveas(gcf, "../result/images/202209w4/meanTrajectoryOfEachReward-" + ...
%             wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle) + "-" + num2str((direction-1)*45) + ".fig");
%         saveas(gcf, "../result/images/202209w4/meanTrajectoryOfEachReward-" + ...
%             wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle) + "-" + num2str((direction-1)*45) + ".svg");
%         close all
%     end
% end

%% EMG tuning curve at holding time as a function of reward and direction 
% load("../data/processed/singleTrials_Rocky2022to0303_0922.mat");
% 
% kinematicsData = [wholeTrialData.data.kinematics];
% EMGData = [wholeTrialData.data.emg];
% directionArray = [kinematicsData.directionLabel];
% rewardArray = [kinematicsData.rewardLabel];
% goodEMGMatrix = vertcat(EMGData.goodEMGData);
% for muscle=(1:5)
%     Y = zeros(8,4);
%     Yerror = zeros(8,4);
%     for direction=(1:8)
%         for reward=(1:4)
%             condition = all([directionArray==direction;rewardArray==reward;goodEMGMatrix(:, muscle).']);
%             selectedTrialData = wholeTrialData.data(condition);
%             emgdata = [selectedTrialData.emg];
%             emgs = cat(3, emgdata.EMG); 
%             meanEMGHT = mean(emgs(50:250, muscle, :), 1);
%             Y(direction, reward) =mean(meanEMGHT);
%             Yerror(direction, reward) =std(meanEMGHT)/sqrt(length(meanEMGHT));
%             for singleTrialData = selectedTrialData
%                 if singleTrialData.kinematics.directionLabel ~= direction && ...
%                         singleTrialData.kinematics.rewardLabel ~= reward && ...
%                         singleTrialData.emg.goodEMGData(muscle) ~= 1
%                     error('incorrect label is included')
%                 end
%             end
%         end
%     end
%     figure
%     errorbar(Y, Yerror,'linewidth',2);
%     legend(["Small", "Medium", "Large", "Jackpot"], Location="southwest")
%     rewColors = [1 0 0; 1 0.6470 0; 0 0 1; 0 0 0];
%     colororder(rewColors);
%     set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
%     xticks([1 2 3 4 5 6 7 8]);
%     xticklabels({'0', '45', '90', '135', '180', '225', '270', '325'});
%     xlim([0.5 8.5]);
%     title(wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle));
% end

%% visualize EKG pupil size
% load("../data/processed/singleTrials_Rocky2022to0303.mat");
% startidx = 1;
% for d=(1:length(wholeTrialData.sessionProp))
%     endidx = startidx + wholeTrialData.sessionProp(d).dataSizes-1;
%     trialData = wholeTrialData.data(startidx:endidx);
%     meanPupilSize = zeros(1, 0);
%     for i=(1:length(trialData))
%         if -6000 < mean(trialData(i).others(50:251, 4))
%             meanPupilSize(end+1) = mean(trialData(i).others(50:251, 4));
%         end
%     end
%     startidx = startidx + length(trialData);
% 
%     smoothPupilSize = movmean(meanPupilSize, 50);
%     
%     if d == 2 || d == 7
%         figure
%         plot(meanPupilSize, "Color", [0.5 0.5 0.5]);
%         title("Day" + num2str(d))
%     end
% end

%% important process: save analog data only file
% dates = ["0216", "0217", "0218", "0221", "0222", "0223", "0224", "0225", "0228", "0301", "0302", "0303"];
% 
% wholeTrialData.data = struct.empty(0);
% wholeTrialData.sessionProp = struct.empty(0);
% delayperiod = [];
% for d=(1:length(dates))
%     date = dates(d);
%     file = dir('../data/synchronized/*2022' +date+ '*.mat');
%     load("../data/synchronized/" + file.name);
%     load('../data/normalized/emg/singleTrials_Rocky2022' + date +'_1ms.mat');
%     load('../data/normalized/others/singleTrials_Rocky2022' + date +'.mat');
% 
%     for i=(1:length(normalizedTrialData))
%         
% 
%         if d == 1
%             normalizedTrialData(i).goodEMGData = EMGMetrics.muscleNames ~= "Trap";
%         elseif d == 6 || d == 7 || d == 8
%             normalizedTrialData(i).goodEMGData = EMGMetrics.muscleNames ~= "Tric";
%             if d == 7
%                 if i > 700 && i < 900
%                     normalizedTrialData(i).goodEMGData(2) = false;
%                 end
%             end
%         elseif d == 9
%             condition = any([EMGMetrics.muscleNames == "Tric"; EMGMetrics.muscleNames == "LBic"; EMGMetrics.muscleNames == "PDel"]);
%             normalizedTrialData(i).goodEMGData = ~condition;
%         elseif d == 11
%             if i > 150 && i < 300
%                 normalizedTrialData(i).goodEMGData(5) = false;
%             end
%         elseif d == 12
%             normalizedTrialData(i).goodEMGData = EMGMetrics.muscleNames ~= "Trap";
%         else
%             normalizedTrialData(i).goodEMGData = true(1, 5);
%         end
%     end
% 
%     [selectedTrialData,selectedArray] = selectStateTransition(trialData, []);
% 
%     normalizedEMGData = normalizedTrialData(selectedArray);
%     otherTrialData = otherTrialData(selectedArray);
% 
% 
%     wholeTrialData.sessionProp(d).EMGMetrics = EMGMetrics;
%     wholeTrialData.sessionProp(d).otherChannels = channelLabels;
%     wholeTrialData.sessionProp(d).dataSizes = length(selectedTrialData);
%     l = length(wholeTrialData.data);
%     timewindow = 801;
%     for s=(1:length(selectedTrialData))
%         stateTransition = selectedTrialData(s).stateTable;
% %         TargetOnsetTime = stateTransition(2, find(stateTransition(1, :)==3));
%         GoCueTime = stateTransition(2, find(stateTransition(1, :)==4));
%         % start: -200ms end: +600ms at GoCue
%         wholeTrialData.data(l+s).emg.EMG = normalizedEMGData(s).EMG(GoCueTime-200:GoCueTime+timewindow-201, :);
%         wholeTrialData.data(l+s).emg.goodEMGData = normalizedEMGData(s).goodEMGData;
%         % GoCueTime-200:GoCueTime+600をそれぞれTime関数から取得しindexに変換する
%         movementStartTime = find(selectedTrialData(s).time == GoCueTime);
%         selectedTrialData(s).handKinematics = selectedTrialData(s).handKinematics.velocity(movementStartTime-200:movementStartTime+timewindow-201, :);
%         
%         wholeTrialData.data(l+s).others = otherTrialData(s).others(GoCueTime-200:GoCueTime+timewindow-201, :);
%         
%         wholeTrialData.data(l+s).kinematics = selectedTrialData(s);
%     end
% end
% save("../data/processed/singleTrials_Rocky2022to0303_0922_all.mat", "wholeTrialData")

%% show normalized EMG each day
% load("../data/processed/singleTrials_Rocky2022to0303_0922.mat");
% 
% startidx=1;
% 
% for day=(1:length(wholeTrialData.sessionProp))
%     endidx = wholeTrialData.sessionProp(day).dataSizes;
%     trialDataByDay = wholeTrialData.data(startidx:startidx+endidx-1);
%     for muscle=(1:5)
%         emgData = [trialDataByDay.emg];
%         emgSignal = cat(3, emgData.EMG); % 801 * 5 * ntrial
%         meanEMGAcrossSession = mean(emgSignal(:, muscle, :), 1);
%         Y = reshape(meanEMGAcrossSession, length(meanEMGAcrossSession), 1);
%         figure
%         plot(Y);
%         set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
%         saveas(gcf, "../result/images/202209w3/NormalizedEMGAcrossSession/" + ...
%             wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle) + "-Day" + num2str(day)+".jpg");
%         close all
%     end
%     startidx=startidx+endidx;
% end


%% show normalized Params each day and muscle
% load("../data/processed/singleTrials_Rocky2022to0303_0922.mat");
% dates = ["0216", "0217", "0218", "0221", "0222", "0223", "0224", "0225", "0228", "0301", "0302", "0303"];
% 
% NormalizedProp = [wholeTrialData.sessionProp.EMGMetrics];
% tuningCurveData = cat(3, NormalizedProp.maxSignalTuningCurve_mean);
% for muscle=(1:5) 
%     figure
%     rawY = reshape(tuningCurveData(:, muscle, :), 9, []);
%     Y = zeros(size(rawY));
%     for day=(1:size(rawY,2))
%         param = NormalizedProp(day).normalizedParams(:, muscle);
%         Y(:, day) = (rawY(:, day) - param(1)) / param(2);
%     end
% 
%     plot(Y,'linewidth',2);
%     legend(["Small", "Medium", "Large", "Jackpot"], Location="southwest")
%     rewColors = [0 0 0;0 0 .66;0 0 .33;0 0 1;0 .66 0;0 .33 0;0 1 0;.66 0 0;.33 0 0;1 0 0;0 1 0.66;0 0.66 1];
%     colororder(rewColors);
%     set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
%     xticks([1 2 3 4 5 6 7 8 9]);
%     xticklabels({'0', '45', '90', '135', '180', '225', '270', '325', 'hold'});
%     xlim([0.5 9.5]);
%     title(wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle));
%     legend(dates)
%     saveas(gcf, "../result/images/202209w3/TuningCurveNormalization/" + ...
%         wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle) + ".jpg");
%     close all
% end


%% get maxVelosity data
% movement = exceptionRemovedEMG.data.kinematics.integratedVelosities; % timewindow * N
% [maxVelosityMagnitudes, maxVelosityIndexs] = max(movement, [], 1); % should be 1*N
% normals = zeros(1,size(movement, 2), 'logical');
% for i=(1:length(maxVelosityIndexs))
%     if maxVelosityIndexs(i) > 300+200
%         normals(i) = 1;
%     end
% end

%% mean peak velocity of EMG as a function of reward
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

%% add goodEMG data 
% dates = ["0216", "0217", "0218", "0221", "0222", "0223", "0224", "0225", "0228", "0301", "0302", "0303"];
% for d=(1:length(dates))
%     date = dates(d);
%     load('../data/normalized/emg/singleTrials_Rocky2022' + date + '_1ms.mat');
%     
% 
%     for i=(1:length(normalizedTrialData))
%         if d == 1
%             normalizedTrialData(i).goodEMGData = EMGMetrics.muscleNames ~= "Trap";
%         elseif d == 6 || d == 7 || d == 8
%             normalizedTrialData(i).goodEMGData = EMGMetrics.muscleNames ~= "Tric";
%         elseif d == 9
%             condition = any([EMGMetrics.muscleNames == "Tric"; EMGMetrics.muscleNames == "LBic"; EMGMetrics.muscleNames == "PDel"]);
%             normalizedTrialData(i).goodEMGData = ~condition;
%         elseif d == 12
%             normalizedTrialData(i).goodEMGData = EMGMetrics.muscleNames ~= "Trap";
%         else
%             normalizedTrialData(i).goodEMGData = true(1, 5);
%         end
%     end
% 
%     save('../data/normalized/emg/singleTrials_Rocky2022' + date + '_1ms.mat', 'normalizedTrialData', 'EMGMetrics');
% end

%% check normalization method
% dates = ["0216", "0217", "0218", "0221", "0222", "0223", "0224", "0225", "0228", "0301", "0302", "0303"];
% figure
% for d=(1:length(dates))
%     date = dates(d);
%     load('../data/normalized/singleTrials_Rocky2022' + date + '_1ms.mat');
%     Y = (EMGMetrics.maxSignalTuningCurve_mean - EMGMetrics.normalizedParams(1,:)) ./ EMGMetrics.normalizedParams(2,:);
%     if d == 1
%         Y(:, EMGMetrics.muscleNames == "Trap") = 0;
%     elseif d == 6 || d == 7 || d == 8
%         Y(:, EMGMetrics.muscleNames == "Tric") = 0;
%     elseif d == 9
%         condition = any([EMGMetrics.muscleNames == "Tric"; EMGMetrics.muscleNames == "LBic"; EMGMetrics.muscleNames == "PDel"]);
%         Y(:, condition) = 0;
%     elseif d == 12
%         Y(:, EMGMetrics.muscleNames == "Trap") = 0;
%     end
%     plot(Y)
%     rewColors = [1 0 0; 1 0.6470 0; 0 0.6470 0; 0 0 1; 0 0 0];
%     colororder(rewColors);
%     hold on
% end
% set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
% hold off

%% EMG fatigue across the session
% parameters = struct.empty(5, 0);
% for channel=(1:5)
%     data = exceptionRemovedEMG.data;
%     emg = exceptionRemovedEMG.data.emgs(channel);
%     acrossday = zeros(size(emg.exceptions));
%     startTrial = 1;
%     parameters(channel).diff = [];
%     for day = (1:length(exceptionRemovedEMG.preprocessProp.IndexEachDay))
%         fetchedEMG = mean(emg.signals(50:250, startTrial:exceptionRemovedEMG.preprocessProp.IndexEachDay(day)), 1); %-150~+50ms
%         exception = emg.exceptions(startTrial:exceptionRemovedEMG.preprocessProp.IndexEachDay(day));
%         fetchedEMG = fetchedEMG(cast(exception, "logical"));
%         startTrial = exceptionRemovedEMG.preprocessProp.IndexEachDay(day)+1;
% %         fprintf("emg size: %d \n", length(fetchedEMG));
%         if length(fetchedEMG) > 2
%             movcar = round(length(fetchedEMG)*0.1);
%             Y = fetchedEMG;
% %             covariance = cov(Y, X);
% %             alpha = covariance(1,2) / var(X);
% %             beta = mean(Y) - alpha * mean(X);
%             parameters(channel).diff(end+1) = mean(fetchedEMG(end-movcar:end)) - mean(fetchedEMG(1:movcar));
% %             figure
% %             plot(X,Y, 'color', [.5 .5 .5])
% %             hold on
% %             plot(X, (alpha*X+beta), "k", "LineWidth", 2);
% %             title([emg.name + ": Day" + num2str(day)]);
% %             hold off
%         end
%     end
% end
% xlabels = string.empty(0);
% for channel=(1:5)
%     scatter(channel * ones(size(parameters(channel).diff)), parameters(channel).diff, '*', "b");
%     hold on
%     xlabels(end+1) = exceptionRemovedEMG.data.emgs(channel).name;
%     scatter(channel, mean(parameters(channel).diff), '*', "r");
%     [h,p] = ttest(parameters(channel).diff);
%     disp(p)
% end
% set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out', "LineWidth", 2);
% ylabel("last 10% EMG - first 10% EMG")
% xlim([0.5 5.5])
% xticklabels(xlabels)
% yline(0)
% hold off

%% EMG variablity as a function of reward
% Y = struct.empty(0);
% for i=(1:4)
%     Y(i).emg = double.empty(0);
% end
% for channel=(5:5)
%     data = exceptionRemovedEMG.data;
%     emg = exceptionRemovedEMG.data.emgs(channel);
%     for direction=(1:8)
%         condition = all([data.directions==direction; emg.exceptions]);
%         rewardArray = data.rewards(condition);
%         fetchedEMG = mean(emg.signals(50:250, condition), 1); %-150~+50ms
%         zScoredEMG = zscore(fetchedEMG);
%         for reward=(1:4)
%             Y(reward).emg = cat(1, Y(reward).emg, zScoredEMG(rewardArray==reward).');
%         end
%     end
% end
% figure
% rewColors = [1 0 0; 1 0.6470 0; 0 0 1; 0 0 0];
% edges = (-3.05:0.1:3.05);
% x = (-3:0.1:3);
% for i=(1:size(Y, 2))
%     N = histcounts(Y(i).emg, edges);
%     prob = N / size(Y(i).emg, 1);
%     plot(x, prob, 'Color', rewColors(i, :), LineWidth=2)
%     % set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
%     hold on
% end
% hold off
% legend({'Small', 'Medium', 'Large', 'Jackpot'});
% xlabel("z-indexed emg")
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
%     plot((-200:600), Y, "LineWidth", 2)
%     set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out', "LineWidth", 2);
%     legend(["right", "upper right", "upper", "upper left", "left", "lower left", "lower", "lower right"], ...
%             "Location", "northwest")
%     title(emg.name);
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

%% EMG as a function of reward hypothesis
% x = (1:8)
% Yhypo = sin(x / 4 * pi)
% Yhypos = ones(4, 8) .* Yhypo
% Yhypos = Yhypos ./ 10
% Yhypos = Yhypos + [-.95; -.9; -.85; -.8]
% plot(Yhypos.','linewidth',2);
% title('ADel');
% legend(["Small", "Medium", "Large", "Jackpot"])
% rewColors = [1 0 0; 1 0.6470 0; 0 0 1; 0 0 0];
% colororder(rewColors);
% set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out','linewidth',2);
% xticks([1 2 3 4 5 6 7 8]);
% xticklabels({'0', '45', '90', '135', '180', '225', '270', '325'});
% xlim([0.5 8.5]);

%% EMG tuning curve at holding time as a function of reward and direction 
% load("../data/processed/singleTrials_Rocky2022to0303_0922.mat");
% 
% kinematicsData = [wholeTrialData.data.kinematics];
% EMGData = [wholeTrialData.data.emg];
% directionArray = [kinematicsData.directionLabel];
% rewardArray = [kinematicsData.rewardLabel];
% goodEMGMatrix = vertcat(EMGData.goodEMGData);
% for muscle=(1:5)
%     Y = zeros(8,4);
%     Yerror = zeros(8,4);
%     for direction=(1:8)
%         for reward=(1:4)
%             condition = all([directionArray==direction;rewardArray==reward;goodEMGMatrix(:, muscle).']);
%             selectedTrialData = wholeTrialData.data(condition);
%             emgdata = [selectedTrialData.emg];
%             emgs = cat(3, emgdata.EMG); 
%             meanEMGHT = mean(emgs(50:250, muscle, :), 1);
%             Y(direction, reward) =mean(meanEMGHT);
%             Yerror(direction, reward) =std(meanEMGHT)/sqrt(length(meanEMGHT));
%             for singleTrialData = selectedTrialData
%                 if singleTrialData.kinematics.directionLabel ~= direction && ...
%                         singleTrialData.kinematics.rewardLabel ~= reward && ...
%                         singleTrialData.emg.goodEMGData(muscle) ~= 1
%                     error('incorrect label is included')
%                 end
%             end
%         end
%     end
%     figure
%     errorbar(Y, Yerror,'linewidth',2);
%     legend(["Small", "Medium", "Large", "Jackpot"], Location="southwest")
%     rewColors = [1 0 0; 1 0.6470 0; 0 0 1; 0 0 0];
%     colororder(rewColors);
%     set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
%     xticks([1 2 3 4 5 6 7 8]);
%     xticklabels({'0', '45', '90', '135', '180', '225', '270', '325'});
%     xlim([0.5 8.5]);
%     title(wholeTrialData.sessionProp(1).EMGMetrics.muscleNames(muscle));
% end

% 
% for channel=(5:5)
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
%     legend(["Small", "Medium", "Large", "Jackpot"], Location="southwest")
%     rewColors = [1 0 0; 1 0.6470 0; 0 0 1; 0 0 0];
%     colororder(rewColors);
%     set(gca, 'fontsize', 14, 'fontname', 'arial', 'tickdir', 'out');
%     xticks([1 2 3 4 5 6 7 8]);
%     xticklabels({'0', '45', '90', '135', '180', '225', '270', '325'});
%     xlim([0.5 8.5]);
% end
