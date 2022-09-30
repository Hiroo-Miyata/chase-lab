%% important process: save analog data only file
dates = ["0216", "0217", "0218", "0221", "0222", "0223", "0224", "0225", "0228", "0301", "0302", "0303"];

wholeTrialData.data = struct.empty(0);
wholeTrialData.sessionProp = struct.empty(0);
delayperiod = [];
for d=(1:length(dates))
    date = dates(d);
    file = dir('../data/synchronized/*2022' +date+ '*.mat');
    load("../data/synchronized/" + file.name);
    load('../data/normalized/emg/singleTrials_Rocky2022' + date +'_1ms.mat');
    load('../data/normalized/others/singleTrials_Rocky2022' + date +'.mat');

    for i=(1:length(normalizedTrialData))
        

        if d == 1
            normalizedTrialData(i).goodEMGData = EMGMetrics.muscleNames ~= "Trap";
        elseif d == 6 || d == 7 || d == 8
            normalizedTrialData(i).goodEMGData = EMGMetrics.muscleNames ~= "Tric";
            if d == 7
                if i > 700 && i < 900
                    normalizedTrialData(i).goodEMGData(2) = false;
                end
            end
        elseif d == 9
            condition = any([EMGMetrics.muscleNames == "Tric"; EMGMetrics.muscleNames == "LBic"; EMGMetrics.muscleNames == "PDel"]);
            normalizedTrialData(i).goodEMGData = ~condition;
        elseif d == 11
            if i > 150 && i < 300
                normalizedTrialData(i).goodEMGData(5) = false;
            end
        elseif d == 12
            normalizedTrialData(i).goodEMGData = EMGMetrics.muscleNames ~= "Trap";
        else
            normalizedTrialData(i).goodEMGData = true(1, 5);
        end
    end

    [selectedTrialData,selectedArray] = selectStateTransition(trialData, []);

    normalizedEMGData = normalizedTrialData(selectedArray);
    otherTrialData = otherTrialData(selectedArray);


    wholeTrialData.sessionProp(d).EMGMetrics = EMGMetrics;
    wholeTrialData.sessionProp(d).otherChannels = channelLabels;
    wholeTrialData.sessionProp(d).dataSizes = length(selectedTrialData);
    l = length(wholeTrialData.data);
    timewindow = 801;
    for s=(1:length(selectedTrialData))
        stateTransition = selectedTrialData(s).stateTable;
%         TargetOnsetTime = stateTransition(2, find(stateTransition(1, :)==3));
        GoCueTime = stateTransition(2, find(stateTransition(1, :)==4));
        % start: -200ms end: +600ms at GoCue
        wholeTrialData.data(l+s).emg.EMG = normalizedEMGData(s).EMG(GoCueTime-200:GoCueTime+timewindow-201, :);
        wholeTrialData.data(l+s).emg.goodEMGData = normalizedEMGData(s).goodEMGData;
        % GoCueTime-200:GoCueTime+600をそれぞれTime関数から取得しindexに変換する
        movementStartTime = find(selectedTrialData(s).time == GoCueTime);
        selectedTrialData(s).handKinematics = selectedTrialData(s).handKinematics.velocity(movementStartTime-200:movementStartTime+timewindow-201, :);
        
        wholeTrialData.data(l+s).others = otherTrialData(s).others(GoCueTime-200:GoCueTime+timewindow-201, :);
        
        wholeTrialData.data(l+s).kinematics = selectedTrialData(s);
    end
end
save("../data/processed/singleTrials_Rocky2022to0303_0922_all.mat", "wholeTrialData")
