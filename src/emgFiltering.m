function preprocessedEMGs = emgFiltering(signalData,fs, movmeanWindow, muscleLabel)

%% Abstruct
% This function preprocess the EMG data including removing noise, smoothing
% the data and downsampling data.
% the pipeline is below.
% 1 notchfilter: remove baseline noise
% 2 Downsampling to 1 KHz
% 3 ECG removal by adaptive filter
% 4 bandpass filter: remove unrelated signal
% 5 Rectifying & smoothing
%
%
%% data structure
% Input
%   - EMGs: [ntimes * nmuscles]
%   - fs: 
EMGs = signalData.data(:, 1:5);
ECG = signalData.data(:, 8);
preprocessedEMGs = zeros(ceil(size(EMGs, 1)/10), 5); % Step 1 prepare (downsampled length, 5) double array
new_fs = 1000;

denoisedECG = ecgPreprocessing(ECG,fs);
% muscleLabel = ["ADel", "LBic", "PDel", "Trap", "Tric"];
for i=(1:length(muscleLabel))
    idx = find(muscleLabel==signalData.EMGMuscleNames(i)); % preventing muscle label misalignment

    baselineRemovedEMG = double(EMGs(:, i));
    for s=(1:8)
        d = designfilt('bandstopiir', 'filterOrder', 2, ...
                        'HalfPowerFrequency1', 60*s-1, 'HalfPowerFrequency2', 60*s+1, ...
                        'DesignMethod', 'butter', 'SampleRate', fs);
        baselineRemovedEMG = filtfilt(d, baselineRemovedEMG);
    end
    baselineRemovedEMG = downsample(baselineRemovedEMG,round(fs/1000));
    [ ECGremovedEMG, ~] = ecgRemovalFilter(baselineRemovedEMG, denoisedECG, baselineRemovedEMG(1:100*new_fs), denoisedECG(1:100*new_fs),new_fs);
    bandpassedEMG = bandpass(ECGremovedEMG, [20, 450], new_fs);
    rectifiedEMG = abs(bandpassedEMG);
    smoothedEMG = movmean(rectifiedEMG, round(movmeanWindow*new_fs)); %RMS: sqrt(movmean(rectifiedEMG.^2, 500))
    preprocessedEMGs(:, idx) = smoothedEMG; % Step 2 smoothed and put into the array
end