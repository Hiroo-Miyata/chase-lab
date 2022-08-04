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

%
% denoise EMG signal
% Step 1 notchfilter: remove baseline noise
% Step 2 bandpass filter: remove unrelated signal
% Step 3 Remove ECG from EMG ...?
% Step 4 Down sampling
% Step 5 Rectifying
%

EMGs = signalData.data(:, 1:5);
i = 1;
baselineRemovedEMG = double(EMGs(:, i));
for s=(1:8)
    d = designfilt('bandstopiir', 'filterOrder', 2, ...
                    'HalfPowerFrequency1', 60*s-1, 'HalfPowerFrequency2', 60*s+1, ...
                    'DesignMethod', 'butter', 'SampleRate', fs);
    baselineRemovedEMG = filtfilt(d, baselineRemovedEMG);
end
bandpassedEMG = bandpass(baselineRemovedEMG, [40, 450], fs);
rectifiedEMG = abs(bandpassedEMG);
smoothedEMG = sqrt(movmean(rectifiedEMG.^2, 100));
downsampledEMG = downsample(smoothedEMG,10);
%plot(signalData.time, double(EMGs(:, i)), downsample(signalData.time,10), downsampledEMG, downsample(signalData.time,10), smoothedEMG)
%legend('rawdata', 'denoised data', 'smoothed data')