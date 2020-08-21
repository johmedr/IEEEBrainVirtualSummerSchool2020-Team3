% Select subject
subj = 3;

% Load the data file and extract necessary fields
Data = load(sprintf('single/Sub%d_singletarget.mat', subj));

x = Data.Data.EEG.'; % The EEG signal (1 electrode, 30 seconds, ~25 trials)
y = Data.Data.TargetFrequency.'; % The flickering frequency (around 10Hz)
Fs = Data.Data.AmpSamplingFrequency;  % The sampling frequency (512Hz)
nepochs = size(x, 1) ;

clf

% Loop over epochs
for c = 1:nepochs
   % Extract the timeserie for the epoch
   ts = x(c, :) ;
   % Estimate the power spectral density using Welch's method
   [pxx, f] = pwelch(ts, 1024,256,[], Fs);
   
   % Select interesting frequencies, most things happen in this range 
   mask = f > 3 & f < 20;
   
   % Convert the PSD to dB 
   pxx_db = pow2db(pxx(mask, :)); 
   % Find the maximal value, and read the corresponding peak frequency
   [maxval, argmax] = max(pxx); 
   f_peak = f(argmax);
   
   % Make a plot 
   subplot(4,7,c);
   
    plot(f(mask, :),pow2db(pxx(mask, :)));
    title(sprintf("Epoch n°%d - Flickering fq: %.1f - Peak~ %.1f", c, y(c,:), f_peak));
    xlabel('Frequency (Hz)');
    ylabel('PSD (dB/Hz)');
    xline(y(c,:));
    hold on;
end 

