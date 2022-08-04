alldata = load("../data/synchronized/Rocky_synchedSpikeAndAnalogData_20220223.mat");
signalData = alldata.analogData;
fs = 10000;

%
% measure heart rate from EKG(ECG) signal
% 
ECG = signalData.data(:, 8);

% for fft plot [y,x] = periodogram(double(ECG), [], [], fs);

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

3
%
% denoise EMG signal
% Step 1 notchfilter: remove baseline noise
% Step 2 bandpass filter: remove unrelated signal
% Step 3 Remove ECG from EMG ...?
% Step 4 Down sampling
% Step 4 Rectifying
%

EMGs = signalData.data(:, 1:5);
i = 1;
baselineRemovedEMG = filtfilt(notchfilter, double(EMGs(:, i)));
bandpassedEMG = bandpass(baselineRemovedEMG, [40, 450], fs);
downsampledEMG = downsample(bandpassedEMG,10);
rectifiedEMG = abs(downsampledEMG);
smoothedEMG = sqrt(movmean(rectifiedEMG.^2, 50));
plot(downsample(signalData.time,10), rectifiedEMG, downsample(signalData.time,10), smoothedEMG)