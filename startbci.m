% Clean up the session
delete(timerfindall);

% Start the BYB driver
startbybreader();

% Start the interface 
figure('Units','normalized','Position',[0 0 1 1])
flickeringFreqs  = [11, 17] %Hz
flickeringcheckboards(1, 2, flickeringFreqs);

% We have 20 trials of 7 sec per class, with 2 sec intertrial interval
nTrials = 20
trialDuration = 7 %sec
intertrialDuration = 2 %sec

% Randomly order the trials
trialSequence = repelem([1 2], nTrials)
trialSequence = trialSequence(randperm(2 * nTrials))

% Prepare and start the trials
trials = preparetrials(trialSequence, trialDuration, intertrialDuration); 
start(trials); 

% TODO: Synchronise trials with data
% TODO: Simple functions to get trials data + event