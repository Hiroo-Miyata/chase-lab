function out = heartrate(denoisedECG, datapoint, fs)

% heart rate = how many value > RMS*3 per minutes
rmsECG = rms(denoisedECG) .* 3;
aboveThresh = denoisedECG > rmsECG;
d = diff(aboveThresh); % Find rising edges
numPeaks = sum(abs(d))./2; % Count rising edges.
out = numPeaks ./ numel(datapoint) .* 60 .* fs;