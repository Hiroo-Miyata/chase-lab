
%% success rate plotting
% 1. delay failure vs success
% 2. overshoot / undershoot / success: []
% 3. holding failure / success
%
% input trialData
% 1. use selectStateTransition function: [3 11] or [4 11] vs [3 4 5]
% 2. fetch [5 6] vs [5 12]
% and divide failed trials into undershoot and overshoot
% 2-1 get a last position(last timepoint in state 5) <= plot the position of each direction
% add the circle by https://www.mathworks.com/help/images/ref/viscircles.html?s_tid=srchtitle#bta7m97-1-radii
% 2-2 get inner product b/w target vector and (position-target center).
% negative=undershoot and positive=overshoot. 
% 2-3 check if the distance b/w position and target is bigger than radius
% 2-4 get the count of each reward and plot it
% 3. use selectStateTransition function: [6 13] vs [6 7]


%% reaction-time
% get trails [4 5]
% calculate the distance to the center target and get the last time
% exceeding the center target distance (maybe always 9mm)
% plot as a function of rewards

%% peak-speed
% get velocity rmms of handkinematics movement and get max 
% plot the mean as a function of rewards 

%% homing-time
% start time when distance is 2/3 of reach target
% end tiem when distance is 1 mm away from reach target failure trial can
% extend there reaching time 150 msec


%% pupil size during reach? preparatory? or whole period?


%% EMG trajectory during reach
