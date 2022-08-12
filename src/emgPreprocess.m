alldata = load("../data/synchronized/Rocky_synchedSpikeAndAnalogData_20220223.mat");
signalData = alldata.analogData;
fs = 10000;
new_fs = 1000;

%
% measure heart rate from EKG(ECG) signal
% 
ECG = signalData.data(:, 8);

% notch filtering
denoisedECG = double(ECG);
for s=(1:8)
    d = designfilt('bandstopiir', 'filterOrder', 2, ...
                    'HalfPowerFrequency1', 60*s-1, 'HalfPowerFrequency2', 60*s+1, ...
                    'DesignMethod', 'butter', 'SampleRate', fs);
    denoisedECG = filtfilt(d, denoisedECG);
end

denoisedECG = downsample(denoisedECG, 10);

% heart rate = how many value > RMS*3 per minutes
% rmsECG = rms(denoisedECG) .* 3;
% aboveThresh = denoisedECG > rmsECG;
% d = diff(aboveThresh); % Find rising edges
% numPeaks = sum(abs(d))./2; % Count rising edges.
% fprintf("diff heartrate; %s \n", numPeaks ./ numel(signalData.time) .* 60 .* fs)


% separate signal by trial
% Step 1 prepare (downsampled length, 5) double array
% Step 2 smoothed and put into the array
% Step 3 separate by trial from synchInfo
% Step 4 load Property from Hand data (reward, direction, success/failure, Handmovement)

preprocessedEMGs = double.empty(ceil(length(signalData.time)/10), 0); % Step 1 prepare (downsampled length, 5) double array

% denoise EMG signal
% 1 notchfilter: remove baseline noise
% 2 bandpass filter: remove unrelated signal
% 3 Remove ECG from EMG ...?
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
    [ ECGremovedEMG, ec] = adaptiveFilter(baselineRemovedEMG, denoisedECG, baselineRemovedEMG(1:100*new_fs), ecgrest(1:100*new_fs),new_fs);
    bandpassedEMG = bandpass(ECGremovedEMG, [20, 450], new_fs);
    rectifiedEMG = abs(bandpassedEMG);
    smoothedEMG = movmean(rectifiedEMG, round(0.1*new_fs)); %RMS: sqrt(movmean(rectifiedEMG.^2, 500))
    preprocessedEMGs(:, i) = smoothedEMG; % Step 2 smoothed and put into the array
end
% for plot: plot(signalData.time, double(EMGs(:, i)), downsample(signalData.time,10), downsampledEMG, downsample(signalData.time,10), smoothedEMG)
%legend('rawdata', 'denoised data', 'smoothed data')
% for fft plot [y,x] = periodogram(double(EMG(:,i)), [], [], fs);
% pwelch(curEMG,30*fs,[],[],fs); axis([0 1 -inf inf]); title('Welchs, 30s window')


% Step 3 separate by trial from synchInfo
% Step 4 load Property from Hand data (reward, direction, success/failure, Handmovement)
trialStartTimes = alldata.synchInfo.taskSynchTrialTimes;
movementData = load('../data/raw/Rocky_20220223_dataForHiroo.mat');
singleTrialData = struct.empty(0);
for t=(1:length(trialStartTimes)-1)
    singleTrialData(t).emg = preprocessedEMGs(ceil(trialStartTimes(t)*1000):ceil(trialStartTimes(t+1)*1000), :);
    singleTrialData(t).prop.result = movementData.data(t).Overview.trialStatus;
    singleTrialData(t).prop.direction = movementData.data(t).TrialData.directionLabel;
    singleTrialData(t).prop.reward = movementData.data(t).TrialData.rewardLabel;
    singleTrialData(t).prop.startTarget = movementData.data(t).TrialData.startTarget;
    singleTrialData(t).prop.endTarget = movementData.data(t).TrialData.endTarget;
    singleTrialData(t).prop.stateTransition = movementData.data(t).TrialData.stateTransitions;
    singleTrialData(t).handKinematics = movementData.data(t).TrialData.handKinematics;
end

muscleLabel = signalData.EMGMuscleNames;
save('../data/processed/singleTrials_20220223_movave_100ms.mat', 'singleTrialData', 'muscleLabel');
