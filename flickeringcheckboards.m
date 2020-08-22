function [tim] = flickeringcheckboards(nRows, nCols, freqArray)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    defaultRefreshFreq = 60

    basePeriods = 0.5./(freqArray)
    global indivCounters 
    indivCounters = basePeriods
    global lastTimes
    width = 50
    cb = checkerboard(width) > 0.5;
    clear im
    clf

    for row = 1:nRows
        for col = 1:nCols
            idx = (row - 1) * nCols + col
            subplot(nRows, nCols, idx);
            if row == 1 & col == 1
                im = imshow(cb)
            else
                im = [im imshow(cb)];
            end
        end
    end
    tim = timer('ExecutionMode','fixedRate','Period',real(1/defaultRefreshFreq),'TimerFcn',{@flickerCheckerboards, im, basePeriods});
    start(tim)
    tic; 
end

function flickerCheckerboards(obj, evt, im, basePeriods)
    global indivCounters
    global lastTimes
    currTime = toc; 
    
    for i = 1:size(im, 2)
        if indivCounters(i) > currTime
            indivCounters(i) = indivCounters(i) - currTime;
        else 
            indivCounters(i) = basePeriods(i);
            im(i).CData = ~im(i).CData;
            lastTimes(i, :) = [lastTimes(i); cputime]; 
        end
            %drawnow limitrate;
    end
    %drawnow;
    
    tic;
end
