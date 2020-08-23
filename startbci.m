% Clean up the session
delete(timerfindall);

% Start the BYB driver
maximumRecordingData = 100000; % data points - 10 sec
sliceSize = 1000; %Transfer data by chunks of 1000 points 
startbybreader(maximumRecordingData, sliceSize);
% Then, data can be accessed in the global variable dataByb
global dataByb; % array of length maximumRecordingData
% Events for the data chunk are stored in the global variable eventByb
% Event i corresponds to the data chunk dataByb(i*sliceSize:(i+1)*sliceSize)
global eventByb; 


% Start the interface 
figure('Units','normalized','Position',[0 0 1 1])
flickeringFreqs  = [11, 17] %Hz
flickeringcheckboards(1, 2, flickeringFreqs);

% We have 20 trials of 7 sec per class, with 2 sec intertrial interval
nTrials = 20
trialDuration = 7 %sec
intertrialDuration = 2 %sec

trialSequence = repelem([1 2], nTrials)
% Randomly order the trials
trialSequence = trialSequence(randperm(2 * nTrials))

% Prepare and start the trials
trials = preparetrials(trialSequence, trialDuration, intertrialDuration); 
start(trials); 