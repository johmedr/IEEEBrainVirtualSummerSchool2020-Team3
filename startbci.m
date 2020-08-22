% Clean up the session
delete(timerfindall);

% Start the BYB driver
startbybreader();

% Start the interface 
flickeringcheckboards(1, 2, [11 17]);

% Create some trials
trialSequence = randi(2,1,40) 
trialDuration = 7 %sec
intertrialDuration = 2 %sec
trials = preparetrials(trialSequence, trialDuration, intertrialDuration); 
start(trials); 

pause(2);