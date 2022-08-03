alldata = load("../data/synchronized/Rocky_synchedSpikeAndAnalogData_20220223.mat");
signalData = alldata.analogData;

% measure heart rate from EKG(ECG) signal
fs = 10000;
ECG = signalData.data(:, 8);


% heart rate = how many value > RMS per minutes

% notch filtering

rmsECG = rms(ECG) .* 4;
count = 0;
status = 0;

for i = 1:size(ECG)
    %fprintf('%s > %s', ECG1(i), rmsECG1);
    if ECG(i) > rmsECG && status == 0
        count = count + 1;
        status = 1;
    elseif ECG(i) < rmsECG && status == 1
        status = 0;
    end
end

fprintf("heartrate: %s \n", count ./ numel(signaldata.time) .* 60 .* fs);