alldata = load("../data/synchronized/Rocky20220303_Trials9_1260_behaviorProcessed_20220815_103412.mat");
signalData = alldata.analogData;
fs = 10000;
new_fs = 1000;
zerotime = alldata.analogData.time(1); %second 

%
% measure heart rate from EKG(ECG) signal
% 
ECG = signalData.data(:, 8);
denoisedECG = double(ECG);
for s=(1:8) % notch filtering
    d = designfilt('bandstopiir', 'filterOrder', 2, ...
                    'HalfPowerFrequency1', 60*s-1, 'HalfPowerFrequency2', 60*s+1, ...
                    'DesignMethod', 'butter', 'SampleRate', fs);
    denoisedECG = filtfilt(d, denoisedECG);
end
denoisedECG = downsample(denoisedECG, 10);

% separate signal by trial
% Step 1 prepare (downsampled length, 5) double array
% Step 2 smoothed and put into the array
% Step 3 separate by trial from synchInfo
% Step 4 load Property from Hand data (reward, direction, success/failure, Handmovement)

preprocessedEMGs = double.empty(ceil(length(signalData.time)/10), 0); % Step 1 prepare (downsampled length, 5) double array

% denoise EMG signal
% 1 notchfilter: remove baseline noise
% 2 bandpass filter: remove unrelated signal
% 3 Remove ECG from EMG
% 4 Rectifying & smoothing
% 5 Down sampling to 1 KHz

EMGs = signalData.data(:, 1:5);
for i=(1:5)
    baselineRemovedEMG = double(EMGs(:, i));
    for s=(1:8)
        d = designfilt('bandstopiir', 'filterOrder', 2, ...
                        'HalfPowerFrequency1', 60*s-1, 'HalfPowerFrequency2', 60*s+1, ...
                        'DesignMethod', 'butter', 'SampleRate', fs);
        baselineRemovedEMG = filtfilt(d, baselineRemovedEMG);
    end
    baselineRemovedEMG = downsample(baselineRemovedEMG,10);
    [ ECGremovedEMG, ec] = adaptiveFilter(baselineRemovedEMG, denoisedECG, baselineRemovedEMG(1:100*new_fs), denoisedECG(1:100*new_fs),new_fs);
    bandpassedEMG = bandpass(ECGremovedEMG, [20, 450], new_fs);
    rectifiedEMG = abs(bandpassedEMG);
    smoothedEMG = movmean(rectifiedEMG, round(0.05*new_fs)); %RMS: sqrt(movmean(rectifiedEMG.^2, 500))
    preprocessedEMGs(:, i) = smoothedEMG; % Step 2 smoothed and put into the array
end
% for plot: plot(signalData.time, double(EMGs(:, i)), downsample(signalData.time,10), downsampledEMG, downsample(signalData.time,10), smoothedEMG)
%legend('rawdata', 'denoised data', 'smoothed data')
% for fft plot [y,x] = periodogram(double(EMG(:,i)), [], [], fs);
% pwelch(curEMG,30*fs,[],[],fs); axis([0 1 -inf inf]); title('Welchs, 30s window')


% Step 3 separate by trial from synchInfo
% Step 4 load Property from Hand data (reward, direction, success/failure, Handmovement)
movementData = alldata;
singleTrialData = struct.empty(0);
for t=(1:length(alldata.trialData)-1)
    trialData = alldata.trialData(t);
    startTime = ceil((trialData.taskSynchTrialTime-zerotime)*1000);
    endTime = ceil((alldata.trialData(t+1).taskSynchTrialTime-zerotime)*1000);
    singleTrialData(t).emg = preprocessedEMGs(startTime:endTime, :);
    singleTrialData(t).prop.result = trialData.trialStatus;
    singleTrialData(t).prop.direction = trialData.directionLabel;
    singleTrialData(t).prop.reward = trialData.rewardLabel;
    singleTrialData(t).prop.startTarget = trialData.centerTarget;
    singleTrialData(t).prop.endTarget = trialData.reachTarget;
    singleTrialData(t).prop.stateTransition = trialData.stateTable;
    singleTrialData(t).handKinematics = trialData.handKinematics;
end

muscleLabel = signalData.EMGMuscleNames;
emg_rest = preprocessedEMGs(1:120*new_fs, :);
save('../data/processed/singleTrials_Rocky20220303_movave_50ms.mat', 'singleTrialData', 'muscleLabel', "emg_rest");
clear;
