function [tim] = preparetrials(trialsSeq, trialDur, intertrialDur)
% preparetrials Prepare a trials sequence (trialsSeq) with certain duration
% (trialDur) and intertrial duration (intertrialDur). Returns a timer
% object that can be started and stopped with start(.) and stop(.)
    global currentTrials
    global trialDuration
    global intertrialDuration
    global trialNumber
    global trialTime
    trialDuration = trialDur; 
    intertrialDuration = intertrialDur; 
    trialNumber = 1;
    currentTrials = trialsSeq;
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
            hidecheckerboardsexcept(currentTrials(trialNumber));
        end
    elseif trialTime > trialDuration && trialTime <= trialDuration + intertrialDuration 
        if selectedIdx ~= 0 
            setselectedcheckerboard(0);
            hidecheckerboardsexcept(0);
        end
    else
        trialTime = 0;
        
        
        if trialNumber < size(currentTrials, 2)
            trialNumber = trialNumber + 1;
        end
    end
end
