% This function preprocesses the EMG data, including filtering,
% rectification, and downsampling. Then, we get the segment applied to each
% trial in trialData and store it accordingly.
%
% Inputs:
% - analogData: structure with 4 fields:
%   - channelLabels: names for each of the analog channels. For this, we
%   use 'EMG_1' through 'EMG_8'
%   - fs: scalar, sampling frequency of the data
%   - time: [ntime x 1] vector with the time (relative to task CPU) of the
%   analog data
%   - data: [ntime x nchannels] analog data
% - synchInfo: structure with many fields of synch information, but
% for this, all we use is the "taskSynchTrialTimes", which indicates when
% state 1 (center target appearance) first occurred for each trial ([ntrials
% x 1])
% - trialData: [ntrials x 1] structure with the trial parameter data and
% kinematics
%
% Outputs:
% - trialData: same as input, but now has 2 more fields:
%   - EMGData: structure with 2 fields:
%       - EMG: [ntime x nmuscles] matrix with EMG values
%       - muscleNames: [nmuscles x 1] cell array with the corresponding 
%       muscle names for each
%   - goodEMGData: [nmuscles x 1] boolean array indicating if the trial's 
%   data for each muscle is good/does not have artifacts or issues
% - EMGMetrics: a structure indicating signal quality for each muscle
%   - baseline = [nmuscles x 1]
%   - maxSignalTuningCurve_mean = [nmuscles x ndirections+1]
%   - maxSignalTuningCurve_std = [nmuscles x ndirections+1]
%   - maxSNR = [nmuscles x 1] (peak avg activity)/(baseline)

alldata = load("../data/synchronized/Rocky20220222_Trials10_667_behaviorProcessed_20220815_102247.mat");
signalData = alldata.analogData;
muscleLabel = ["ADel", "LBic", "PDel", "Trap", "Tric"];
fs = 10000;
new_fs = 1000;
zerotime = alldata.analogData.time(1); %second 

% separate signal by trial
% Step 1 prepare (downsampled length, 5) double array
% Step 2 smoothed and put into the array
% Step 3 separate by trial from synchInfo
% Step 4 load Property from Hand data (reward, direction, success/failure, Handmovement)
preprocessedEMGs = emgFiltering(signalData,fs, 0.05, muscleLabel);

% for plot: plot(signalData.time, double(EMGs(:, i)), downsample(signalData.time,10), downsampledEMG, downsample(signalData.time,10), smoothedEMG)
%legend('rawdata', 'denoised data', 'smoothed data')
% for fft plot [y,x] = periodogram(double(EMG(:,i)), [], [], fs);
% pwelch(curEMG,30*fs,[],[],fs); axis([0 1 -inf inf]); title('Welchs, 30s window')

% Step 3 separate by trial from synchInfo
% Step 4 load Property from Hand data (reward, direction, success/failure, Handmovement)
preprocessedTrialData = struct.empty(0);

for t=(1:length(alldata.trialData)-1)
    trialData = alldata.trialData(t);
    startTime = ceil((trialData.taskSynchTrialTime-zerotime)*1000);
    endTime = ceil((trialData.taskSynchTrialTime-zerotime)*1000 + max(trialData.time));
    preprocessedTrialData(t).emg = preprocessedEMGs(startTime:endTime, :);
    preprocessedTrialData(t).prop.result = trialData.trialStatus;
    preprocessedTrialData(t).prop.direction = trialData.directionLabel;
    preprocessedTrialData(t).prop.reward = trialData.rewardLabel;
    preprocessedTrialData(t).prop.startTarget = trialData.centerTarget;
    preprocessedTrialData(t).prop.endTarget = trialData.reachTarget;
    preprocessedTrialData(t).prop.stateTransition = trialData.stateTable;
    preprocessedTrialData(t).handKinematics = trialData.handKinematics;
    preprocessedTrialData(t).timeInTrial = trialData.time;
end

emgRest = preprocessedEMGs(1:120*new_fs, :);
% save('../data/processed/singleTrials_Rocky20220216_movave_50ms.mat', 'preprocessedTrialData', 'muscleLabel', "emg_rest");
[normalizedTrialData, EMGMetrics] = emgNormalization(preprocessedTrialData, emgRest, muscleLabel);
save('../data/normalized/singleTrials_Rocky20220222_50ms.mat', 'normalizedTrialData', 'EMGMetrics');
