alldata = load("../data/synchronized/Rocky_synchedSpikeAndAnalogData_20220223.mat");
signalData = alldata.analogData;
fs = 10000;

%
% measure heart rate from EKG(ECG) signal
% 
ECG = signalData.data(:, 8);

% notch filtering
notchfilter = designfilt('bandstopiir', 'filterOrder', 2, ...
                        'HalfPowerFrequency1', 59, 'HalfPowerFrequency2', 61, ...
                        'DesignMethod', 'butter', 'SampleRate', fs);
denoisedECG = filtfilt(notchfilter, double(ECG));

% heart rate = how many value > RMS*3 per minutes
rmsECG = rms(denoisedECG) .* 3;
aboveThresh = denoisedECG > rmsECG;
d = diff(aboveThresh); % Find rising edges
numPeaks = sum(abs(d))./2; % Count rising edges.
fprintf("diff heartrate; %s \n", numPeaks ./ numel(signalData.time) .* 60 .* fs)


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
    bandpassedEMG = bandpass(baselineRemovedEMG, [10, 450], fs);
    rectifiedEMG = abs(bandpassedEMG);
    smoothedEMG = sqrt(movmean(rectifiedEMG.^2, 100));
    downsampledEMG = downsample(smoothedEMG,10);
    preprocessedEMGs(:, i) = downsampledEMG; % Step 2 smoothed and put into the array
end
% for plot: plot(signalData.time, double(EMGs(:, i)), downsample(signalData.time,10), downsampledEMG, downsample(signalData.time,10), smoothedEMG)
%legend('rawdata', 'denoised data', 'smoothed data')
% for fft plot [y,x] = periodogram(double(EMG(:,i)), [], [], fs);


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
    singleTrialData(t).handKinematics = movementData.data(t).TrialData.handKinematics;
end