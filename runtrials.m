function [tim] = preparetrials(trials, trialDuration, intertrialDuration)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    global currentTrials
    global trialDuration
    global intertrialDuration
    global trialNumber
    global trialTime
    trialNumber = 1;
    currentTrials = trials;
    trialTime = 0
    period = 0.5
    tim = timer('ExecutionMode','fixedRate','Period', 0.5,'TimerFcn',{@performtrial, period});
end


function performtrial(obj, evt, period) 
    global trialTime
    global currentTrials
    global trialNumber
    global trialDuration 
    global intertrialDuration 
    global selectedIdx
    trialTime = trialTime + period; 
    if trialTime <= trialDuration 
        if selectedIdx ~= currentTrials(trialNumber)
            setselectedcheckerboard(currentTrials(trialNumber));
        end
    elseif trialTime > trialDuration && trialTime <= trialDuration + intertrialDuration 
        if selectedIdx ~= 0 
            setselectedcheckerboard(0);
        end
    else
        trialTime = 0;
        
        
        if trialNumber < size(currentTrials, 2)
            trialNumber = trialNumber + 1;
        end
    end
end
